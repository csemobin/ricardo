import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ricardo/app/helpers/custom_location_helper.dart';
import 'package:ricardo/feature/view/home/map/helpers/location_bootstrap_helper.dart';
import 'package:ricardo/app/helpers/snackbar_helper.dart';
import 'package:ricardo/feature/models/home/ride_status_model.dart';
import 'package:ricardo/feature/models/socket/accept_ride_driver_model.dart';
import 'package:ricardo/feature/models/socket/get_ride_driver_location.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/feature/view/home/map/driver_location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/feature/controllers/profile/favourite_rides_controller.dart';
import 'package:ricardo/services/direction_services.dart';
import 'package:ricardo/services/api_client.dart';

class MapOPTController extends GetxController {
  static const int freeWaitingPeriodSeconds = 120;
  static const String _waitingRideIdKey = 'driver_waiting_ride_id';
  static const String _arrivalAtKeyPrefix = 'driver_arrival_at_';
  static const String _waitingStartedAtKeyPrefix = 'driver_waiting_started_at_';
  static const String _waitingFinalSecondsKeyPrefix =
      'driver_waiting_final_seconds_';

  // Controller are here
  RxBool isCurrentMarkerShowOrNot = true.obs;

  UserController? _userController;
  UserController get userController =>
      _userController ??= Get.find<UserController>();
  RxBool showCancelReasonDialog = false.obs;
  final Rx<GetRideDriverLocation?> getRideDriverLocation =
      Rx<GetRideDriverLocation?>(null);
  final Rxn<LatLng> animatedCurrentMarkerPosition = Rxn<LatLng>();
  final Rxn<LatLng> animatedRemoteDriverPosition = Rxn<LatLng>();
  final RxDouble animatedCurrentMarkerSpeedMps = 0.0.obs;
  final RxDouble animatedRemoteDriverSpeedMps = 0.0.obs;
  final RxDouble animatedCurrentMarkerHeading = 0.0.obs;
  final RxDouble animatedRemoteDriverHeading = 0.0.obs;
  final RxString remoteVehiclePhase = 'idle'.obs;

  /// Bumped once per live-marker paint (after lat+heading written).
  /// MapView listens to this alone so position/heading don't each force a rebuild.
  final RxInt liveOverlayRevision = 0.obs;
  final RxInt markerAssetsRevision = 0.obs;
  final prefetchedPickupDistance = 0.obs;
  final prefetchedPickupDuration = 0.obs;
  final prefetchedDestinationDistance = 0.obs;
  final prefetchedDestinationDuration = 0.obs;
  final Rxn<DateTime> lastDriverLocationSocketAt = Rxn<DateTime>();
  DateTime? _lastGetDriverLocationEmitAt;
  Timer? _rideLocationSyncTimer;
  String? _syncingRideId;
  String? _lastFinishedRideId;
  DateTime? _lastFinishedAt;
  RxDouble buttonTop = 300.0.obs;
  RxDouble buttonRight = 10.0.obs;

  // Controls Uber-style location button visibility.
  // Hidden by default; shown when the map camera moves away from the user's
  // current position; hidden again once the user taps it.
  RxBool isLocationButtonVisible = false.obs;

  // Set to true while the "go to my location" animation is running so that the
  // camera-move callbacks fired by the animation don't re-show the button.
  bool _isCenteringCamera = false;

  int _programmaticCameraGen = 0;

  void notifyMapMoved() {
    // Ignore camera events that we triggered ourselves (e.g. animateCamera).
    if (_isCenteringCamera) return;
    isLocationButtonVisible.value = true;
  }

  /// Suppress location-button flashes while we programmatically pan/follow.
  void beginProgrammaticCamera({
    Duration hold = const Duration(milliseconds: 500),
  }) {
    _isCenteringCamera = true;
    final gen = ++_programmaticCameraGen;
    Future.delayed(hold, () {
      if (gen != _programmaticCameraGen) return;
      _isCenteringCamera = false;
    });
  }

  void hideLocationButton() {
    _isCenteringCamera = true;
    isLocationButtonVisible.value = false;
    final gen = ++_programmaticCameraGen;
    Future.delayed(const Duration(milliseconds: 900), () {
      if (gen != _programmaticCameraGen) return;
      _isCenteringCamera = false;
    });
  }

