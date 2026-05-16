import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:point_hue/features/home/home_screen.dart';
import 'package:point_hue/features/color/library_screen.dart';
import 'package:point_hue/features/color/color_detail_screen.dart';

part 'router.g.dart';

final goRouter = GoRouter(initialLocation: '/', routes: $appRoutes);

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<LibraryRoute>(path: 'library'),
    TypedGoRoute<ColorDetailRoute>(path: 'details/:hex'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class LibraryRoute extends GoRouteData with $LibraryRoute {
  const LibraryRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      CustomTransitionPage(
        key: state.pageKey,
        child: const LibraryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      );
}

class ColorDetailRoute extends GoRouteData with $ColorDetailRoute {
  final String hex;
  const ColorDetailRoute({required this.hex});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      CustomTransitionPage(
        key: state.pageKey,
        child: ColorDetailScreen(hex: hex),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      );
}
