import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'ui/design_system.dart';

// Providers
import 'services/college_provider.dart';
import 'services/profile_provider.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/college_detail_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/predictor_screen.dart';
import 'screens/exams_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/goal_location_selector_screen.dart';
import 'models/college.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CollegeProvider()),
        // Load profile from SharedPreferences on startup
        ChangeNotifierProvider(create: (_) => ProfileProvider()..load()),
      ],
      child: MaterialApp.router(
        title: 'College Campus',
        theme: ThemeData(
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: AppTokens.primary,
            onPrimary: Colors.white,
            secondary: AppTokens.secondary,
            onSecondary: Colors.black,
            error: AppTokens.error,
            onError: Colors.white,
            surface: AppTokens.surface,
            onSurface: AppTokens.textPrimary,
            tertiary: AppTokens.tertiary,
            background: AppTokens.bg,
            onBackground: AppTokens.textPrimary,
          ),
          scaffoldBackgroundColor: AppTokens.bg,
          useMaterial3: true,
          fontFamily: 'Inter',
          appBarTheme: AppBarTheme(
            backgroundColor: AppTokens.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actionsIconTheme: const IconThemeData(color: Colors.white),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            shadowColor: AppTokens.primary.withOpacity(0.4),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.primary,
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: AppTokens.primary.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 3,
            shadowColor: Colors.black.withOpacity(0.1),
            surfaceTintColor: Colors.white,
            color: AppTokens.surface,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppTokens.outline, width: 1),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppTokens.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTokens.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTokens.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTokens.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTokens.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTokens.error, width: 2),
            ),
            hintStyle: const TextStyle(color: AppTokens.textSecondary, fontSize: 15),
            labelStyle: const TextStyle(color: AppTokens.textSecondary, fontSize: 15),
            floatingLabelStyle: const TextStyle(color: AppTokens.primary, fontWeight: FontWeight.w600),
            prefixIconColor: AppTokens.textSecondary,
            suffixIconColor: AppTokens.textSecondary,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: AppTokens.surface,
            selectedItemColor: AppTokens.primary,
            unselectedItemColor: AppTokens.textSecondary,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            type: BottomNavigationBarType.fixed,
            elevation: 12,
            showSelectedLabels: true,
            showUnselectedLabels: true,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1.0),
            displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return WillPopScope(
            onWillPop: () async {
              if (GoRouter.of(context).canPop()) {
                GoRouter.of(context).pop();
                return false;
              }
              return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Exit App'),
                      content:
                          const Text('Are you sure you want to exit the app?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Exit'),
                        ),
                      ],
                    ),
                  ) ??
                  false;
            },
            child: child!,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Page Not Found'),
      backgroundColor: const Color(0xFF4F46E5),
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Page not found'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
  redirectLimit: 5,
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/home',
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(opacity: curve, child: child);
        },
        transitionDuration: const Duration(milliseconds: 180),
      ),
    ),
    GoRoute(
      path: '/favorites',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const FavoritesScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(opacity: curve, child: child);
        },
        transitionDuration: const Duration(milliseconds: 180),
      ),
    ),
    GoRoute(
      path: '/predictor',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PredictorScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(opacity: curve, child: child);
        },
        transitionDuration: const Duration(milliseconds: 180),
      ),
    ),
    GoRoute(
      path: '/exams',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ExamsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(opacity: curve, child: child);
        },
        transitionDuration: const Duration(milliseconds: 180),
      ),
    ),
    GoRoute(
      path: '/compare',
      pageBuilder: (context, state) {
        final extra = state.extra;
        List<College>? initial;
        if (extra is College) {
          initial = [extra];
        } else if (extra is List<College>) {
          initial = extra;
        }
        return CustomTransitionPage(
          key: state.pageKey,
          child: CompareScreen(initialSelection: initial),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(opacity: curve, child: child);
          },
          transitionDuration: const Duration(milliseconds: 180),
        );
      },
    ),
    GoRoute(
      path: '/select-goal',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const GoalLocationSelectorScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(opacity: curve, child: child);
        },
        transitionDuration: const Duration(milliseconds: 180),
      ),
    ),
    GoRoute(
      path: '/college/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: CollegeDetailScreen(collegeId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(opacity: curve, child: child);
          },
          transitionDuration: const Duration(milliseconds: 180),
        );
      },
    ),
    // NEW: Profile route
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(opacity: curve, child: child);
        },
        transitionDuration: const Duration(milliseconds: 180),
      ),
    ),
  ],
);
