import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';

void showCancelReasonSheet(
  BuildContext context, {
  required MapOPTController mapOPTController,
  required Future<void> Function() onConfirmed,
}) {
  final reasons = [
    'Passenger no show',
    'Difficult pickup location',
    'Unaccompanied minor',
    'No car seat',
    'Too many bags',
    'Other safety concern',
    'Destination changed',
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white.withOpacity(0.3),
    barrierColor: Colors.transparent,
    builder: (sheetContext) {
      String? selectedReason;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return GlassBackgroundWidget(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        mapOPTController.showCancelReasonDialog.value = false;
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Choose Reason For Cancelling',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: reasons.map(
                        (reason) {
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() => selectedReason = reason);
                              mapOPTController.selectedReason.text = reason;
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selectedReason == reason
                                            ? Colors.green
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                      color: selectedReason == reason
                                          ? Colors.green
                                          : Colors.transparent,
                                    ),
                                    child: selectedReason == reason
                                        ? const Icon(
                                            Icons.check,
                                            size: 13,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      reason,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () {
                    final isLoading =
                        mapOPTController.isRideCanceledLoader.value;

                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          disabledBackgroundColor:
                              Colors.red.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: selectedReason == null || isLoading
                            ? null
                            : () async {
                                final rideId = mapOPTController.activeRideId;
                                if (rideId == null || rideId.isEmpty) {
                                  return;
                                }

                                final success = await mapOPTController
                                    .cancelRideByDriverHandler(rideId);

                                if (!sheetContext.mounted) return;

                                if (success) {
                                  mapOPTController.showCancelReasonDialog
                                      .value = false;
                                  await onConfirmed();
                                  Navigator.pop(sheetContext);
                                  return;
                                }

                                final message = mapOPTController
                                    .cancelRideErrorMessage;
                                if (message != null && message.isNotEmpty) {
                                  ScaffoldMessenger.of(sheetContext)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor:
                                            AppColors.errorColor,
                                      ),
                                    );
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Cancel Ride',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  ).whenComplete(() {
    mapOPTController.showCancelReasonDialog.value = false;
  });
}
