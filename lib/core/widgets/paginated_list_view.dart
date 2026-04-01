import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A ListView that triggers [onFetchMore] when the user scrolls near the bottom.
///
/// Shows a loading indicator at the bottom while fetching, or an error tile
/// with retry on failure. Wraps with [RefreshIndicator] from outside.
class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? loadMoreError;
  final VoidCallback onFetchMore;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? emptyWidget;
  final EdgeInsets padding;
  final double scrollThreshold;
  final ScrollController? controller;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.isLoadingMore,
    required this.hasMore,
    this.loadMoreError,
    required this.onFetchMore,
    this.onRetry,
    required this.itemBuilder,
    this.emptyWidget,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 24),
    this.scrollThreshold = 200.0,
    this.controller,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late ScrollController _scrollController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _scrollController = widget.controller!;
    } else {
      _scrollController = ScrollController();
      _ownsController = true;
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (_ownsController) _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - widget.scrollThreshold) {
      widget.onFetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoadingMore) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    final hasFooter = widget.isLoadingMore || widget.loadMoreError != null;
    final itemCount = widget.items.length + (hasFooter ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: widget.padding,
      itemCount: itemCount,
      itemBuilder: (ctx, i) {
        if (i < widget.items.length) {
          return widget.itemBuilder(ctx, widget.items[i], i);
        }
        // Footer: loading or error
        if (widget.loadMoreError != null) {
          return _ErrorFooter(
            onRetry: widget.onRetry ?? widget.onFetchMore,
          );
        }
        return const _LoadingFooter();
      },
    );
  }
}

class _LoadingFooter extends StatelessWidget {
  const _LoadingFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.navyMid,
          ),
        ),
      ),
    );
  }
}

class _ErrorFooter extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorFooter({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.errorSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.refresh, size: 18, color: AppColors.error),
              const SizedBox(width: 6),
              Text('إعادة المحاولة', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 12,
                fontWeight: FontWeight.w700, color: AppColors.error)),
            ]),
          ),
        ),
      ),
    );
  }
}
