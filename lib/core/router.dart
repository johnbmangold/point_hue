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
  Widget build(BuildContext context, GoRouterState state) =>
      const LibraryScreen();
}

class ColorDetailRoute extends GoRouteData with $ColorDetailRoute {
  final String hex;
  const ColorDetailRoute({required this.hex});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ColorDetailScreen(hex: hex);
}

// TODO: Add History and Details routes when screens are ready
