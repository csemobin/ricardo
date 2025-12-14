import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/gen/assets.gen.dart';

class HelperData {


  static final List<Map<String, dynamic>> onboardingData = [
    {
      "image": Assets.images.firstonbaordimage.path,
      "title": "Communication Made Simple",
      "subtitle": "Whether you're a tutor or a parent, stay connected with real-time messaging. Discuss progress, share updates, and ensure smooth communication without any hassle."
    },
    {
      "image": Assets.images.secondonbaordimagePng.path,
      "title": "Stay Organized and In Control",
      "subtitle": "Access your schedules, messages, and resources easily. Keep everything you need in one place, and stay on top of tasks with just a few taps."
    },
    {
      "image": Assets.images.thirdonbaordimagePng.path,
      "title": "Share and Access Resources",
      "subtitle": "Easily share important documents, educational materials, and updates. Both tutors and parents can access and manage resources quickly, keeping the learning process seamless."
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
