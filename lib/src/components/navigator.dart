// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pacervtu/constants.dart';
import 'package:pacervtu/src/pages/finances.dart';
import 'package:pacervtu/src/pages/home.dart';
import 'package:pacervtu/src/pages/settings.dart';

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int currentIndex = 0;

  final pages = const [
    Home(),
    Finances(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: NavigationBar(
        height: 65,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),

        // Optional: Customize background
        backgroundColor: Theme.of(context).colorScheme.surface,

        indicatorColor: AppData.appTheme.withOpacity(0.2),

        labelTextStyle: MaterialStateProperty.all(TextStyle(color: AppData.fontTheme, fontWeight: FontWeight.w400)),

        destinations: [
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/home.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppData.fontTheme,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/home-filled.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppData.appTheme.withAlpha(150),
                BlendMode.srcIn,
              ),
            ),
            label: "Home",
          ),

          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/finances.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                 AppData.fontTheme,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/finances-filled.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
              AppData.appTheme.withAlpha(150),
                BlendMode.srcIn,
              ),
            ),
            label: "Finances",
          ),

          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/settings.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                 AppData.fontTheme,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/settings-filled.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
              AppData.appTheme.withAlpha(150),
                BlendMode.srcIn,
              ),
            ),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
