import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';

class MapCustomHeaderBack extends StatefulWidget {
  const MapCustomHeaderBack({super.key, required this.rideController});

  final RideController rideController;

  @override
  State<MapCustomHeaderBack> createState() => _MapCustomHeaderBackState();
}

class _MapCustomHeaderBackState extends State<MapCustomHeaderBack> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: Obx(() {
        final userController = Get.find<UserController>();

        final user = userController.userModel.value?.userProfile;
        final profileImage =
            user?.image?.filename ?? Assets.images.profileImage.path;
        final userName = user?.name ?? 'User';
        // ✅ In your initState or wherever you load user data

        return ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.14,
              decoration: BoxDecoration(
                color: Color(0x80FFFFFF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Custom Marker Show related work are here
                          final mOTPCnt= Get.find<MapOPTController>();
                          mOTPCnt.isCurrentMarkerShow.value = true;

                          // Get all controllers
                          final rideController = Get.find<RideController>();
                          final googleSearchController =
                              Get.find<GoogleSearchLocationController>();

                          // Hide everything
                          rideController
                              .returnToNormalView(); // Sets viewInMap=false, viewInMapReturn=true
                          googleSearchController
                              .showModal(); // Sets isModalOn=false

                          // print('View in map clicked - hiding all UI elements');

                          // Optional: Force refresh the UI
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 25,
                          weight: 800,
                        ),
                      ),
                      SizedBox(
                        width: 35.w,
                      ),
                      Text(
                        'Nearby Rides (${widget.rideController.drivers.length <= 9 ? '0${widget.rideController.drivers.length}' : widget.rideController.drivers.length})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.poppins,
                            fontSize: 18.sp,
                            color: AppColors.blackColor,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  // child: Row(
                  //   children: [
                  //     IconButton(onPressed: (){
                  //       // Get all controllers
                  //       final rideController = Get.find<RideController>();
                  //       final googleSearchController = Get.find<GoogleSearchLocationController>();
                  //
                  //       // Hide everything
                  //       rideController.returnToNormalView();  // Sets viewInMap=false, viewInMapReturn=true
                  //       googleSearchController.showModal(); // Sets isModalOn=false
                  //
                  //       print('View in map clicked - hiding all UI elements');
                  //
                  //       // Optional: Force refresh the UI
                  //       setState(() {});
                  //     }, icon: Icon(Icons.arrow_back)),
                  //     Text('Nearby rides')
                  //   ],
                  // ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
