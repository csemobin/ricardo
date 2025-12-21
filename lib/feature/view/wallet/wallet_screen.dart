import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_custom_design.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodayEarningsContainer(),
          SizedBox(height: 10.h),
          _buildBalanceContainer(),
          SizedBox(height: 20.h),
          _buildActionButtons(),
          SizedBox(height: 20.h),
          Text('Recent History', style: AppCustomDesign.walletScreenTextStyle),
          Expanded(child: _buildHistoryList()),
        ],
      ),
    );
  }

  // Today's Earnings Container
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
              '\$0.00',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.appBarTitleColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  // Balance Container
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
                color: AppColors.darkColor,
                fontWeight: FontWeight.w500,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '\$12,670.90',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.whiteColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  // Action Buttons (Payment & Withdraw)
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

  // Custom Button Builder Method
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
                border: Border.all(
                  color: AppColors.greenColor,
                  width: 1.w,
                ),
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

  // History List Builder
  Widget _buildHistoryList() {
    return ListView.separated(
      itemBuilder: (context, index) => _buildListTile(index),
      separatorBuilder: (context, index) => Divider(
        color: AppColors.dividerLineColor,
        height: 1.h,
      ),
      itemCount: 10,
    );
  }

  // History List Item
  Widget _buildListTile(int index) {
    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amina S. provide you a order',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryTextColor,
                ),
              ),
              Text(
                '18 Feb 2025   10:OO AM',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.recentHistoryListTileSubtitleColor,
                ),
              )
            ],
          ),
          Text(
            '+ \$100',
            style: TextStyle(
              color: (index % 2 != 0)
                  ? AppColors.greenColor
                  : AppColors.errorColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
