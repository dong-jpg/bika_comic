import 'package:flutter/material.dart';
import 'package:haka_comic/mixin/pagination.dart';
import 'package:haka_comic/network/http.dart';
import 'package:haka_comic/network/models.dart';
import 'package:haka_comic/providers/block_provider.dart';
import 'package:haka_comic/utils/log.dart';
import 'package:haka_comic/utils/request/request.dart';
import 'package:haka_comic/views/comics/common_pagination_footer.dart';
import 'package:haka_comic/views/comics/common_tmi_list.dart';
import 'package:haka_comic/views/comics/page_selector.dart';
import 'package:haka_comic/widgets/error_page.dart';

/// 首页单个分类的漫画列表页；[category] 为 null 表示「最新」
class CategoryComicsTab extends StatefulWidget {
  const CategoryComicsTab({
    super.key,
    required this.category,
    required this.sortType,
  });

  final String? category;

  final ComicSortType sortType;

  @override
  State<CategoryComicsTab> createState() => _CategoryComicsTabState();
}

class _CategoryComicsTabState extends State<CategoryComicsTab>
    with RequestMixin, PaginationMixin, AutomaticKeepAliveClientMixin {
  int page = 1;

  ComicsPayload _payload(ComicSortType sortType, int page) => ComicsPayload(
    c: widget.category,
    s: sortType,
    page: page,
  );

  late final handler = fetchComics.useRequest(
    defaultParams: _payload(widget.sortType, page),
    onSuccess: (data, _) => Log.i('Fetch comics success', data.toString()),
    onError: (e, _) => Log.e('Fetch comics failed', error: e),
    reducer:
        pagination
            ? null
            : (prev, current) {
              if (prev == null) return current;
              return current.copyWith.comics(
                docs: [...prev.comics.docs, ...current.comics.docs],
              );
            },
  );

  @override
  List<RequestHandler> registerHandler() => [handler];

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadMore() async {
    final pages = handler.state.data?.comics.pages ?? 1;
    if (page >= pages) return;
    await _onPageChange(page + 1);
  }

  Future<void> _onPageChange(int value) async {
    setState(() => page = value);
    await handler.run(_payload(widget.sortType, value));
  }

  @override
  void didUpdateWidget(CategoryComicsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sortType != widget.sortType) {
      setState(() => page = 1);
      handler.mutate(ComicsResponse.empty);
      handler.run(_payload(widget.sortType, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return switch (handler.state) {
      RequestState(:final data) when data != null => CommonTMIList(
        controller: pagination ? null : scrollController,
        comics: context.filtered(data.comics.docs),
        pageSelectorBuilder:
            pagination
                ? (context) => PageSelector(
                  pages: data.comics.pages,
                  onPageChange: _onPageChange,
                  currentPage: page,
                )
                : null,
        footerBuilder:
            pagination
                ? null
                : (context) =>
                    CommonPaginationFooter(loading: handler.state.loading),
      ),
      Error(:final error) => ErrorPage(
        errorMessage: error.toString(),
        onRetry: handler.refresh,
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
