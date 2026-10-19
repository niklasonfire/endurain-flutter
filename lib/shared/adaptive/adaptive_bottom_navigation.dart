import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:endurain/core/constants/ui_constants.dart';
import 'package:endurain/core/utils/platform_utils.dart';

class AdaptiveTab {
  const AdaptiveTab({
    required this.routeName,
    required this.label,
    required this.materialIcon,
    required this.cupertinoIcon,
    required this.builder,
  });

  final String routeName;
  final String label;
  final IconData materialIcon;
  final IconData cupertinoIcon;
  final WidgetBuilder builder;
}

class AdaptiveBottomNavigation extends StatefulWidget {
  const AdaptiveBottomNavigation({
    super.key,
    required this.tabs,
    this.selectedIndex,
    this.onIndexChanged,
  });

  final List<AdaptiveTab> tabs;
  final int? selectedIndex;
  final ValueChanged<int>? onIndexChanged;

  @override
  State<AdaptiveBottomNavigation> createState() =>
      _AdaptiveBottomNavigationState();
}

class _AdaptiveBottomNavigationState extends State<AdaptiveBottomNavigation> {
  late int _currentIndex = widget.selectedIndex ?? 0;
  late final CupertinoTabController _cupertinoController =
      CupertinoTabController(initialIndex: _currentIndex);

  @override
  void didUpdateWidget(covariant AdaptiveBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = widget.selectedIndex;
    if (selected != null && selected != _currentIndex) {
      _currentIndex = selected;
      _cupertinoController.index = selected;
    }
  }

  void _selectIndex(int index) {
    setState(() => _currentIndex = index);
    widget.onIndexChanged?.call(index);
  }

  @override
  void dispose() {
    _cupertinoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isApplePlatform) {
      return CupertinoTabScaffold(
        controller: _cupertinoController,
        tabBar: CupertinoTabBar(
          height: UIConstants.tabBarHeight,
          onTap: _selectIndex,
          items: [
            for (final tab in widget.tabs)
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: UIConstants.paddingSmall),
                  child: Icon(tab.cupertinoIcon),
                ),
                label: tab.label,
              ),
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) => widget.tabs[index].builder(context),
          );
        },
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (final tab in widget.tabs)
            KeyedSubtree(
              key: PageStorageKey(tab.routeName),
              child: tab.builder(context),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: _selectIndex,
        items: [
          for (final tab in widget.tabs)
            BottomNavigationBarItem(
              icon: Icon(tab.materialIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
