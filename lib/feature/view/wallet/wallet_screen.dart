import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/helpers/time_format.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_custom_design.dart';
import 'package:ricardo/feature/controllers/wallet/recent_history.dart';
import 'package:ricardo/feature/models/wallet/wallet_history_model.dart' hide Image;
import 'package:ricardo/feature/simmer/wallet_history_shimmer.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  // ✅ find: reuses the permanent instance from DI — never recreates
  final controller = Get.find<RecentHistoryController>();

  @override
  void initState() {
    super.initState();
    // ✅ only hits API on first visit, skips on tab switch
    controller.fetchIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        backgroundColor: AppColors.bgColor,
        title: Text(
          'Wallet',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // ✅ always fetches fresh on pull-to-refresh
          await controller.forceRefresh();
        },
        child: Obx(() {
          if (controller.isWalletLoadingStatus.value) {
            return WalletScreenShimmer(userRole: controller.userRole.value);
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.userRole.value == 'driver')
                  _buildTodayEarningsContainer(),
                SizedBox(height: 10.h),
                _buildBalanceContainer(),
                SizedBox(height: 20.h),
                if (controller.userRole.value == 'driver')
                  _buildActionButtons(),
                if (controller.userRole.value == 'passenger')
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.addAmountScreen),
                    child: Container(
                      width: double.maxFinite,
                      height: 44.h,
                      alignment: Alignment.center,
                      decoration: AppCustomDesign.linearButtonBoxDecorationDesign,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Assets.images.widrawIcon.path),
                          SizedBox(width: 6.w),
                          Text(
                            'Add Money',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 20.h),
                Text('Recent History',
                    style: AppCustomDesign.walletScreenTextStyle),
                _buildHistoryList(),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── rest of your widget methods unchanged ──────────────────────

  Widget _buildTodayEarningsContainer() {
    return Container(
      height: 63.h,
      width: double.maxFinite,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.walletNarrowBackground.path),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Today\'s Earnings',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '\$ ${controller.todayEarnings.value.toString()}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.appBarTitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceContainer() {
    return Container(
      height: 134.h,
      width: double.maxFinite,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.walletCoinBackground.path),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BALANCE',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontFamily: FontFamily.poppins,
                fontSize: 24.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '\$ ${controller.userWallet.value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCustomButton(
          iconPath: Assets.images.paymentIcon.path,
          label: 'Payment Method',
          isFilledButton: false,
          onTap: () => Get.toNamed(AppRoutes.paymentMethodsSelectionScreen),
        ),
        _buildCustomButton(
          iconPath: Assets.images.widrawIcon.path,
          label: 'Withdraw',
          isFilledButton: true,
          onTap: () => Get.toNamed(AppRoutes.withdrawRequestScreen),
        ),
      ],
    );
  }

  Widget _buildCustomButton({
    required String iconPath,
    required String label,
    required bool isFilledButton,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 167.w,
        height: 44.h,
        alignment: Alignment.center,
        decoration: isFilledButton
            ? AppCustomDesign.linearButtonBoxDecorationDesign
            : BoxDecoration(
          border: Border.all(color: AppColors.greenColor, width: 1.w),
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: isFilledButton ? Colors.white : AppColors.greenColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (controller.recentHistoryList.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40.h),
          child: const Text("No recent history found"),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final data = controller.recentHistoryList[index];
        return _buildListTile(index, data);
      },
      separatorBuilder: (context, index) => Divider(
        color: AppColors.dividerLineColor,
        height: 1.h,
      ),
      itemCount: controller.recentHistoryList.length,
      padding: const EdgeInsets.only(bottom: 80),
    );
  }

  Widget _buildListTile(int index, RecentHistory data) {
    final transaction = getTransactionDisplay(data);
    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title ?? "N/A",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryTextColor,
                ),
              ),
              Text(
                TimeFormatHelper.formatFullDateTime(data.createdAt) ?? "",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.recentHistoryListTileSubtitleColor,
                ),
              ),
            ],
          ),
          Text(
            transaction.amountText,
            style: TextStyle(
              color: transaction.color,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  TransactionDisplay getTransactionDisplay(RecentHistory data) {
    final type = data.type ?? '';
    final amount = data.amount?.toStringAsFixed(0) ?? '0';
    switch (type) {
      case 'add_money':
      case 'ride_earning':
      case 'refund':
        return TransactionDisplay(amountText: '+ \$$amount', color: AppColors.greenColor);
      case 'ride_fee':
      case 'cancel_penalty':
      case 'withdraw_approved':
        return TransactionDisplay(amountText: '- \$$amount', color: AppColors.errorColor);
      case 'withdraw_request':
        return TransactionDisplay(amountText: '~ \$$amount', color: Colors.orange);
      case 'withdraw_rejected':
        return TransactionDisplay(amountText: '+ \$$amount', color: AppColors.greenColor);
      case 'adjustment':
        final isCredit = (data.amount ?? 0) >= 0;
        return TransactionDisplay(
          amountText: isCredit ? '+ \$$amount' : '- \$$amount',
          color: isCredit ? AppColors.greenColor : AppColors.errorColor,
        );
      default:
        return TransactionDisplay(amountText: '\$$amount', color: Colors.grey);
    }
  }
}

class TransactionDisplay {
  final String amountText;
  final Color color;
  TransactionDisplay({required this.amountText, required this.color});
}