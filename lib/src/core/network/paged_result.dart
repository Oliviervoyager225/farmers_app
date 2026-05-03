class PagedResult<T> {
  final List<T> items;
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;

  const PagedResult({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
  });

  bool get hasMore => currentPage < lastPage;
}
