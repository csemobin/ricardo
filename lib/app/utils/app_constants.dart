class AppConstants{
  static const String bearerToken = "bearerToken";
  static const String isEmailVerified = "isEmailVerified";
  static const String profilePicture = "profilePicture";
  static const String completed = "completed";
  static const String email = "email";
  static const String phone = "phone";
  static const String name = "name";
  static const String image = "image";
  static const String role = "role";
  static const String userId = "userId";
  static const String userActive = "userActive";
  static const String bio = "bio";
  static const String isLogged = "isLogged";
  static const String managerType = "managerType";
  static const String fcmToken = "fcmToken";


  static RegExp emailValidate = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static bool validatePassword(String value) {
    RegExp regex = RegExp(r'^(?=.*[0-9])(?=.*[a-zA-Z]).{6,}$');
    return regex.hasMatch(value);
  }



}