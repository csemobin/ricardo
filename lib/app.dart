import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/routes/app_routes.dart';

class RideSharingApplication extends StatelessWidget{
  const RideSharingApplication({super.key});
  @override
  Widget build(BuildContext context){
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_,child){
        return GetMaterialApp(
          initialRoute: AppRoutes.initialRoute,
          routes: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}