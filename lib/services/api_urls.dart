class ApiUrls{
  // Base, Image, Socket
  // static const String baseUrl = "https://zsv1pz87-5000.inc1.devtunnels.ms/api/v1";

  // static const String baseUrl = "https://api.gogodriver.us/api/v1";
  // static const String imageBaseUrl = "https://api.gogodriver.us/images/";
  // static const String socketUrl = "https://api.gogodriver.us";

  static const String baseUrl = "https://withdrawal-berry-everything-spring.trycloudflare.com/api/v1";
  static const String imageBaseUrl = "https://withdrawal-berry-everything-spring.trycloudflare.com/images/";
  static const String socketUrl = "https://withdrawal-berry-everything-spring.trycloudflare.com";

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
  static const String authLogOut = '/auth/logout';
  static const String getMe = '/user/me';
  static const String createUserProfile = '/user/update-user';
  static const String changePassword = '/auth/change-password';
  static const String updateProfile = '/user/update-user';

  //License Related work are here
  static const String registrationLicense = '/registration/license';
  static const String registrationVehicle = '/registration/vehicle';

  // Privacy Policy - Terms & Condition - About us
  static String legalContent(String url) => '/$url';
  static const String support = '/setting/support';

  // Favourite Rides
  static const String favouriteRides = '/favorite-rider';
  static String favouriteRiderDelete( String rideId ) => '/favorite-rider/$rideId';

  // Wallet Related work are here
  static const String paymentCardInfo = '/payment-card/get-all-card-info';
  static String paymentCardDelete(String cardId) => '/payment-card/delete-card-info?cardId=$cardId';
  static String paymentRecentHistory( int page, int len ) => '/payment/recent-transactions?page=$page&limit=$len';
  static String paymentCardStore = '/payment-card/store-card-info';

  // Payment Related work are here
  static const String addBalance = '/payment/add-balance';
  static const String withdrawRequest = '/payment/withdraw-request';

  // Ride History
  static const String rideHistory = '/ride/get-complete-ride-history';

  //Driver Rating
  static const String driverGetRating = '/driver/get-ratings';

  //Booked a Ride
  static const String rideBookRide = '/ride/book-ride';
  static String requestAreaRider(String id ) => '/ride/request-area-rider?rideId=$id';
  static String sendPickUpRequest( String riderId, String driverId) => '/ride/send-pick-request?rideId=$riderId&driverId=$driverId';
  static String cancelRequest( String riderId, String driverId) => '/ride/cancel-pick-request?rideId=$riderId&driverId=$driverId';

  //Notification
  static String notification( int limit, int page ) =>'/notification?limit=$limit&page=$page';

  static String driverSwitchAvailabilityStatus = '/driver/switch-availability-status';
  static String rideAcceptRideByRideId( String rideId ) => '/ride/accept-ride?rideId=$rideId';
  static const String sendTips = '/payment/send-tips';
  static const String favoriteRider = '/favorite-rider';
  static const String ratingCreate = '/rating/create';
}