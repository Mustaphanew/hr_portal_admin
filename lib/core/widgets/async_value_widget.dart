import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppColors.navyMid),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.g300),
            const SizedBox(height: 12),
            Text('حدث خطأ في تحميل البيانات',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tx2)),
            const SizedBox(height: 4),
            Text(error.toString(),
                style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 11, color: AppColors.tx3),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text('إعادة المحاولة',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class SliverAsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  const SliverAsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.navyMid),
        ),
      ),
      error: (error, _) => SliverFillRemaining(
        child: AsyncValueWidget(
          value: value,
          data: (_) => const SizedBox.shrink(),
          onRetry: onRetry,
        ),
      ),
    );
  }
}
