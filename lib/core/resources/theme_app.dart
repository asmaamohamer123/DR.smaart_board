import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'style.dart';

// to access the themeData properties use {Theme.of(context).}
ThemeData lightTheme() {
  return ThemeData(
      primaryColor: AppColors.primaryColorLight,
      scaffoldBackgroundColor: AppColors.backGroundColorLightMode,
      disabledColor: AppColors.disabledColor,
      appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: AppColors.primaryColorLight,
          titleTextStyle: black22bold().copyWith(color: AppColors.colorWhite),
          toolbarHeight: 80,
          elevation: 5,
          shadowColor: AppColors.primaryColorLight,
          iconTheme: const IconThemeData(color: AppColors.colorWhite),
          shape:const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
          )),
      drawerTheme: const DrawerThemeData(
          backgroundColor: AppColors.backGroundColorLightMode),
      textTheme: TextTheme(
          headlineLarge: black24bold(),
          headlineMedium: black22bold(),
          headlineSmall: black20bold(),
          titleLarge: black18regular(),
          titleMedium: black16regular(),
          titleSmall: black14regular(),
          labelSmall: black12regular()),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primaryColorLight,
          unselectedItemColor: AppColors.iconColorLight,
          selectedItemColor: AppColors.primaryColorLight,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          selectedIconTheme:
              const IconThemeData(color: AppColors.primaryColorLight),
          unselectedIconTheme: IconThemeData(color: AppColors.iconColorLight)),
      cardTheme: CardTheme(
        elevation: 6.5,
        shadowColor: Colors.black.withOpacity(.5),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.colorGray, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        // focused border style
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.colorBlue, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        // error border style
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.colorRed, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        // focused border style
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.colorBlue, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(5))),
      ));
}

ThemeData darkTheme() {
  return ThemeData(
    disabledColor: AppColors.disabledColor,
    primaryColor: AppColors.primaryColorDark,
    scaffoldBackgroundColor: AppColors.backGroundColorDarkMode,
    appBarTheme: AppBarTheme(
        centerTitle: true,
        color: AppColors.primaryColorDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.iconColorDark)),
    drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.backGroundColorDarkMode),
    textTheme: TextTheme(
        headlineLarge: white24bold(),
        headlineMedium: white22bold(),
        headlineSmall: white20bold(),
        titleLarge: white18regular(),
        titleMedium: white16regular(),
        titleSmall: white14regular(),
        labelSmall: white12regular()),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.primaryColorDark,
      unselectedItemColor: AppColors.iconColorDark,
      selectedItemColor: AppColors.primaryColorLight,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      selectedIconTheme: const IconThemeData(color: AppColors.primaryColorDark),
      unselectedIconTheme: IconThemeData(color: AppColors.iconColorDark),
    ),
    cardTheme: const CardTheme(elevation: 0),
  );
}
