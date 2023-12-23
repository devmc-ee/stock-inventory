import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/pages/inventory_list.dart';
import 'package:inventory/providers/inventory.dart';
import 'package:inventory/providers/login_info.dart';
import 'package:inventory/pages/home.dart';
import 'package:inventory/pages/inventory_item.dart';
import 'package:inventory/pages/login.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(App());
}

class App extends StatelessWidget {
  final loginInfo = LoginInfo();

  App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginInfo>(create: (context) => LoginInfo()),
        ChangeNotifierProvider<InventoryProvider>(
          create: (context) => InventoryProvider(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  late final _router = GoRouter(
    routes: [
      GoRoute(
        name: 'inventories',
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
          name: 'inventory',
          path: '/inventory/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'];
            final int inventoryId = id != null ? int.parse(id) : 0;
            context.read<InventoryProvider>().setCurrentInventory(inventoryId);
            return const InventoryListPage();
          }),
      GoRoute(path: '/item', builder: (context, state) => InventoryItemPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    ],
    redirect: (context, state) {
      // if the user is not logged in, they need to login
      final loggedIn = context.watch<LoginInfo>().loggedIn;
      final loggingIn = state.fullPath == '/login';
      if (!loggedIn) return loggingIn ? null : '/login';

      // if the user is logged in but still on the login page, send them to
      // the home page
      if (loggingIn) return '/';

      // no need to redirect at all
      return null;
    },
    refreshListenable: loginInfo,
  );
}
