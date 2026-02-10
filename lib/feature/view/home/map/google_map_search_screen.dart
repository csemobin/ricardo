/*
// Updated GoogleMapsSearchScreen
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// import '../../../../controllers/google_map_controller/google_map_controller.dart';
// import '../../../../controllers/google_map_controller/map_search_controller.dart';
// import '../../../widgets/custom_text.dart';
// import '../../../widgets/dummy_widget.dart';
// import '../../../widgets/text_field_widget.dart';

class GoogleMapsSearchScreen extends StatefulWidget {
  const GoogleMapsSearchScreen({
    super.key,
    required this.textEditingController,
    this.isStartLocation = true,
    this.onLocationSelected,
  });

  final TextEditingController textEditingController;
  final bool isStartLocation;
  final Function(LatLng)? onLocationSelected;

  @override
  State<GoogleMapsSearchScreen> createState() => _GoogleMapsSearchScreenState();
}

class _GoogleMapsSearchScreenState extends State<GoogleMapsSearchScreen> {
  final MapSearchController _mapSearchController = Get.find<MapSearchController>();
  final GoogleMapScreenController _placesController = Get.find<GoogleMapScreenController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mapSearchController.listenCurrentLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isStartLocation && _mapSearchController.startLocation != null) {
        _mapSearchController.updateCameraPosition(_mapSearchController.startLocation!);
      } else if (!widget.isStartLocation && _mapSearchController.endLocation != null) {
        _mapSearchController.updateCameraPosition(_mapSearchController.endLocation!);
      }
    });
  }

  Future<void> _fetchPlaceDetails(String placeId) async {
    try {
      final details = await _placesController.getPlacesDetails(placeId);
      if (details.status == 'OK') {
        final location = details.result.geometry!.location;
        final latLng = LatLng(location.lat, location.lng);

        // Use map search controller for map operations
        _mapSearchController.updateCameraPosition(latLng);
        _mapSearchController.addMarker(
          latLng,
          title: details.result.name ?? 'Selected Location',
          isStartLocation: widget.isStartLocation,
        );

        widget.textEditingController.text = details.result.formattedAddress ?? '';

        // Call the callback if provided
        if (widget.onLocationSelected != null) {
          widget.onLocationSelected!(latLng);
        }

        // Close both bottom sheet and the entire screen, returning coordinates
        Navigator.of(context).pop(); // Close bottom sheet
        Get.back(result: latLng); // Close entire screen and return coordinates
      }
    } catch (e) {
      debugPrint("Error getting place details: $e");
    }
  }



  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, size: 24.sp),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomText(
                        text: 'Search Location',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Search field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: TextFieldWidget(
                  controller: _searchController,
                  hintText: 'Enter location name...',
                  maxLine: 1,
                  autoFocus: true,
                  // prefixIcon: Icon(Icons.search, color: Colors.grey, size: 24.sp),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _placesController.clearSearch();
                    },
                  )
                      : null,
                  onChange: (value) {
                    _mapSearchController.debouncedSearch(
                      value,
                      _placesController.searchPlaces,
                    );
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // Search results
              Expanded(
                child: GetBuilder<GoogleMapScreenController>(
                  builder: (controller) {
                    if (controller.isLoading) {
                      return _buildLoadingState();
                    }

                    if (_searchController.text.isEmpty) {
                      return _buildEmptyState(
                        'Start typing to search locations',
                      );
                    }

                    if (controller.predictions.isEmpty) {
                      return _buildEmptyState(
                        'No results found for "${_searchController.text}"',
                      );
                    }

                    return _buildSearchResults(controller);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2.w,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 16.h),
          CustomText(text: 'Searching...', fontSize: 16.sp, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: CustomText(
              text: message,
              fontSize: 16.sp,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(GoogleMapScreenController controller) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: controller.predictions.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1.h, thickness: 0.5),
      itemBuilder: (context, index) {
        final prediction = controller.predictions[index];
        return _buildLocationTile(prediction);
      },
    );
  }

  Widget _buildLocationTile(dynamic prediction) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (prediction.placeId != null) {
            _fetchPlaceDetails(prediction.placeId!);
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: Colors.blue,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text:
                      prediction.structuredFormatting?.mainText ??
                          prediction.description ??
                          'Unknown location',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      maxline: 1,
                      textOverflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,

                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      text:
                      prediction.structuredFormatting?.secondaryText ??
                          prediction.description ??
                          '',
                      fontSize: 14.sp,
                      color: Colors.grey,
                      maxline: 2,
                      textOverflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
        actions: [
          CustomButton(
            label: 'Done',
            onPressed: () => Get.back(),
            width: 70.w,
            height: 40.h,
            fontSize: 16.sp,
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: GetBuilder<MapSearchController>(
        builder: (mapController) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(23.8041, 90.4152),
                  zoom: 16,
                ),
                onMapCreated: (GoogleMapController controller) {
                  mapController.setMapController(controller);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mapController.markers.isNotEmpty) {
                      mapController.fitMarkersInView();
                    }
                  });
                },
                markers: mapController.markers,
                polylines: mapController.polylines,
                */
/*   onTap: (LatLng position) {
                  mapController.addMarker(
                    position,
                    title: 'Selected Location',
                    isStartLocation: widget.isStartLocation,
                  );

                  if (widget.onLocationSelected != null) {
                    widget.onLocationSelected!(position);
                  }
                },*//*

              ),
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  children: [
                    TextFieldWidget(
                      controller: widget.textEditingController,
                      readOnly: true,
                      hintText: 'Search Location',
                      maxLine: 1,
                      onTap: _showSearchBottomSheet,
                    ),

                    // Add a button to show pit stops info (optional)
                    if (mapController.pitStopPositions.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8.r,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: Colors.orange,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            CustomText(
                              text: '${mapController.pitStopPositions.length} pit stops',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapSearchController.getCurrentLocation(),
        child: const Icon(Icons.location_on_outlined),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapSearchController.clearDebounce();
    super.dispose();
  }
}
*/


