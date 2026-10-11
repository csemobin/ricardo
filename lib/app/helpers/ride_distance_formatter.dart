class RideDistanceFormatter {
  static String formatDuration(int seconds) {
    if (seconds <= 0) return 'Calculating...';

    final int days = seconds ~/ 86400;
    final int hours = (seconds % 86400) ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;

    if (days > 0) {
      if (hours > 0) {
        return '$days Day${days > 1 ? 's' : ''} $hours Hr${hours > 1 ? 's' : ''}';
      }
      return '$days Day${days > 1 ? 's' : ''}';
    }

    if (hours > 0) {
      if (minutes > 0) {
        return '$hours Hr${hours > 1 ? 's' : ''} $minutes Min';
      }
      return '$hours Hr${hours > 1 ? 's' : ''}';
    }

    if (minutes > 0) {
      if (secs > 0) return '$minutes Min $secs Sec';
      return '$minutes Min';
    }

    return '$secs Sec';
  }

  static String formatDistance(int meters) {
    if (meters <= 0) return 'Calculating...';

    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} M';
    }

    final double km = meters / 1000;

    if (km < 100) {
      return '${km.toStringAsFixed(2)} KM';
    }

    return '${km.toStringAsFixed(1)} KM';
  }

  static String formatEtaLine({
    required int durationSeconds,
    required int distanceMeters,
  }) {
    if (distanceMeters <= 0 && durationSeconds <= 0) {
      return 'Calculating...';
    }

    return '( ${formatDuration(durationSeconds)}) ${formatDistance(distanceMeters)}';
  }
}
