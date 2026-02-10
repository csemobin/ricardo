import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/models/home/place_suggestion.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/services/location_permission_service.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';
import 'package:ricardo/widgets/location_permission_dialog.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final controller = Get.put(GoogleSearchLocationController());
  final FocusNode _pickupFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkLocationBeforeSearch();
  }

  @override
  void dispose() {
    _pickupFocusNode.dispose();  // ✅ FIXED: Dispose here instead
    super.dispose();
  }

  Future<void> _checkLocationBeforeSearch() async {
    final status = await LocationPermissionService.checkAndRequestLocation();

    if (status != LocationStatus.granted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LocationPermissionDialog(status: status),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: Text(
          "Let's Go...",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.poppins,
          ),
        ),
        forceMaterialTransparency: true,
        backgroundColor: AppColors.bgColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 27.h),

            CustomTextField(
              focusNode: _pickupFocusNode,
              controller: controller.pickUpLocation,
              labelText: 'Set Pick-up Location',
              prefixIcon: Image.asset(Assets.images.greenPin.path),
              hintText: 'Enter Pick-up Location',
            ),

            _buildSuggestionsList(
              controller.pickupSuggestions,
              controller.isLoadingPickup,
                  (suggestion) {
                controller.selectPickupLocation(suggestion);
                _pickupFocusNode.unfocus();  // ✅ Close keyboard
              },
            ),

            SizedBox(height: 65),

            CustomPrimaryButton(
              onHandler: () async {
                final status = await LocationPermissionService.checkAndRequestLocation();

                if (status != LocationStatus.granted) {
                  showDialog(
                    context: context,
                    builder: (context) => LocationPermissionDialog(status: status),
                  );
                  return;
                }

                if (controller.selectedPickup.value != null) {
                  // Handle find ride
                  print('Selected Location: ${controller.selectedPickup.value?.address}');
                } else {
                  Get.snackbar('Error', 'Please select a location');
                }
              },
              title: 'Find Ride',
            ),
          ],
        ),
      ),
    );
  }

  // Build Suggestion list widget
  Widget _buildSuggestionsList(
      RxList<PlaceSuggestion> suggestions,
      RxBool isLoading,
      Function(PlaceSuggestion) onSelect,
      ) {
    return Obx(() {
      if (isLoading.value) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (suggestions.isEmpty) {
        return SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          separatorBuilder: (context, index) => Divider(height: 1),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              leading: Icon(Icons.location_on, color: AppColors.greenColor),
              title: Text(
                suggestion.mainText,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
              subtitle: Text(
                suggestion.secondaryText,
                style: TextStyle(fontSize: 12.sp),
              ),
              onTap: () => onSelect(suggestion),
            );
          },
        ),
      );
    });
  }
}