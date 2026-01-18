
import 'package:logger/logger.dart';

logger(Type type) => Logger(printer: CustomPrinter(type.toString()));

class CustomPrinter extends LogPrinter {
  final String className;
  CustomPrinter(this.className);

  // Custom mapping of log levels to custom color functions.
  final customColors = {
    Level.verbose: (String msg) => '\x1B[38;5;250m$msg\x1B[0m', // Gray
    Level.debug: (String msg) => '\x1B[38;5;39m$msg\x1B[0m',    // Blue
    Level.info: (String msg) => '\x1B[38;5;45m$msg\x1B[0m',     // Ocean Blue
    Level.warning: (String msg) => '\x1B[38;5;226m$msg\x1B[0m', // Yellow
    Level.error: (String msg) => '\x1B[38;5;196m$msg\x1B[0m',   // Red
    Level.wtf: (String msg) => '\x1B[38;5;201m$msg\x1B[0m',     // Pink
  };

  @override
  List<String> log(LogEvent event) {
    final color = customColors[event.level] ?? (msg) => msg;
    final emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    return [color('$emoji $className : ${event.message}')];
  }
}
