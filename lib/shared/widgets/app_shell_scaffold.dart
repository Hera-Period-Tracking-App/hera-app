import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';
import 'package:hera_app/shared/providers/shell_navigation_visibility_provider.dart';

class AppShellScaffold extends ConsumerWidget {
  const AppShellScaffold({
    required this.navigationShell,
    this.hideNavigation = false,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final bool hideNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phaseColors = Theme.of(context).extension<CyclePhaseColors>();
    final notesEnabled = ref.watch(settingsProvider).maybeWhen(
          data: (settings) => settings.notesEnabled,
          orElse: () => true,
        );

    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: hideNavigation
          ? null
          : Stack(
              clipBehavior: Clip.none,
              children: [
                BottomAppBar(
                  color: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 72,
                      child: Row(
              children: [
                _ShellTabButton(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => navigationShell.goBranch(
                    0,
                    initialLocation: 0 == navigationShell.currentIndex,
                  ),
                ),
                _ShellTabButton(
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  label: 'Calendar',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => navigationShell.goBranch(
                    1,
                    initialLocation: 1 == navigationShell.currentIndex,
                  ),
                ),
                const SizedBox(width: 56),
                _ShellTabButton(
                  icon: Icons.edit_note_outlined,
                  activeIcon: Icons.edit_note,
                  label: 'Notes',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: notesEnabled
                      ? () => navigationShell.goBranch(
                            2,
                            initialLocation: 2 == navigationShell.currentIndex,
                          )
                      : null,
                ),
                _ShellTabButton(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isSelected: navigationShell.currentIndex == 3,
                  onTap: () => navigationShell.goBranch(
                    3,
                    initialLocation: 3 == navigationShell.currentIndex,
                  ),
                ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -28,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      onPressed: () =>
                          _showAddMenu(context, notesEnabled: notesEnabled),
                      backgroundColor: AppColors.sun,
                      foregroundColor: AppColors.twilight,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showAddMenu(
    BuildContext context, {
    required bool notesEnabled,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.playlist_add_circle_outlined),
                  title: const Text('Start new cycle'),
                  subtitle:
                      const Text('Begin tracking a fresh cycle start date.'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    final focusToday = DateTime.now().millisecondsSinceEpoch;
                    context.go(
                      '${AppRoutePaths.calendar}?startNewCycle=true&focusToday=$focusToday',
                    );
                  },
                ),
                if (notesEnabled)
                  ListTile(
                    leading: const Icon(Icons.note_add_outlined),
                    title: const Text('Add note'),
                    subtitle:
                        const Text('Pick a date and write a private note.'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      final focusAddNote =
                          DateTime.now().millisecondsSinceEpoch;
                      context.go(
                        '${AppRoutePaths.calendar}?addNote=true&focusAddNote=$focusAddNote',
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShellTabButton extends StatelessWidget {
  const _ShellTabButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: onTap == null
                  ? theme.disabledColor
                  : isSelected
                      ? selectedColor
                      : unselectedColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: onTap == null
                    ? theme.disabledColor
                    : isSelected
                        ? selectedColor
                        : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
