part of '../../map_screen.dart';

extension _Sockets on _MapScreenState {
  Future<void> connectSocket() async {
    String? fcmToken = await FirebaseNotificationService.getFCMToken();
    await PrefsHelper.setString(AppConstants.fcmToken, fcmToken);

    SocketServices.socket?.on('new-ride-request', (data) {
      try {
        if (data is! Map || data['newRideRequest'] != true) return;

        final rawDetails = data['rideDetails'];
        if (rawDetails is! Map) {
          debugPrint('new-ride-request: rideDetails missing or invalid');
          return;
        }

        final details = RideDetailsSocketModel.fromJson(
          Map<String, dynamic>.from(rawDetails),
        );
        if (details.rideId == null || details.rideId!.isEmpty) {
          debugPrint('new-ride-request: rideId missing in payload');
          return;
        }

        mapOPTController.rideDetailsData.value = details;
        mapOPTController.rideDetailsData.refresh();
        mapOPTController.startRideRequestTimer();
        mapOPTController.isPassengerRequest.value = true;
      } catch (e, stackTrace) {
        debugPrint('new-ride-request error: $e');
        debugPrint('STACK: $stackTrace');
      }
    });

    SocketServices.socket?.on('cancel-ride-request', (data) {
      if (data['isCancelPickRequest'] == true) {
        mapOPTController.isPassengerRequest.value = false;
        mapOPTController.rideDetailsData.value = null;
        mapOPTController.cancelRideRequestTimer();
      }
    });

    SocketServices.socket?.on('ride-accepted', (data) {
      if (data is! Map<String, dynamic>) return;
      if (data['isRideAccepted'] != true) return;

      final driver = data['driver'];
      rideController.isRideAccepted.value = true;
      rideController.acceptedRideDriverName.value =
          (driver is Map ? driver['driverName'] : null) ?? '';

      try {
        rideController.acceptRideModel.value = AcceptRideModel.fromJson(data);
      } catch (e) {
        debugPrint('ride-accepted parse error: $e');
      }

      final rideId = rideController.acceptRideModel.value?.ride?.id;
      if (rideId != null && rideId.isNotEmpty) {
        mapOPTController.startRideLocationSync(rideId);
      }
    });

    SocketServices.socket?.on('ride-accepted-driver', (data) {
      if (data is Map<String, dynamic>) {
        if (data['isRideAcceptedDriver'] == true) {
          mapOPTController.acceptedRideDriverDataStatus.value = true;
          mapOPTController.acceptedRideDriverData.value =
              AcceptRideDriverModel.fromJson(data);
          mapOPTController.isPassengerRequest.value = false;
          mapOPTController.cancelRideRequestTimer();

          final rideId =
              mapOPTController.acceptedRideDriverData.value?.ride?.sId;
          if (rideId != null && rideId.isNotEmpty) {
            mapOPTController.startRideLocationSync(rideId);
            mapOPTController.prefetchPickupRouteEstimate();
          }
        }
      }
    });

    SocketServices.socket?.off('get-ride-driver-location');
    SocketServices.socket?.on('get-ride-driver-location', (data) {
      final socketReceiveAt = DateTime.now();
      final bool isPassenger =
          userController.userModel.value?.userProfile?.role ==
              AppConstants.passenger;
      if (isPassenger && !mapOPTController.showPassengerDriverCar) return;
      try {
        Map<String, dynamic> jsonData;
        if (data is List) {
          jsonData = Map<String, dynamic>.from(data[0]);
        } else if (data is String) {
          jsonData = jsonDecode(data);
        } else if (data is Map) {
          jsonData = Map<String, dynamic>.from(data);
        } else {
          return;
        }
        final updatedDriverLocation = GetRideDriverLocation.fromJson(jsonData);
        final driverLoc = updatedDriverLocation.driverLocation;
        final updatedCoords = driverLoc?.coordinates;

        // Prefer nested driverLocation extras; fall back to top-level fields
        // if the backend forwards telemetry beside the GeoJSON point.
        double? speed = driverLoc?.speed;
        double? heading = driverLoc?.heading;
        double? accuracy = driverLoc?.accuracy;
        DateTime? gpsTimestamp = driverLoc?.updatedAt;
        if (speed == null) {
          final raw = jsonData['speed'] ?? jsonData['speedMps'];
          if (raw is num) speed = raw.toDouble();
        }
        if (heading == null) {
          final raw =
              jsonData['heading'] ?? jsonData['bearing'] ?? jsonData['headingDegrees'];
          if (raw is num) heading = raw.toDouble();
        }
        if (accuracy == null) {
          final raw = jsonData['accuracy'] ?? jsonData['accuracyMeters'];
          if (raw is num) accuracy = raw.toDouble();
        }
        if (gpsTimestamp == null) {
          final raw = jsonData['updatedAt'] ??
              jsonData['timestamp'] ??
              jsonData['locationUpdatedAt'];
          if (raw is String) {
            gpsTimestamp = DateTime.tryParse(raw);
          } else if (raw is num) {
            final value = raw.toInt();
            gpsTimestamp = DateTime.fromMillisecondsSinceEpoch(
              value < 1000000000000 ? value * 1000 : value,
              isUtc: true,
            ).toLocal();
          }
        }

        if (updatedCoords != null && updatedCoords.length >= 2) {
          final sample = _liveDriverTracker.accept(
            latitude: updatedCoords[1],
            longitude: updatedCoords[0],
            gpsTimestamp: gpsTimestamp,
            speedMps: speed,
            headingDegrees: heading,
            accuracyMeters: accuracy,
            receivedAt: socketReceiveAt,
          );

          if (_liveLocationDiag) {
            debugPrint(
              'SOCKET_RECEIVED ${socketReceiveAt.toIso8601String()} '
              'get-ride-driver-location '
              'lat=${updatedCoords[1]} lng=${updatedCoords[0]} '
              'speed=$speed heading=$heading '
              'accuracy=$accuracy '
              'gpsTs=$gpsTimestamp '
              'accepted=${sample != null} seq=${sample?.sequence}',
            );
          }

          if (sample != null) {
            _applyLiveDriverSample(sample);
          }
        }

        mapOPTController.getRideDriverLocation.value = updatedDriverLocation;
        mapOPTController.getRideDriverLocation.refresh();
        mapOPTController.markDriverLocationSocketReceived();
        if (isPassenger &&
            updatedCoords != null &&
            updatedCoords.length >= 2 &&
            _fullRoutePoints.isEmpty) {
          final rideStatus = mapOPTController.rideStatusData.value;
          if (rideStatus?.startRide == true) {
            pickupToDestinationRoute();
          } else if (rideStatus?.ongoingRide == true) {
            loadAcceptedRideRoute();
          }
        }
      } catch (e) {
        debugPrint('get-ride-driver-location error: $e');
      }
    });

    SocketServices.socket?.on('ride-status', (data) async {
      try {
        Map<String, dynamic> jsonData;
        if (data is List) {
          jsonData = Map<String, dynamic>.from(data[0]);
        } else if (data is String) {
          jsonData = jsonDecode(data);
        } else if (data is Map) {
          jsonData = Map<String, dynamic>.from(data);
        } else {
          debugPrint('📡❌ ride-status: unknown payload type → $data');
          return;
        }

        debugPrint('📡 ride-status received → $jsonData');

        final RideModel.RideStatusModel rideStatus =
            RideModel.RideStatusModel.fromJson(jsonData);

        final rideId = rideStatus.ride?.id;
        final role = userController.userModel.value?.userProfile?.role;
        debugPrint(
          '📡 ride-status parsed | role=$role rideId=$rideId '
          'acceptRide=${rideStatus.acceptRide} ongoingRide=${rideStatus.ongoingRide} '
          'arrivingRide=${rideStatus.arrivingRide} startRide=${rideStatus.startRide} '
          'completeRide=${rideStatus.completeRide} ride.status=${rideStatus.ride?.status}',
        );

        if (mapOPTController.shouldIgnoreRideStatus(rideId) &&
            rideStatus.completeRide != true &&
            rideStatus.driverCancel != true &&
            rideStatus.passengerCancel != true) {
          debugPrint(
              '📡⏭️ ride-status ignored — ride already finished locally');
          return;
        }

        // Cancels reset straight back to the initial map without ever storing
        // the status — storing driverCancel=true would re-hide the nav bar
        // that finishRide() just restored.
        if (rideStatus.driverCancel == true ||
            rideStatus.passengerCancel == true ||
            rideStatus.ride?.status == 'cancelled') {
          debugPrint('❌ ride-status: Ride cancelled → resetting to initial');

          if (rideStatus.driverCancel == true) {
            Get.snackbar(
              'Ride Cancelled',
              'The driver has cancelled the ride request.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
              margin: EdgeInsets.only(bottom: 90.h, left: 10.w, right: 10.w),
            );
          }

          await finishRide(rideId: rideId);
          return;
        }

        if (rideStatus.completeRide == true) {
          debugPrint('🏁✅ ride-status: completeRide=true | role=$role');
          _haltVehicleMotion(phase: VehicleMotionPhase.arrived);
          _routeGeneration++;
          _polylines = <Polyline>{};
          _clearRoadRoute();
          final isDriver = role == AppConstants.driver;
          if (isDriver) {
            debugPrint('🏁🚗 driver → finishRide()');
            await finishRide(rideId: rideId);
          } else {
            debugPrint(
              '🏁🧳 passenger → keep panel, set completeRide=true | rideId=$rideId',
            );
            mapOPTController.rideStatusData.value = rideStatus;
            mapOPTController.rideStatusData.refresh();
            mapOPTController.stopRideLocationSync();
            debugPrint(
              '🏁🧳 passenger rideStatusData updated → '
              'completeRide=${mapOPTController.rideStatusData.value?.completeRide}',
            );
          }
          return;
        }

        debugPrint('📡 ride-status: normal update → saving rideStatusData');
        mapOPTController.rideStatusData.value = rideStatus;
        mapOPTController.rideStatusData.refresh();

        if (rideStatus.acceptRide == true) {
          rideController.drivers.clear();
          mapOPTController.isCurrentMarkerShowOrNot.value = true;
          mapOPTController.isPassengerRequest.value = false;
          mapOPTController.cancelRideRequestTimer();

          final isDriver = userController.userModel.value?.userProfile?.role ==
              AppConstants.driver;
          final rideId = rideStatus.ride?.id;
          if (rideId != null && rideId.isNotEmpty) {
            mapOPTController.startRideLocationSync(rideId);
            if (isDriver) {
              mapOPTController.prefetchPickupRouteEstimate();
            }
          }
        } else if (rideStatus.ongoingRide == true) {
          final rideId = rideStatus.ride?.id;
          if (rideId != null && rideId.isNotEmpty) {
            mapOPTController.maybeEmitGetDriverLocation(rideId);
          }
          loadAcceptedRideRoute();
        } else if (rideStatus.arrivingRide == true) {
          _haltVehicleMotion(phase: VehicleMotionPhase.stopped);
          _routeGeneration++;
          markers.clear();
          _polylines = <Polyline>{};
          _clearRoadRoute();
        } else if (rideStatus.startRide == true) {
          _haltVehicleMotion(phase: VehicleMotionPhase.idle);
          _routeGeneration++;
          _polylines = <Polyline>{};
          _clearRoadRoute();
          mapOPTController.prefetchDestinationRouteEstimate();
          final rideId = rideStatus.ride?.id;
          if (rideId != null && rideId.isNotEmpty) {
            mapOPTController.maybeEmitGetDriverLocation(rideId);
          }
          pickupToDestinationRoute();
        }
      } catch (e, stackTrace) {
        debugPrint('📡❌ ride-status ERROR: $e');
        debugPrint('📡❌ STACK: $stackTrace');
      }
    });

    SocketServices.onReconnected =
        mapOPTController.resumeRideLocationSyncIfNeeded;
  }

  void disconnectSocket() {
    SocketServices.onReconnected = null;
    SocketServices.socket?.off('new-ride-request');
    SocketServices.socket?.off('cancel-ride-request');
    SocketServices.socket?.off('ride-accepted');
    SocketServices.socket?.off('ride-accepted-driver');
    SocketServices.socket?.off('get-ride-driver-location');
    SocketServices.socket?.off('ride-status');
  }
}
