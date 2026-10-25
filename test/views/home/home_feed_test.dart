import 'package:flutter_test/flutter_test.dart';
import 'package:haka_comic/config/app_config.dart';
import 'package:haka_comic/utils/shared_preferences_util.dart';
import 'package:haka_comic/views/home/home_feed.dart';
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
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({});
    SharedPreferencesUtil.prefsWithCache =
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(),
        );
    AppConf().visibleCategories = [];
  });

  test('最新固定第一位，其余按传入顺序', () {
    expect(
      HomeFeed.buildTabs(['全彩', '長篇']),
      ['最新', '全彩', '長篇'],
    );
  });

  test('应用用户设置的顺序并过滤隐藏项', () {
    AppConf().visibleCategories = ['長篇', '全彩'];
    expect(HomeFeed.buildTabs(['全彩', '長篇', '同人']), ['最新', '長篇', '全彩']);
  });

  test('未收录的新分类追加在末尾', () {
    AppConf().visibleCategories = ['全彩'];
    expect(
      HomeFeed.buildTabs(['全彩', '新分类']),
      ['最新', '全彩', '新分类'],
    );
  });
}
