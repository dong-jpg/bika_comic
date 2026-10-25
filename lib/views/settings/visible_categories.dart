import 'package:flutter/material.dart';
import 'package:haka_comic/config/app_config.dart';

/// 所有分类
List<String> categories = [
  "排行榜",
  "留言板",
  "最近更新",
  "随机本子",
  "大家都在看",
  "大濕推薦",
  "那年今天",
  "官方都在看",
  "嗶咔漢化",
  "全彩",
  "長篇",
  "同人",
  "短篇",
  "圓神領域",
  "碧藍幻想",
  "CG雜圖",
  "英語 ENG",
  "生肉",
  "純愛",
  "百合花園",
  "後宮閃光",
  "扶他樂園",
  "耽美花園",
  "偽娘哲學",
  "單行本",
  "姐姐系",
  "妹妹系",
  "性轉換",
  "SM",
  "足の恋",
  "人妻",
  "NTR",
  "強暴",
  "非人類",
  "艦隊收藏",
  "Love Live",
  "SAO 刀劍神域",
  "Fate",
  "東方",
  "WEBTOON",
  "禁書目錄",
  "歐美",
  "Cosplay",
  "重口地帶",
];

/// 已知条目集合（含首页菜单项）
final Set<String> _knownCategories = categories.toSet();

/// 应用用户设置的可见性与顺序：
/// - 未设置（空）→ 原顺序全部展示
/// - 已设置 → 按设置顺序展示已知条目；设置页未收录的新条目（API 新增）追加在末尾
List<String> applyVisibleOrder(List<String> names) {
  final pref = AppConf().visibleCategories;
  if (pref.isEmpty) return names;
  final ordered = [for (final title in pref) if (names.contains(title)) title];
  final appended = [
    for (final name in names)
      if (!pref.contains(name) && !_knownCategories.contains(name)) name,
  ];
  return [...ordered, ...appended];
}

class VisibleCategories extends StatefulWidget {
  const VisibleCategories({super.key});

  @override
  State<VisibleCategories> createState() => _VisibleCategoriesState();
}

class _VisibleCategoriesState extends State<VisibleCategories> {
  List<String> get _pref => AppConf().visibleCategories;

  /// 展示顺序：pref 内的按 pref 顺序在前，未选中的按默认顺序在后
  List<String> _displayList() {
    final pref = _pref;
    if (pref.isEmpty) return List<String>.from(categories);
    final ordered = [
      for (final title in pref)
        if (categories.contains(title)) title,
    ];
    final hidden = [
      for (final c in categories)
        if (!pref.contains(c)) c,
    ];
    return [...ordered, ...hidden];
  }

  void _toggle(String title, bool visible) {
    final pref = List<String>.from(_pref);
    if (pref.isEmpty && !visible) {
      pref
        ..addAll(categories)
        ..remove(title);
    } else if (visible && !pref.contains(title)) {
      pref.add(title);
    } else if (!visible) {
      pref.remove(title);
    }
    setState(() => AppConf().visibleCategories = pref);
  }

  void _onReorder(int oldIndex, int newIndex) {
    final wasVisible = Set<String>.of(_pref.isEmpty ? categories : _pref);
    final list = _displayList();
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    setState(() {
      AppConf().visibleCategories = [
        for (final title in list)
          if (wasVisible.contains(title)) title,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final pref = _pref;
    final list = _displayList();
    return Scaffold(
      appBar: AppBar(title: const Text('分类管理')),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: list.length,
        onReorder: _onReorder,
        itemBuilder: (context, index) {
          final title = list[index];
          final visible = pref.isEmpty || pref.contains(title);
          return ListTile(
            key: ValueKey(title),
            leading: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
            title: Text(title),
            trailing: Switch(
              value: visible,
              onChanged: (v) => _toggle(title, v),
            ),
          );
        },
      ),
    );
  }
}
