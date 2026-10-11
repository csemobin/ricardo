import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/app/helpers/snackbar_helper.dart';

class ReportController extends GetxController{
  final TextEditingController txController = TextEditingController();
  RxInt radioBtnValue = 0.obs;

  RxBool isReportStatus = false.obs;

  static const int otherReason = 5;

  static const Map<int, String> _reasonLabels = {
    1: 'Safety Issues',
    2: 'Behavior Issues',
    3: 'Trip Issues',
    4: 'Vehicle Issues',
  };

  /// The radio label for options 1-4; the typed note for "Other". The text
  /// field only exists for "Other", so every other option must send its label.
  String get reportText => radioBtnValue.value == otherReason
      ? txController.text.trim()
      : (_reasonLabels[radioBtnValue.value] ?? '');

  Future<bool> reportButtonHandler(String rideId ) async {
    if( rideId.isEmpty ) return false;

    final String report = reportText;
    if( report.isEmpty ){
      showSnackbar(
        'Error',
        radioBtnValue.value == otherReason
            ? 'Please describe your issue'
            : 'Please select a reason',
      );
      return false;
    }

    try{
      isReportStatus.value = true;
      final response = await ApiClient.postData(ApiUrls.reportRideByPassenger,
          {
            "rideId": rideId,
            "report": report,
          });
      if( response.statusCode == 200 || response.statusCode == 201 ){
        return true;
      }
      showSnackbar('Error', response.body['message']);
      return false;
    }catch(e){
      debugPrint(e.toString());
      return false;
    }finally{
      isReportStatus.value = false;
    }
  }

  @override
  void onClose() {
    txController.dispose();
    super.onClose();
  }

}