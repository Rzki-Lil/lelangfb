/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsLogoGen {
  const $AssetsLogoGen();

  /// File path: assets/logo/google.png
  AssetGenImage get google => const AssetGenImage('assets/logo/google.png');

  /// File path: assets/logo/lelang.png
  AssetGenImage get lelang => const AssetGenImage('assets/logo/lelang.png');

  /// File path: assets/logo/lelangv2.png
  AssetGenImage get lelangv2 => const AssetGenImage('assets/logo/lelangv2.png');

  /// File path: assets/logo/logo_auction.png
  AssetGenImage get logoAuction =>
      const AssetGenImage('assets/logo/logo_auction.png');

  /// File path: assets/logo/logo_lifestyle.png
  AssetGenImage get logoLifestyle =>
      const AssetGenImage('assets/logo/logo_lifestyle.png');

  /// File path: assets/logo/logo_mobil.png
  AssetGenImage get logoMobil =>
      const AssetGenImage('assets/logo/logo_mobil.png');

  /// File path: assets/logo/logo_motor.png
  AssetGenImage get logoMotor =>
      const AssetGenImage('assets/logo/logo_motor.png');

  /// File path: assets/logo/logo_unpak.png
  AssetGenImage get logoUnpak =>
      const AssetGenImage('assets/logo/logo_unpak.png');

  /// File path: assets/logo/mobil.png
  AssetGenImage get mobil => const AssetGenImage('assets/logo/mobil.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        google,
        lelang,
        lelangv2,
        logoAuction,
        logoLifestyle,
        logoMobil,
        logoMotor,
        logoUnpak,
        mobil
      ];
}

class $AssetsSvgGen {
  const $AssetsSvgGen();

  /// File path: assets/svg/logo_lelang.svg
  SvgGenImage get logoLelang => const SvgGenImage('assets/svg/logo_lelang.svg');

  /// File path: assets/svg/logo_lelang_v2.svg
  SvgGenImage get logoLelangV2 =>
      const SvgGenImage('assets/svg/logo_lelang_v2.svg');

  /// File path: assets/svg/logo_mobil.svg
  SvgGenImage get logoMobil => const SvgGenImage('assets/svg/logo_mobil.svg');

  /// File path: assets/svg/logo_motor.svg
  SvgGenImage get logoMotor => const SvgGenImage('assets/svg/logo_motor.svg');

  /// File path: assets/svg/logo_unpak.svg
  SvgGenImage get logoUnpak => const SvgGenImage('assets/svg/logo_unpak.svg');

  /// File path: assets/svg/logo_white.svg
  SvgGenImage get logoWhite => const SvgGenImage('assets/svg/logo_white.svg');

  /// List of all assets
  List<SvgGenImage> get values =>
      [logoLelang, logoLelangV2, logoMobil, logoMotor, logoUnpak, logoWhite];
}

class Assets {
  Assets._();

  static const $AssetsLogoGen logo = $AssetsLogoGen();
  static const $AssetsSvgGen svg = $AssetsSvgGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

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
    FilterQuality filterQuality = FilterQuality.low,
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

class SvgGenImage {
  const SvgGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = false;

  const SvgGenImage.vec(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
