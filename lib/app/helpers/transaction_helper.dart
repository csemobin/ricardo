import 'package:flutter/material.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class TransactionHelper {
  // Determine the display title based on type and status
  static String getTitle({
    required String type,
    required String status,
    String? userName,
    String? customTitle,
  }) {
    if (customTitle != null && customTitle.isNotEmpty) {
      return customTitle;
    }

    final transactionType = type.toLowerCase();
    final transactionStatus = status.toLowerCase();

    switch (transactionType) {
      case 'ride_earning':
        return userName != null ? '$userName provided you an order' : 'Ride Earning';

      case 'ride_fee':
        return 'Ride Fee';

      case 'add_money':
        return 'Add Money';

      case 'withdraw_request':
        return 'Withdraw Request';

      case 'withdraw_approved':
        return 'Withdraw Approved';

      case 'withdraw_rejected':
        return 'Withdraw Rejected';

      case 'cancel_penalty':
        return 'Cancel Penalty';

      case 'refund':
        return 'Refund';

      case 'adjustment':
        return 'Adjustment';

      default:
        return 'Transaction';
    }
  }

  // Determine if amount should show as positive (credit) or negative (debit)
  static bool isCredit({
    required String type,
    required String status,
  }) {
    final transactionType = type.toLowerCase();
    final transactionStatus = status.toLowerCase();

    switch (transactionType) {
      case 'ride_earning':
        return true; // Driver earns - Credit

      case 'add_money':
        return true; // Add money - Credit

      case 'refund':
        return true; // Refund - Credit

      case 'ride_fee':
        return false; // Passenger pays - Debit

      case 'cancel_penalty':
        return false; // Penalty - Debit

      case 'withdraw_approved':
        return false; // Withdraw approved - Debit

      case 'withdraw_request':
      // Request might show as pending/neutral
        return false;

      case 'withdraw_rejected':
      // Rejected might show as neutral
        return false;

      case 'adjustment':
      // Could be positive or negative based on amount
        return true;

      default:
        return true;
    }
  }

  // Get amount display text with sign
  static String getAmountText({
    required double amount,
    required String type,
    required String status,
  }) {
    final isCreditAmount = isCredit(type: type, status: status);
    final sign = isCreditAmount ? '+' : '-';

    // Format amount to 2 decimal places
    final formattedAmount = amount.toStringAsFixed(2);
    return '$sign \$$formattedAmount';
  }

  // Get amount color
  static Color getAmountColor({
    required String type,
    required String status,
  }) {
    final isCreditAmount = isCredit(type: type, status: status);

    if (status.toLowerCase() == 'pending' ||
        status.toLowerCase() == 'processing') {
      return Color(0XffFF0000); // Yellow/Orange for pending
    }

    if (status.toLowerCase() == 'failed' ||
        status.toLowerCase() == 'rejected') {
      return AppColors.errorColor; // Red for failed
    }

    return isCreditAmount ? AppColors.greenColor : AppColors.errorColor;
  }

  // Get status display text
  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'failed':
        return 'Failed';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return AppColors.greenColor;
      case 'pending':
      case 'processing':
        return Color(0XffFF0000);
      case 'failed':
      case 'rejected':
      case 'cancelled':
        return AppColors.errorColor;
      default:
        return AppColors.secondaryTextColor;
    }
  }

  // Format date for display
  static String formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final dateTime = DateTime.parse(dateString);
      return '${_getDay(dateTime.day)} ${_getMonth(dateTime.month)} ${dateTime.year}  ${_formatTime(dateTime)}';
    } catch (e) {
      return dateString;
    }
  }

  static String _getDay(int day) {
    return day.toString();
  }

  static String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }
}