class ApiUrls{
  // Base, Image, Socket
  // static const String baseUrl = "https://zsv1pz87-5000.inc1.devtunnels.ms/api/v1";
  static const String baseUrl = "https://desert-attacks-midlands-hawaiian.trycloudflare.com/api/v1";

  static const String imageBaseUrl = "https://zsv1pz87-5000.inc1.devtunnels.ms";

  static const String socketUrl = "https://zsv1pz87-5000.inc1.devtunnels.ms";

  // User Registration Related work
  static const String registration = '/user/register';
  static const String otpSendVerification = '/otp/send/verification';
  static const String otpVerifyVerification = '/otp/verify/verification';

  //Forget Password Related work
  static const String otpSendForgotPassword = '/otp/send/forgot-password';
  static const String otpVerifyForgotPassword = '/otp/verify/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  // log in related work are here
  static const String authLogin = '/auth/login';
  static const String getMe = '/user/me';
  static const String createUserProfile = '/user/update-user';

  //License Related work are here
  static const String registrationLicense = '/registration/license';
  static const String registrationVehicle = '/registration/vehicle';



  static const String forgetPassword = '/otp/send/forgot-password';
}