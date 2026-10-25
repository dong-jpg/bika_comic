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
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({});
    SharedPreferencesUtil.prefsWithCache =
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(),
        );
    AppConf().visibleCategories = [];
  });

  test('未设置时按原顺序全部返回', () {
    AppConf().visibleCategories = [];
    expect(
      applyVisibleOrder(['全彩', '長篇', '同人']),
      ['全彩', '長篇', '同人'],
    );
  });

  test('已设置时按设置顺序返回，隐藏已知条目', () {
    AppConf().visibleCategories = ['同人', '全彩'];
    // 長篇 在设置页已知列表中但未被选中 → 隐藏
    expect(
      applyVisibleOrder(['全彩', '長篇', '同人']),
      ['同人', '全彩'],
    );
  });

  test('设置未收录的新条目追加在末尾', () {
    AppConf().visibleCategories = ['全彩'];
    // 新API分类「新分类」不在设置页已知列表 → 追加
    expect(
      applyVisibleOrder(['全彩', '新分类']),
      ['全彩', '新分类'],
    );
  });

  test('设置中的多余条目（如菜单项对Tab列表）被忽略', () {
    AppConf().visibleCategories = ['排行榜', '全彩'];
    expect(applyVisibleOrder(['全彩', '同人']), ['全彩']);
  });
}
