// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/inter_regular.ttf
  String get interRegular => 'assets/fonts/inter_regular.ttf';

  /// List of all assets
  List<String> get values => [interRegular];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/button.svg
  String get button => 'assets/icons/button.svg';

  /// File path: assets/icons/logo.svg
  String get logo => 'assets/icons/logo.svg';

  /// File path: assets/icons/sortLogo.png
  AssetGenImage get sortLogo =>
      const AssetGenImage('assets/icons/sortLogo.png');

  /// List of all assets
  List<dynamic> get values => [button, logo, sortLogo];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/amico.png
  AssetGenImage get amico => const AssetGenImage('assets/images/amico.png');

  /// File path: assets/images/applogo.png
  AssetGenImage get applogo => const AssetGenImage('assets/images/applogo.png');

  /// File path: assets/images/cuate.png
  AssetGenImage get cuate => const AssetGenImage('assets/images/cuate.png');

  /// File path: assets/images/driver.png
  AssetGenImage get driver => const AssetGenImage('assets/images/driver.png');

  /// File path: assets/images/firstonbaordimage.png
  AssetGenImage get firstonbaordimage =>
      const AssetGenImage('assets/images/firstonbaordimage.png');

  /// File path: assets/images/onboardingthree.jpg
  AssetGenImage get onboardingthree =>
      const AssetGenImage('assets/images/onboardingthree.jpg');

  /// File path: assets/images/onboardone.jpg
  AssetGenImage get onboardone =>
      const AssetGenImage('assets/images/onboardone.jpg');

  /// File path: assets/images/onboardtwo.jpg
  AssetGenImage get onboardtwo =>
      const AssetGenImage('assets/images/onboardtwo.jpg');

  /// File path: assets/images/passenger.png
  AssetGenImage get passenger =>
      const AssetGenImage('assets/images/passenger.png');

  /// File path: assets/images/rafiki.png
  AssetGenImage get rafiki => const AssetGenImage('assets/images/rafiki.png');

  /// File path: assets/images/secondonbaordimage.png.png
  AssetGenImage get secondonbaordimagePng =>
      const AssetGenImage('assets/images/secondonbaordimage.png.png');

  /// File path: assets/images/splash_background.jpg
  AssetGenImage get splashBackground =>
      const AssetGenImage('assets/images/splash_background.jpg');

  /// File path: assets/images/splash_screen_background.jpg
  AssetGenImage get splashScreenBackground =>
      const AssetGenImage('assets/images/splash_screen_background.jpg');

  /// File path: assets/images/thirdonbaordimage.png.png
  AssetGenImage get thirdonbaordimagePng =>
      const AssetGenImage('assets/images/thirdonbaordimage.png.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        amico,
        applogo,
        cuate,
        driver,
        firstonbaordimage,
        onboardingthree,
        onboardone,
        onboardtwo,
        passenger,
        rafiki,
        secondonbaordimagePng,
        splashBackground,
        splashScreenBackground,
        thirdonbaordimagePng
      ];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
