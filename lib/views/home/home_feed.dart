import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haka_comic/network/http.dart';
import 'package:haka_comic/network/models.dart';
import 'package:haka_comic/router/route_observer.dart';
import 'package:haka_comic/utils/log.dart';
import 'package:haka_comic/utils/request/request.dart';
import 'package:haka_comic/utils/ui.dart';
import 'package:haka_comic/views/comics/sort_type_selector.dart';
import 'package:haka_comic/views/home/category_comics_tab.dart';
import 'package:haka_comic/views/settings/visible_categories.dart';
import 'package:haka_comic/widgets/error_page.dart';

/// 首页：顶部分类 Tab + 每分类一页封面网格
class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();

  /// Tab 列表 = [最新] + 应用用户顺序后的分类，纯函数便于测试
  static List<String> buildTabs(List<String> categoryTitles) =>
      [latestTab, ...applyVisibleOrder(categoryTitles)];

  static const String latestTab = '最新';
}

class _HomeFeedState extends State<HomeFeed>
    with RequestMixin, SingleTickerProviderStateMixin, RouteAware {
  late final handler = fetchCategories.useRequest(
    onSuccess: (data) => Log.i('Fetch categories success', data.toString()),
    onError: (e) => Log.e('Fetch categories failed', error: e),
  );

  TabController? _tabController;
  final Map<String, ComicSortType> _sortTypes = {};

  @override
  List<RequestHandler> registerHandler() => [handler];

  /// Tab 数量变化时重建 controller（新实例 index 从 0 开始，天然合法）；
  /// 旧 controller 延迟到帧末 dispose，避免在 build 中释放正在使用的实例
  void _syncController(int length) {
    final old = _tabController;
    if (old?.length == length) return;
    _tabController = TabController(length: length, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  ComicSortType _sortOf(String tab) => _sortTypes[tab] ?? ComicSortType.dd;

  void _showSortSelector(BuildContext context, List<String> tabs) {
    final controller = _tabController;
    if (controller == null) return;
    final tab = tabs[controller.index.clamp(0, tabs.length - 1)];
    showDialog(
      context: context,
      builder: (context) => SortTypeSelector(
        sortType: _sortOf(tab),
        onSortTypeChange: (type) => setState(() => _sortTypes[tab] = type),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  // 从设置页返回后，Tab 顺序可能已变化
  @override
  void didPopNext() {
    if (handler.state is Success) setState(() {});
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (handler.state) {
      Success(:final data) => Builder(
        builder: (context) {
          final tabs = HomeFeed.buildTabs([
            for (final category in data.categories) category.title,
          ]);
          _syncController(tabs.length);

          return Scaffold(
            appBar: AppBar(
              title: const Text('首页'),
              actions: [
                IconButton(
                  onPressed: () => context.push('/categories'),
                  icon: const Icon(Icons.grid_view_rounded),
                  tooltip: '全部分类',
                ),
                if (UiMode.m1(context)) ...[
                  IconButton(
                    onPressed: () => context.push('/search'),
                    icon: const Icon(Icons.search),
                    tooltip: '搜索',
                  ),
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(Icons.notifications),
                    tooltip: '通知',
                  ),
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: const Icon(Icons.settings),
                    tooltip: '设置',
                  ),
                ],
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kTextTabBarHeight),
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: [for (final tab in tabs) Tab(text: tab)],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showSortSelector(context, tabs),
                      icon: const Icon(Icons.sort),
                      tooltip: '排序',
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                for (final tab in tabs)
                  CategoryComicsTab(
                    key: ValueKey(tab),
                    category: tab == HomeFeed.latestTab ? null : tab,
                    sortType: _sortOf(tab),
                  ),
              ],
            ),
          );
        },
      ),
      Error(:final error) => Scaffold(
        appBar: AppBar(title: const Text('首页')),
        body: ErrorPage(
          errorMessage: error.toString(),
          onRetry: handler.refresh,
        ),
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}