  @override
  void onInit() {
    super.onInit();
    _waitingStatusWorker = ever<RideStatusModel?>(
      rideStatusData,
      (status) => unawaited(_syncWaitingState(status)),
    );
    // Do not apply SharedPreferences / last-known as the user location.
    // First GPS from the map screen is the source of truth.
  }

  Timer? _rideRequestTimer;
  RxDouble timerProgress = 1.0.obs;
  RxBool isRideRequestExpired = false.obs;

  void startRideRequestTimer() {
    _rideRequestTimer?.cancel();

    final timeoutMinutes =
        int.tryParse(dotenv.env['RIDE_MODAL_EXPIRE_TIME'] ?? '') ?? 2;
    final totalMillis = timeoutMinutes * 60 * 1000;
    final startTime = DateTime.now();

    timerProgress.value = 1.0;
    isRideRequestExpired.value = false;

    _rideRequestTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        final remaining = totalMillis - elapsed;

        if (remaining <= 0) {
          timerProgress.value = 0.0;
          isRideRequestExpired.value = true;
          timer.cancel();
        } else {
          timerProgress.value = remaining / totalMillis;
        }
      },
    );
  }

  void cancelRideRequestTimer() {
    _rideRequestTimer?.cancel();
    _rideRequestTimer = null;
    timerProgress.value = 1.0;
    isRideRequestExpired.value = false;
  }

  //***************************************************
  // ******* Current Location Related work are here****
  // ***************************************************

  RxString currentLocation = kLocationLoadingAddress.obs;
  RxString currentLocationLine1 = kLocationLoadingAddress.obs;
  RxString currentLocationLine2 = ''.obs;
  RxDouble? currentLatitudePosition = 0.0.obs;
  RxDouble? currentLongitudePosition = 0.0.obs;
  DateTime? _lastAddressRefreshAt;
  DateTime? _lastAppliedGpsAt;
  LatLng? _lastGeocodedAt;
  int _geocodeGeneration = 0;
  // Heading in degrees clockwise from North. Used to rotate the car marker so
  // it points the way the driver is moving. Stays at the last valid value when
  // the device is stationary (otherwise the icon spins from GPS jitter).
  RxDouble headingDegrees = 0.0.obs;

  bool get hasValidCoordinates =>
      isValidLatLng(
        currentLatitudePosition?.value,
        currentLongitudePosition?.value,
      ) &&
      !isAppFallbackCoordinate(
        currentLatitudePosition?.value,
        currentLongitudePosition?.value,
      );

  bool get needsAddressRefresh {
    if (!hasValidCoordinates) return false;
    if (isUnknownAddressText(currentLocation.value)) return true;
    final geocoded = _lastGeocodedAt;
    if (geocoded == null) return true;
    final lat = currentLatitudePosition?.value;
    final lng = currentLongitudePosition?.value;
    if (lat == null || lng == null) return false;
    return Geolocator.distanceBetween(
          geocoded.latitude,
          geocoded.longitude,
          lat,
          lng,
        ) >=
        30;
  }

  /// Cached prefs are never the live user position. Kept so splash/bootstrap
  /// callers remain valid; GPS apply is the only writer of current coords.
  Future<void> seedCachedCoordinates() async {}

  /// Accepts a fresh device GPS sample. Older fixes cannot overwrite newer ones.
  bool applyCurrentGps({
    required double latitude,
    required double longitude,
    DateTime? gpsTimestamp,
  }) {
    if (!isValidLatLng(latitude, longitude)) return false;
    if (isAppFallbackCoordinate(latitude, longitude)) return false;
    final ts = gpsTimestamp ?? DateTime.now();
    if (_lastAppliedGpsAt != null && ts.isBefore(_lastAppliedGpsAt!)) {
      return false;
    }
    _lastAppliedGpsAt = ts;
    currentLatitudePosition?.value = latitude;
    currentLongitudePosition?.value = longitude;
    return true;
  }

  Future<void> maybeRefreshAddress() async {
    if (!needsAddressRefresh) return;
    final now = DateTime.now();
    if (_lastAddressRefreshAt != null &&
        now.difference(_lastAddressRefreshAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastAddressRefreshAt = now;
    await getLocation();
  }

  Future<void> getLocation({Position? knownPosition}) async {
    final gen = ++_geocodeGeneration;
    try {
      if (knownPosition != null) {
        applyCurrentGps(
          latitude: knownPosition.latitude,
          longitude: knownPosition.longitude,
          gpsTimestamp: knownPosition.timestamp,
        );
      } else if (!hasValidCoordinates) {
        final position = await resolveInitialPosition();
        if (gen != _geocodeGeneration) return;
        if (position != null) {
          applyCurrentGps(
            latitude: position.latitude,
            longitude: position.longitude,
            gpsTimestamp: position.timestamp,
          );
        }
      }

      if (gen != _geocodeGeneration) return;

      final lat = currentLatitudePosition?.value;
      final lng = currentLongitudePosition?.value;
      if (!isValidLatLng(lat, lng) || isAppFallbackCoordinate(lat, lng)) {
        return;
      }

      final parts = await reverseGeocodeAddressParts(lat!, lng!);
      if (gen != _geocodeGeneration) return;
      if (parts == null) return;

      currentLocationLine1.value = parts.firstLine;
      currentLocationLine2.value = parts.secondLine;
      currentLocation.value = parts.full;
      _lastGeocodedAt = LatLng(lat, lng);
    } catch (e) {
      debugPrint('getLocation failed: $e');
    }
  }

//***************************************************
// ******* Offline & Online Related work are here ****
// ***************************************************

  RxBool isDriverSwitchAvailabilityStatus = false.obs;

  Future<void> driverSwitchAvailabilityStatus() async {
    final user = userController.userModel.value;
    final bool previousIsOnline = user?.driverProfile?.isOnline ?? false;

    // Optimistic flip — UI updates instantly, no waiting for the round trip.
    user?.driverProfile?.isOnline = !previousIsOnline;
    userController.userModel.refresh();

    isDriverSwitchAvailabilityStatus.value = true;
    final response = await ApiClient.patch(
      ApiUrls.driverSwitchAvailabilityStatus,
      {
        "location": {
          "type": "Point",
          "coordinates": [
            currentLongitudePosition?.value,
            currentLatitudePosition?.value
          ]
        }
      },
    );
    isDriverSwitchAvailabilityStatus.value = false;

    if (response.statusCode != 200 && response.statusCode != 201) {
      // Revert on failure.
      user?.driverProfile?.isOnline = previousIsOnline;
      userController.userModel.refresh();
      showSnackbar(
          'Error', response.body?['message'] ?? 'Failed to update status');
    }
  }

  //***************************************************
  // ******* Socket Rider Response  ****
  // ***************************************************
  RxBool isPassengerRequest = false.obs;
  Rx<RideDetailsSocketModel?> rideDetailsData =
      Rx<RideDetailsSocketModel?>(null);

  Rx<DateTime?> rideRequestReceivedAt =
      Rx<DateTime?>(null); // tracks when request arrived
  Rx<RideStatusModel?> rideStatusData =
      Rx<RideStatusModel?>(null); // ride-status socket data

  final RxInt freeWaitingSeconds = freeWaitingPeriodSeconds.obs;
  final RxInt waitingFineSeconds = 0.obs;
  final RxBool isWaitingFineAvailable = false.obs;
  final RxBool isWaitingFineRunning = false.obs;
  final RxBool wasWaitingFineStarted = false.obs;
  Timer? _waitingClock;
  Worker? _waitingStatusWorker;
  String? _waitingRideId;
  int? _arrivalAtMilliseconds;
  int? _waitingStartedAtMilliseconds;
  int? _finalWaitingSeconds;

  //***************************************************
// *** Socket  Driver Model  Response ****
// ***************************************************
  RxBool acceptedRideDriverDataStatus = false.obs;
  Rx<AcceptRideDriverModel?> acceptedRideDriverData =
      Rx<AcceptRideDriverModel?>(null);

  //***************************************************
  // ******* Book a Ride From the Driver  **************
  // ***************************************************
  final isRideAcceptStatusLoading = false.obs;

  Future<void> rideAcceptRide(String rideId) async {
    if (rideId.isEmpty) {
      showSnackbar('Error', 'Ride id is missing');
      return;
    }

    isRideAcceptStatusLoading.value = true;
    LatLng currentLatLun = await CustomLocationHelper.getCurrentLocation();

    final response =
        await ApiClient.postData(ApiUrls.rideAcceptRideByRideId(rideId), {
      "coordinates": [currentLatLun.longitude, currentLatLun.latitude]
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      isRideAcceptStatusLoading.value = false;
      isPassengerRequest.value = false;
      rideDetailsData.value = null;
      cancelRideRequestTimer();
      await driverServiceFun(rideId);
      await prefetchPickupRouteEstimate();
    } else {
      isRideAcceptStatusLoading.value = false;
      showSnackbar('Error', response.body['message']);
    }
  }

  // ---------------- Tips related work are here
  // -------------------------------------------
  final TextEditingController provideTips = TextEditingController();
  RxBool isLoading = false.obs;
  RxBool isTipsSuccess = false.obs;

  /// Ride ids the passenger already tipped in this session (no API flag).
  final RxSet<String> tippedRideIds = <String>{}.obs;

  bool hasTippedRide(String? rideId) {
    if (rideId == null || rideId.isEmpty) return false;
    return tippedRideIds.contains(rideId);
  }

  Future<bool> provideTipsHandler(String rideId) async {
    if (rideId.isEmpty) return false;

    if (provideTips.text.trim().isEmpty) {
      isTipsSuccess.value = false;
      showSnackbar(
        'Tips',
        'Please enter or select a tip amount',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isLoading.value = true;

      final response = await ApiClient.postData(
        ApiUrls.sendTips,
        {
          "amount": provideTips.text.trim(),
          "rideId": rideId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        isTipsSuccess.value = true;
        tippedRideIds.add(rideId);
        tippedRideIds.refresh();
        provideTips.clear();
        return true;
      } else {
        showSnackbar('Error', response.body['message'],
            snackPosition: SnackPosition.BOTTOM);
        isTipsSuccess.value = false;
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      isTipsSuccess.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ------------- Review related work are here
  // -------------------------------------------

  final isAddedFavouriteRiderStatus = false.obs;
  final addedFavourite = false.obs;

  /// Prefetch whether [driverId] is already in favourites (disables the button).
  Future<void> prepareFavouriteForDriver(String? driverId) async {
    addedFavourite.value = false;
    if (driverId == null || driverId.isEmpty) return;

    try {
      final favController = Get.isRegistered<FavouriteRidesController>()
          ? Get.find<FavouriteRidesController>()
          : Get.put(FavouriteRidesController());
      if (favController.favouriteRiderModel.isEmpty) {
        await favController.fetchFavouriteRides();
      }
      addedFavourite.value = favController.favouriteRiderModel.any(
        (e) => e.driverId == driverId,
      );
    } catch (e) {
      debugPrint('prepareFavouriteForDriver: $e');
    }
  }

  Future<bool> addedFavouriteRide(String driverId) async {
    if (addedFavourite.value) return false;

    try {
      isAddedFavouriteRiderStatus.value = true;

      final response = await ApiClient.postData(
        ApiUrls.favoriteRider,
        {"driver": driverId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        addedFavourite.value = true;
        return true;
      }

      final message = response.body is Map
          ? response.body['message']?.toString() ?? ''
          : '';
      final alreadyFavorite = response.statusCode == 400 &&
          message.toLowerCase().contains('already');

      if (alreadyFavorite) {
        showSnackbar("Info", "Already added to favorites");
        addedFavourite.value = true;
        return false;
      }

      addedFavourite.value = false;
      showSnackbar(
        'Error',
        message.isNotEmpty ? message : 'Something went wrong',
      );
      return false;
    } catch (e) {
      addedFavourite.value = false;
      showSnackbar('Error', e.toString());
      debugPrint(e.toString());
      return false;
    } finally {
      isAddedFavouriteRiderStatus.value = false;
    }
  }

  Future<void> _syncWaitingState(RideStatusModel? status) async {
    if (status == null) return;
    if (userController.userModel.value?.userProfile?.role !=
        AppConstants.driver) {
      return;
    }

    final rideId = status.ride?.id;
    if (rideId == null || rideId.isEmpty) return;

    if (status.completeRide == true ||
        status.driverCancel == true ||
        status.passengerCancel == true ||
        status.ride?.status == 'cancelled') {
      await clearWaitingTimerState(rideId: rideId);
      return;
    }

    if (status.arrivingRide == true) {
      await _restoreWaitingState(rideId, createArrivalIfMissing: true);
      _updateWaitingClock();
      _startWaitingClock();
      return;
    }

    if (status.startRide == true) {
      await _restoreWaitingState(rideId);
      _updateWaitingClock();
      _waitingClock?.cancel();
      isWaitingFineRunning.value = false;
    }
  }

  Future<void> _restoreWaitingState(
    String rideId, {
    bool createArrivalIfMissing = false,
  }) async {
    final storedRideId = await PrefsHelper.getString(_waitingRideIdKey);
    if (storedRideId.isNotEmpty && storedRideId != rideId) {
      await _removeWaitingKeys(storedRideId);
    }

    _waitingRideId = rideId;
    await PrefsHelper.setString(_waitingRideIdKey, rideId);

    var arrivalAt = await PrefsHelper.getInt('$_arrivalAtKeyPrefix$rideId');
    if (arrivalAt < 0 && createArrivalIfMissing) {
      arrivalAt = DateTime.now().millisecondsSinceEpoch;
      await PrefsHelper.setInt('$_arrivalAtKeyPrefix$rideId', arrivalAt);
    }

    final waitingStartedAt =
        await PrefsHelper.getInt('$_waitingStartedAtKeyPrefix$rideId');
    final finalWaitingSeconds =
        await PrefsHelper.getInt('$_waitingFinalSecondsKeyPrefix$rideId');

    _arrivalAtMilliseconds = arrivalAt >= 0 ? arrivalAt : null;
    _waitingStartedAtMilliseconds =
        waitingStartedAt >= 0 ? waitingStartedAt : null;
    _finalWaitingSeconds =
        finalWaitingSeconds >= 0 ? finalWaitingSeconds : null;
    wasWaitingFineStarted.value = _waitingStartedAtMilliseconds != null;
  }

  void _startWaitingClock() {
    _waitingClock?.cancel();
    _waitingClock = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateWaitingClock(),
    );
  }

  void _updateWaitingClock() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final arrivalAt = _arrivalAtMilliseconds;
    if (arrivalAt != null) {
      final elapsed = ((now - arrivalAt) / 1000).floor().clamp(0, 1 << 30);
      freeWaitingSeconds.value = (freeWaitingPeriodSeconds - elapsed)
          .clamp(0, freeWaitingPeriodSeconds);
    } else {
      freeWaitingSeconds.value = freeWaitingPeriodSeconds;
    }

    final waitingStartedAt = _waitingStartedAtMilliseconds;
    if (_finalWaitingSeconds != null) {
      waitingFineSeconds.value = _finalWaitingSeconds!;
    } else if (waitingStartedAt != null) {
      waitingFineSeconds.value =
          ((now - waitingStartedAt) / 1000).floor().clamp(0, 1 << 30);
    } else {
      waitingFineSeconds.value = 0;
    }

    isWaitingFineRunning.value =
        waitingStartedAt != null && _finalWaitingSeconds == null;
    isWaitingFineAvailable.value = freeWaitingSeconds.value == 0 &&
        waitingStartedAt == null &&
        rideStatusData.value?.arrivingRide == true;
  }

  Future<void> startWaitingFine() async {
    final rideId = activeRideId;
    if (rideId == null ||
        !isWaitingFineAvailable.value ||
        rideStatusData.value?.arrivingRide != true) {
      return;
    }

    final startedAt = DateTime.now().millisecondsSinceEpoch;
    _waitingRideId = rideId;
    _waitingStartedAtMilliseconds = startedAt;
    _finalWaitingSeconds = null;
    wasWaitingFineStarted.value = true;
    isWaitingFineAvailable.value = false;
    isWaitingFineRunning.value = true;
    await PrefsHelper.setString(_waitingRideIdKey, rideId);
    await PrefsHelper.setInt('$_waitingStartedAtKeyPrefix$rideId', startedAt);
    await PrefsHelper.remove('$_waitingFinalSecondsKeyPrefix$rideId');
    _updateWaitingClock();
    _startWaitingClock();
  }

  Future<int?> finalizeWaitingFine() async {
    final rideId = _waitingRideId ?? activeRideId;
    if (rideId == null || _waitingStartedAtMilliseconds == null) return null;

    _updateWaitingClock();
    _finalWaitingSeconds = waitingFineSeconds.value;
    isWaitingFineRunning.value = false;
    _waitingClock?.cancel();
    await PrefsHelper.setInt(
      '$_waitingFinalSecondsKeyPrefix$rideId',
      _finalWaitingSeconds!,
    );
    return _finalWaitingSeconds! > 0 ? _finalWaitingSeconds : null;
  }

  int? get waitingTimeForCompletion {
    if (!wasWaitingFineStarted.value || waitingFineSeconds.value <= 0) {
      return null;
    }
    return waitingFineSeconds.value;
  }

  Future<void> clearWaitingTimerState({String? rideId}) async {
    final storedRideId = await PrefsHelper.getString(_waitingRideIdKey);
    final id = rideId ??
        _waitingRideId ??
        (storedRideId.isNotEmpty ? storedRideId : null);
    _waitingClock?.cancel();
    _waitingClock = null;
    if (id != null && id.isNotEmpty) {
      await _removeWaitingKeys(id);
    }
    if (id == null || storedRideId == id) {
      await PrefsHelper.remove(_waitingRideIdKey);
    }
    _waitingRideId = null;
    _arrivalAtMilliseconds = null;
    _waitingStartedAtMilliseconds = null;
    _finalWaitingSeconds = null;
    freeWaitingSeconds.value = freeWaitingPeriodSeconds;
    waitingFineSeconds.value = 0;
    isWaitingFineAvailable.value = false;
    isWaitingFineRunning.value = false;
    wasWaitingFineStarted.value = false;
  }

  Future<void> _removeWaitingKeys(String rideId) async {
    await PrefsHelper.remove('$_arrivalAtKeyPrefix$rideId');
    await PrefsHelper.remove('$_waitingStartedAtKeyPrefix$rideId');
    await PrefsHelper.remove('$_waitingFinalSecondsKeyPrefix$rideId');
  }

  // Ride Status change are here
  RxBool isRideStatusChangeLoading = false.obs;

  Future<bool> rideStatusChange(String rideId, String status) async {
    try {
      isRideStatusChangeLoading.value = true;

      final response = await ApiClient.postData(
          ApiUrls.rideChangeRideStatus(rideId), {"status": status});
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('===================>>>>>>>>>>>>>> Maruf ${response.body}');
        return true;
      } else {
        showSnackbar('error', response.body['message']);
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    } finally {
      isRideStatusChangeLoading.value = false;
    }
  }

  RxBool isRideCanceledLoader = false.obs;
  final TextEditingController selectedReason = TextEditingController();
  RxBool isResult = false.obs;
  String? cancelRideErrorMessage;

  Future<bool> cancelRideByDriverHandler(String rideId) async {
    cancelRideErrorMessage = null;

    try {
      isRideCanceledLoader.value = true;
      isResult.value = false;

      final response = await ApiClient.postData(
        ApiUrls.cancelRideByDriver(rideId),
        {"cancellationReason": selectedReason.text.trim()},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        isResult.value = true;
        selectedReason.clear();
        return true;
      }

      isResult.value = false;
      if (response.body is Map) {
        cancelRideErrorMessage = response.body['message']?.toString();
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      isResult.value = false;
      return false;
    } finally {
      isRideCanceledLoader.value = false;
    }
  }

  //  Driver Service Function are here
  void clearPrefetchedRouteEstimates() {
    prefetchedPickupDistance.value = 0;
    prefetchedPickupDuration.value = 0;
    prefetchedDestinationDistance.value = 0;
    prefetchedDestinationDuration.value = 0;
    lastDriverLocationSocketAt.value = null;
    _lastGetDriverLocationEmitAt = null;
  }

  bool get isInActiveRide {
    final status = rideStatusData.value;
    if (status == null) return false;
    return status.acceptRide == true ||
        status.ongoingRide == true ||
        status.arrivingRide == true ||
        status.startRide == true;
  }

  /// Passenger car marker. Hidden after cancel so a late location packet
  /// cannot put the car back on the map.
  bool get showPassengerDriverCar {
    final status = rideStatusData.value;
    if (status?.driverCancel == true ||
        status?.passengerCancel == true ||
        status?.ride?.status == 'cancelled') {
      return false;
    }
    if (isInActiveRide || status?.completeRide == true) return true;
    final finishedAt = _lastFinishedAt;
    if (finishedAt == null) return true;
    return DateTime.now().difference(finishedAt) >= const Duration(minutes: 2);
  }

  String? get activeRideId {
    final fromStatus = rideStatusData.value?.ride?.id;
    if (fromStatus != null && fromStatus.isNotEmpty) return fromStatus;
    final fromDriverAccept = acceptedRideDriverData.value?.ride?.sId;
    if (fromDriverAccept != null && fromDriverAccept.isNotEmpty) {
      return fromDriverAccept;
    }
    return null;
  }

  void markRideFinished(String rideId) {
    if (rideId.isEmpty) return;
    _lastFinishedRideId = rideId;
    _lastFinishedAt = DateTime.now();
  }

  bool shouldIgnoreRideStatus(String? rideId) {
    if (rideId == null || rideId.isEmpty || _lastFinishedRideId == null) {
      return false;
    }
    if (_lastFinishedRideId != rideId) return false;
    final finishedAt = _lastFinishedAt;
    if (finishedAt == null) return false;
    return DateTime.now().difference(finishedAt) < const Duration(minutes: 2);
  }

  void refreshRideObservables() {
    rideStatusData.refresh();
    acceptedRideDriverData.refresh();
    acceptedRideDriverDataStatus.refresh();
    isPassengerRequest.refresh();
    rideDetailsData.refresh();
    getRideDriverLocation.refresh();
    isCompleteRideLoading.refresh();
    isRideStatusChangeLoading.refresh();
    update();
  }

  void clearRideSession() {
    stopRideLocationSync();
    unawaited(clearWaitingTimerState(rideId: activeRideId));
    final rideController = Get.find<RideController>();
    rideController.isRideAccepted.value = false;
    rideController.acceptRideModel.value = null;
    rideController.drivers.clear();
    acceptedRideDriverDataStatus.value = false;
    acceptedRideDriverData.value = null;
    isPassengerRequest.value = false;
    isCurrentMarkerShowOrNot.value = true;
    rideStatusData.value = null;
    rideRequestReceivedAt.value = null;
    rideDetailsData.value = null;
    getRideDriverLocation.value = null;
    animatedRemoteDriverPosition.value = null;
    animatedRemoteDriverSpeedMps.value = 0;
    animatedRemoteDriverHeading.value = 0;
    remoteVehiclePhase.value = 'idle';
    lastDriverLocationSocketAt.value = null;
    showCancelReasonDialog.value = false;
    clearPrefetchedRouteEstimates();
    addedFavourite.value = false;
    isTipsSuccess.value = false;
    provideTips.clear();
    userController.activeRideStatus.value = '';
    PrefsHelper.setString('status', '');
    PrefsHelper.setString('ride-accepted-data', '');
    PrefsHelper.setString('driver-status', '');
    PrefsHelper.setString('ride-accepted-driver-data', '');
    refreshRideObservables();
    rideController.isRideAccepted.refresh();
    rideController.acceptRideModel.refresh();
    rideController.update();
    userController.update();
  }

  bool get isDriverLocationSocketFresh {
    final at = lastDriverLocationSocketAt.value;
    if (at == null) return false;
    return DateTime.now().difference(at) < const Duration(seconds: 45);
  }

  void markDriverLocationSocketReceived() {
    lastDriverLocationSocketAt.value = DateTime.now();
  }

  /// Both passenger and driver emit this; backend replies on the same socket
  /// with [get-ride-driver-location].
  ///
  /// Throttled at ~2 Hz so location stays near real-time without flooding.
  void maybeEmitGetDriverLocation(String rideId) {
    if (rideId.isEmpty || !SocketServices.isConnected) return;

    final now = DateTime.now();
    if (_lastGetDriverLocationEmitAt != null &&
        now.difference(_lastGetDriverLocationEmitAt!) <
            const Duration(milliseconds: 350)) {
      return;
    }

    _lastGetDriverLocationEmitAt = now;
    SocketServices.emit('get-driver-location', {'rideId': rideId});
  }

  void stopRideLocationSync() {
    _rideLocationSyncTimer?.cancel();
    _rideLocationSyncTimer = null;
    _syncingRideId = null;
    DriverLocationService().stop();
  }

  Future<void> startRideLocationSync(String rideId) async {
    if (rideId.isEmpty) {
      stopRideLocationSync();
      return;
    }

    if (!SocketServices.isConnected) {
      debugPrint('❌ Socket not connected, skipping ride location sync');
      return;
    }

    final isDriver = userController.userModel.value?.userProfile?.role ==
        AppConstants.driver;

    if (_syncingRideId == rideId &&
        (isDriver
            ? DriverLocationService().isRunning
            : _rideLocationSyncTimer != null)) {
      maybeEmitGetDriverLocation(rideId);
      return;
    }

    stopRideLocationSync();
    _syncingRideId = rideId;

    if (isDriver) {
      DriverLocationService().startEmitting(rideId);
    } else {
      // Passenger pull cadence — backend stores coords from update-user-location
      // and returns them on get-ride-driver-location. 350ms keeps the marker
      // close to the vehicle without saturating the socket.
      _rideLocationSyncTimer = Timer.periodic(
        const Duration(milliseconds: 350),
        (_) => maybeEmitGetDriverLocation(rideId),
      );
    }

    maybeEmitGetDriverLocation(rideId);
  }

  void resumeRideLocationSyncIfNeeded() {
    final rideId = activeRideId;
    if (rideId != null && isInActiveRide) {
      startRideLocationSync(rideId);
    }
  }

  Future<void> prefetchPickupRouteEstimate() async {
    final pickupCoords =
        rideStatusData.value?.ride?.pickupLocation?.coordinates ??
            acceptedRideDriverData.value?.ride?.pickupLocation?.coordinates;
    if (pickupCoords == null || pickupCoords.length < 2) return;

    final driverLat = currentLatitudePosition?.value;
    final driverLng = currentLongitudePosition?.value;
    if (driverLat == null ||
        driverLng == null ||
        driverLat == 0 ||
        driverLng == 0) {
      return;
    }

    final metrics = await DirectionsService.getRouteMetrics(
      LatLng(driverLat, driverLng),
      LatLng(pickupCoords[1], pickupCoords[0]),
    );
    if (metrics == null) return;

    prefetchedPickupDistance.value = metrics.distanceMeters;
    prefetchedPickupDuration.value = metrics.durationSeconds;
  }

  Future<void> prefetchDestinationRouteEstimate() async {
    final destinationCoords = rideStatusData
            .value?.ride?.destinationLocation?.coordinates ??
        acceptedRideDriverData.value?.ride?.destinationLocation?.coordinates;
    if (destinationCoords == null || destinationCoords.length < 2) return;

    final driverLat = currentLatitudePosition?.value;
    final driverLng = currentLongitudePosition?.value;
    if (driverLat == null ||
        driverLng == null ||
        driverLat == 0 ||
        driverLng == 0) {
      return;
    }

    final metrics = await DirectionsService.getRouteMetrics(
      LatLng(driverLat, driverLng),
      LatLng(destinationCoords[1], destinationCoords[0]),
    );
    if (metrics == null) return;

    prefetchedDestinationDistance.value = metrics.distanceMeters;
    prefetchedDestinationDuration.value = metrics.durationSeconds;
  }

  Future<void> driverServiceFun(String rideId) async {
    await startRideLocationSync(rideId);
  }

  //  Complete Related work are here
  RxBool isCompleteRideLoading = false.obs;
  Future<bool> completeRideHandler(
    String rideId, {
    int? waitingTime,
  }) async {
    try {
      isCompleteRideLoading.value = true;
      debugPrint('🚗🏁 driver complete API start | rideId=$rideId');
      final body = <String, dynamic>{};
      if (waitingTime != null && waitingTime > 0) {
        body['waitingTime'] = waitingTime;
      }
      final response = await ApiClient.postData(
        ApiUrls.completeRideByDriver(rideId),
        body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('🚗✅ driver complete API success | body=${response.body}');
        markRideFinished(rideId);
        stopRideLocationSync();
        await clearWaitingTimerState(rideId: rideId);
        return true;
      } else {
        debugPrint(
          '🚗❌ driver complete API failed | status=${response.statusCode} body=${response.body}',
        );
        final message = response.body is Map
            ? response.body['message'] ?? 'Something went wrong'
            : 'Something went wrong';
        showSnackbar('Error', message);
        return false;
      }
    } catch (e) {
      debugPrint('🚗❌ driver complete API error → $e');
      return false;
    } finally {
      isCompleteRideLoading.value = false;
    }
  }

  @override
  void onClose() {
    stopRideLocationSync();
    _waitingClock?.cancel();
    _waitingStatusWorker?.dispose();
    provideTips.dispose();
    selectedReason.dispose();
    _rideRequestTimer?.cancel();
    super.onClose();
  }
}
