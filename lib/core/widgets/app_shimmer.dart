import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape shape;

  const AppShimmer({
    super.key,
    this.width = 50,
    this.height = 50,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  factory AppShimmer.rectangle({
    required double width,
    required double height,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(8),
    ),
  }) {
    return AppShimmer(width: width, height: height, borderRadius: borderRadius);
  }

  factory AppShimmer.circle({required double width, required double height}) {
    return AppShimmer(width: width, height: height, shape: BoxShape.circle);
  }

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: widget.borderRadius,
          shape: widget.shape,
        ),
      ),
    );
  }
}
