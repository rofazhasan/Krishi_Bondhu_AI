import 'package:go_router/go_router.dart';
import '../../ui/features/welcome/welcome_screen.dart';
import '../../ui/features/camera/camera_screen.dart';
import '../../ui/features/analysis/analysis_screen.dart';
import '../../ui/features/diagnosis/diagnosis_screen.dart';
import '../../ui/features/medicine/medicine_screen.dart';
import '../../ui/features/history/history_screen.dart';
import '../../ui/features/learning/learning_center_screen.dart';
import '../../ui/features/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/camera',
      builder: (context, state) => const CameraScreen(),
    ),
    GoRoute(
      path: '/analysis',
      builder: (context, state) => const AnalysisScreen(),
    ),
    GoRoute(
      path: '/diagnosis',
      builder: (context, state) => const DiagnosisScreen(),
    ),
    GoRoute(
      path: '/medicine',
      builder: (context, state) => const MedicineScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/learning',
      builder: (context, state) => const LearningCenterScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
