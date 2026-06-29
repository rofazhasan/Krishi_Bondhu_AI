import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/colors.dart';
import 'core/services/router.dart';
import 'core/services/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'কৃষি বন্ধু AI',
      debugShowCheckedModeBanner: false,
      
      // Light and Dark theme configurations
      theme: AppColors.getLightTheme(),
      darkTheme: AppColors.getDarkTheme(),
      themeMode: themeMode,
      
      // Router configuration using GoRouter
      routerConfig: appRouter,
    );
  }
}
