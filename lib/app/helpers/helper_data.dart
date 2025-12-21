import 'package:ricardo/gen/assets.gen.dart';

class HelperData {


  static final List<Map<String, dynamic>> onboardingData = [
    {
      "image": Assets.images.secondonbaordimagePng.path,
      "title": "Welcome to the GO GO DRIVER.",
      "subtitle": "Seamless, affordable, and reliable ride-sharing at your fingertips."
    },
    {
      "image": Assets.images.onboardone.path,
      "title": "Safe and Secure Journeys.",
      "subtitle": "Your safety is our top priority. Every ride is monitored for your peace of mind."
    },
    {
      "image": Assets.images.thirdonbaordimagePng.path,
      "title": "Easy and Convenient Booking.",
      "subtitle": "Book your ride in just a few taps. Quick, easy, and hassle-free."
    },
  ];


  /// fake data
  static final List<Map<String, dynamic>> notifications = [
    {'name': 'Annette Black', 'message': 'Match request', 'date': DateTime.now(), 'type': 'request'},
    {'name': 'Annette Black', 'message': 'Commented on your post', 'date': DateTime.now(), 'type': 'comment'},
    {'name': 'Annette Black', 'message': 'Match request', 'date': DateTime.now().subtract(Duration(days: 1)), 'type': 'request'},
  ];




  static List<Map<String, dynamic>> messages = [
    {
      'text': 'Hey, how are you?',
      'isMe': true,
      'time': DateTime.now().subtract(Duration(minutes: 5)),
      'status': 'seen',
    },
    {
      'text': 'I am good, thanks! What about you?',
      'isMe': false,
      'time': DateTime.now().subtract(Duration(minutes: 3)),
      'status': 'seen',
    },
    {
      'text': 'I am doing great, working on a new project.',
      'isMe': true,
      'time': DateTime.now().subtract(Duration(minutes: 1)),
      'status': 'seen',
    },
    {
      'text': 'That sounds interesting!',
      'isMe': false,
      'time': DateTime.now(),
      'status': 'delivered',
    },
  ];
}
