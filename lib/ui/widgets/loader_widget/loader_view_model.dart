import 'package:flutter/material.dart';
import 'package:themoviedb/domain/services/auth_service.dart';
import 'package:themoviedb/ui/navigation/main_navigation.dart';

class LoaderViewModel {
  final _authService = AuthService();
  final BuildContext context;
  LoaderViewModel(this.context) {
    asyncInit();
  }

  Future<void> asyncInit() async {
    await checkAuth();
  }

  Future<void> checkAuth([bool mounted = true]) async {
    final isAuth = await _authService.isAuth();
    final nextScreen =
        isAuth ? MainNavigationNames.mainScreen : MainNavigationNames.auth;
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(nextScreen);
  }
}
