import 'package:flutter/material.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/feature/view/home/map_screen.dart';

import '../../../services/socket_services.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var token='';
  var fcmToken='';

  void getData()async{


     token = await PrefsHelper.getString(AppConstants.bearerToken);
     fcmToken = await PrefsHelper.getString(AppConstants.fcmToken);

     print("Called data $token =============== $fcmToken");
  }


  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //    getData();
  //
  //   SocketServices.socket?.emit('user-connected', {
  //     "accessToken" : token ,
  //     "fcmToken" : fcmToken
  //   });
  // }

  @override
  Widget build(BuildContext context){
    return MapScreen();
  }
}