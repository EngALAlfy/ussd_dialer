import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LicenseProvider extends ChangeNotifier{
  bool isLicense = true;
  bool isLoaded = true;

  getAppStatus() async {
    // try{
    //   Response response = await Dio().get("https://apps-status.arconnecthost.com/?app=com.alalfy.ussd_dialer");
    //   if(response.statusCode == 200){
    //     if(response.data["success"] == true){
    //       if(response.data["status"] == 1){
    //         isLicense = true;
    //       }else{
    //         isLicense = false;
    //       }
    //     }else{
    //       isLicense = false;
    //     }
    //   }
    //   print(response);
    //
    // }catch(e){
    //   EasyLoading.showError(e.toString());
    //   isLicense = false;
    // }

   //  isLoaded = true;
   //
   // notifyListeners();
  }
}