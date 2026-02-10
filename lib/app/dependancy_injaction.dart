import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/auth/car_registration_controller.dart';
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/controllers/profile/change_password_controller.dart';
import 'package:ricardo/feature/controllers/auth/forget_password_controller.dart';
import 'package:ricardo/feature/controllers/auth/forget_password_otp_verify_controller.dart';
import 'package:ricardo/feature/controllers/auth/otp_varify_controller.dart';
import 'package:ricardo/feature/controllers/profile/profile_update_controller.dart';
import 'package:ricardo/feature/controllers/auth/reset_password_controller.dart';
import 'package:ricardo/feature/controllers/auth/sign_in_controller.dart';
import 'package:ricardo/feature/controllers/auth/sign_up_controller.dart';
import 'package:ricardo/feature/controllers/profile/reviews_ratings.dart';
import 'package:ricardo/feature/controllers/profile/support_controller.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/auth/driver_profile_controller.dart';
import 'package:ricardo/feature/controllers/auth/driving_license_controller.dart';
import 'package:ricardo/feature/controllers/profile/favourite_rides_controller.dart';
import 'package:ricardo/feature/controllers/history/history_controller.dart';
import 'package:ricardo/feature/controllers/profile/legal_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/controllers/wallet/add_card_controller.dart';
import 'package:ricardo/feature/controllers/wallet/add_money_controller.dart';
import 'package:ricardo/feature/controllers/wallet/payment_method_controller.dart';
import 'package:ricardo/feature/controllers/wallet/recent_history.dart';
import 'package:ricardo/feature/controllers/wallet/withdraw_request_controller.dart';
import 'package:ricardo/feature/models/wallet/wallet_history_model.dart';

class DependencyInjection implements Bindings {
  @override
  void dependencies() {
    Get.put(LegalController());
    Get.put(CustomBottomNavBarController());
    Get.put(DrivingLicenseController());
    Get.put(SignUpController());
    Get.put(OtpVerifyController());
    Get.put(SignInController());
    Get.put(ForgetPasswordController());
    Get.put(ForgetPasswordOtpVerifyController());
    Get.put(ResetPasswordController());
    Get.put(UserController());
    Get.put(CarRegistrationController());
    Get.lazyPut(() => DriverProfileController());
    Get.lazyPut(() => ChangePasswordController());
    Get.lazyPut(() => ProfileUpdateController());
    Get.lazyPut(() => SupportController());
    Get.lazyPut(() => FavouriteRidesController());
    Get.lazyPut(() => PaymentMethodController());
    Get.lazyPut(() => AddMoneyController());
    Get.lazyPut(() => WithdrawRequestController());
    Get.lazyPut(() => HistoryController());
    Get.lazyPut(() => ReviewsRatingsController());
    Get.lazyPut(() => RecentHistoryController());
    Get.lazyPut(() => AddCardController());
    Get.lazyPut(() => GoogleSearchLocationController());
  }
}
