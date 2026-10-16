import 'package:flutter/material.dart';
import 'package:flutter_catat_stok/core/config/extensions.dart';
import 'package:flutter_catat_stok/core/theme/app_theme.dart';

class StepperHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int indexPage;

  StepperHeaderDelegate(this.indexPage);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return AnimatedContainer(
      width: context.dw,
      height: 94,
      color: AppColors.background,
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: (shrinkOffset > 0) ? 24 : 0,
        bottom: 4,
      ),
      child: Column(
        children: [
          const Spacer(),
          Row(
            children: List<Widget>.generate(
              5,
              (index) => (index.isEven)
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: (index ~/ 2 == indexPage)
                              ? AppColors.info
                              : AppColors.borderSubtle,
                          child: Text(
                            '${(index ~/ 2) + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: (index ~/ 2 == indexPage)
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          (index ~/ 2 == 0)
                              ? 'Realisasi'
                              : (index ~/ 2 == 1)
                              ? 'Usulan'
                              : 'Ringkasan',
                          style: TextStyle(
                            fontSize: 12,
                            color:  AppColors.textPrimary,
                          ),
                        ),
                      ],
                    )
                  : const Expanded(
                      child: Divider(thickness: 1, indent: 6, endIndent: 6),
                    ),
            ),
          ),
          const Divider(thickness: 1, height: 32),
          const Spacer(),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 94;

  @override
  double get minExtent => 94;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
