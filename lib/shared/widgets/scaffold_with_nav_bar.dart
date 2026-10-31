import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: Icon(PhosphorIconsLight.house),
            selectedIcon: Icon(PhosphorIconsFill.house),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsLight.receipt),
            selectedIcon: Icon(PhosphorIconsFill.receipt),
            label: 'Gastos',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsLight.clipboardText),
            selectedIcon: Icon(PhosphorIconsFill.clipboardText),
            label: 'Fijos',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsLight.creditCard),
            selectedIcon: Icon(PhosphorIconsFill.creditCard),
            label: 'Creditos',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsLight.chartBar),
            selectedIcon: Icon(PhosphorIconsFill.chartBar),
            label: 'Estadisticas',
          ),
        ],
      ),
    );
  }
}
