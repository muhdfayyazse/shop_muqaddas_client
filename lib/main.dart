import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muqaddas_shop/providers/cart.dart';
import 'package:muqaddas_shop/providers/orders.dart';
import 'package:muqaddas_shop/providers/products_provider.dart';
import 'package:muqaddas_shop/screens/cart_screen.dart';
import 'package:muqaddas_shop/screens/product_detail.dart';
import 'package:muqaddas_shop/screens/userproducts_screen.dart';

import 'helpers/custom_route.dart';
import 'providers/auth.dart';
import 'screens/auth_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/home_page.dart';
import 'screens/orders_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products("", [], ""),
          update: (ctx, auth, previousProduct) => Products(
            auth.token.toString(),
            previousProduct!.items,
            auth.userId.toString(),
          ),
        ),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders("", [], ""),
          update: (context, auth, previousOrder) => Orders(
            auth.token.toString(),
            previousOrder!.orders,
            auth.userId.toString(),
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, authData, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Your One Stop Food Place',
            theme: themeForApp(),
            home: authData.isAuth
                ? const HomePage()
                : FutureBuilder(
                    future: authData.tryAutoLogin(),
                    builder: (context, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? const SplashScreen()
                            : const AuthScreen(),
                  ),
            routes: {
              HomePage.routeName: (context) => const HomePage(),
              ProductDetail.routeName: (context) => const ProductDetail(),
              CartScreen.routeName: (context) => const CartScreen(),
              OrdersScreen.routeName: (context) => const OrdersScreen(),
              UserProductsScreen.routeName: (context) =>
                  const UserProductsScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
            },
          );
        },
      ),
    );
  }

  ThemeData themeForApp() {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.orange)
          .copyWith(secondary: Colors.red),
      fontFamily: "Lato",
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: CustomPageTransitionBuilder(),
        TargetPlatform.iOS: CustomPageTransitionBuilder(),
      }),
    );
  }
}
