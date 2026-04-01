import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/pagination.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PAGINATED RESPONSE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PaginatedResponse<T> {
  final List<T> items;
  final Pagination? pagination;
  const PaginatedResponse({required this.items, this.pagination});
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PAGINATED STATE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@immutable
class PaginatedState<T> {
  final List<T> items;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;

  const PaginatedState({
    required this.items,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  PaginatedState<T> copyWith({
    List<T>? items,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError,
    bool clearError = false,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearError ? null : (loadMoreError ?? this.loadMoreError),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PAGINATED NOTIFIER (base class)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

typedef FetchPage<T> = Future<PaginatedResponse<T>> Function(int page, int perPage);

abstract class PaginatedNotifier<T> extends AsyncNotifier<PaginatedState<T>> {
  int get perPage => 50;

  /// Subclasses implement this to provide the actual fetch logic.
  FetchPage<T> get fetchPage;

  @override
  Future<PaginatedState<T>> build() async {
    final result = await fetchPage(1, perPage);
    return PaginatedState<T>(
      items: result.items,
      currentPage: 1,
      hasMore: result.pagination?.hasNextPage ?? false,
    );
  }

  /// Load next page. Safe to call multiple times — guards against concurrent fetches.
  Future<void> fetchMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true, clearError: true));

    try {
      final nextPage = current.currentPage + 1;
      final result = await fetchPage(nextPage, perPage);
      state = AsyncData(PaginatedState<T>(
        items: [...current.items, ...result.items],
        currentPage: nextPage,
        hasMore: result.pagination?.hasNextPage ?? false,
      ));
    } catch (e) {
      state = AsyncData(current.copyWith(isLoadingMore: false, loadMoreError: e));
    }
  }
}
