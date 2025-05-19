GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/count/new',
      builder: (_, __) => const ButterflyCountForm(),
    ),
    GoRoute(
      path: '/count/mine',
      builder: (_, __) => const MyCountsScreen(),
    ),
  ],
)