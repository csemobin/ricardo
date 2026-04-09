import 'package:flutter/material.dart';
import 'package:ricardo/app/dependancy_injaction.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';

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
          initialBinding: DependencyInjection(),
          theme: ThemeData(
            fontFamily: FontFamily.poppins
          ),
        );
      },
    );
  }
}