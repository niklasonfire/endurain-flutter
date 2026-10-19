import 'package:endurain/core/utils/platform_utils.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PlatformUtils.debugIsApplePlatformOverride = false;
  });

  tearDown(PlatformUtils.debugResetOverrides);

  for (final apple in [false, true]) {
    testWidgets(
      'Home action can select Activities and user can return (apple=$apple)',
      (tester) async {
        PlatformUtils.debugIsApplePlatformOverride = apple;
        await tester.pumpWidget(
          AdaptiveApp(title: 'Test', home: _HomeNavigationExample()),
        );
        expect(find.text('Home content'), findsOneWidget);
        await tester.tap(find.text('Update recording'));
        await tester.pump();
        expect(find.text('Recording 1'), findsOneWidget);
        await tester.tap(find.text('All activities'));
        await tester.pumpAndSettle();
        expect(find.text('Activity content'), findsOneWidget);
        await tester.tap(find.text('Home').last);
        await tester.pumpAndSettle();
        expect(find.text('Home content'), findsOneWidget);
      },
    );
  }

  testWidgets('AdaptiveBottomNavigation switches material tabs', (
    tester,
  ) async {
    await tester.pumpWidget(
      AdaptiveApp(
        title: 'Test',
        home: AdaptiveBottomNavigation(
          tabs: [
            AdaptiveTab(
              routeName: '/map',
              label: 'Map',
              materialIcon: Icons.map,
              cupertinoIcon: Icons.map,
              builder: (_) => const Center(child: Text('Map page')),
            ),
            AdaptiveTab(
              routeName: '/settings',
              label: 'Settings',
              materialIcon: Icons.settings,
              cupertinoIcon: Icons.settings,
              builder: (_) => const Center(child: Text('Settings page')),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Map page'), findsOneWidget);
    expect(find.text('Settings page'), findsNothing);

    await tester.tap(find.text('Settings'));
    await tester.pump();

    expect(find.text('Map page'), findsNothing);
    expect(find.text('Settings page'), findsOneWidget);
  });
}

class _HomeNavigationExample extends StatefulWidget {
  @override
  State<_HomeNavigationExample> createState() => _HomeNavigationExampleState();
}

class _HomeNavigationExampleState extends State<_HomeNavigationExample> {
  int selected = 0;
  int recording = 0;
  @override
  Widget build(BuildContext context) => AdaptiveBottomNavigation(
    selectedIndex: selected,
    onIndexChanged: (index) => setState(() => selected = index),
    tabs: [
      AdaptiveTab(
        routeName: '/home',
        label: 'Home',
        materialIcon: Icons.home,
        cupertinoIcon: Icons.home,
        builder: (_) => Column(
          children: [
            const Text('Home content'),
            Text('Recording $recording'),
            AdaptiveButton(
              label: 'Update recording',
              onPressed: () => setState(() => recording++),
            ),
            AdaptiveButton(
              onPressed: () => setState(() => selected = 1),
              label: 'All activities',
            ),
          ],
        ),
      ),
      AdaptiveTab(
        routeName: '/activities',
        label: 'Activities',
        materialIcon: Icons.list,
        cupertinoIcon: Icons.list,
        builder: (_) => const Center(child: Text('Activity content')),
      ),
    ],
  );
}
