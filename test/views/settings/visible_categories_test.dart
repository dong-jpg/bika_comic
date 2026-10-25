import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haka_comic/config/app_config.dart';
import 'package:haka_comic/utils/shared_preferences_util.dart';
import 'package:haka_comic/views/settings/visible_categories.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({
      'visibleCategories': ['排行榜'],
    });
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          'visibleCategories': ['排行榜'],
        });
    SharedPreferencesUtil.prefsWithCache =
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(),
        );
    AppConf().visibleCategories = ['排行榜'];
  });

  testWidgets('渲染为可拖动排序列表，每行带开关', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VisibleCategories()));
    await tester.pump();

    expect(find.byType(ReorderableListView), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);
    expect(find.text('排行榜'), findsOneWidget);

    // 排行榜在 pref 中 → 开
    final sw =
        tester.widget<ListTile>(find.widgetWithText(ListTile, '排行榜')).trailing
            as Switch;
    expect(sw.value, isTrue);
  });

  testWidgets('关闭开关从 pref 移除，打开开关加入 pref', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VisibleCategories()));
    await tester.pump();

    // 全彩 不在 pref → 关；点开 → 加入
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, '全彩'),
        matching: find.byType(Switch),
      ),
    );
    await tester.pump();
    expect(AppConf().visibleCategories, contains('全彩'));

    // 再关掉 → 移除
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, '全彩'),
        matching: find.byType(Switch),
      ),
    );
    await tester.pump();
    expect(AppConf().visibleCategories, isNot(contains('全彩')));
  });

  testWidgets('长按拖动改变 pref 顺序', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VisibleCategories()));
    await tester.pump(const Duration(milliseconds: 300));

    // pref=['排行榜']，全彩为隐藏区第一条；把排行榜拖到全彩下方
    final handle = find.byIcon(Icons.drag_handle).first;
    final start = tester.getCenter(handle);
    final target = tester.getCenter(find.text('全彩'));

    final gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 400));
    await gesture.moveBy(Offset(0, target.dy - start.dy + 40));
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();

    final pref = AppConf().visibleCategories;
    expect(pref, contains('排行榜'));
    expect(pref.length, greaterThanOrEqualTo(1));
  });
}
