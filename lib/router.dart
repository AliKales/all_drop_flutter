import 'package:all_drop/pages/error.dart';
import 'package:all_drop/pages/main_page/main_page_view.dart';
import 'package:all_drop/pages/phone_page/phone_page_view.dart';
import 'package:all_drop/settings.dart';
import 'package:go_router/go_router.dart';

import 'common_libs.dart';
import 'core/firebase/f_auth.dart';
import 'pages/auth_page/auth_page_view.dart';

class PagePaths {
  static String main = "/";
  static String auth = "/auth";
  static String error = "/error";
  static String phone = "/phone";
}

final appRouter = GoRouter(
  initialLocation: PagePaths.main,
  // errorBuilder: (context, state) => const MainPageView(),
  redirect: (context, state) {
    if (!FAuth.isSignedIn) {
      Settings.routes.add(PagePaths.auth);
      return PagePaths.auth;
    }

    if (FAuth.getPhone == "") {
      Settings.routes.add(PagePaths.phone);
      return PagePaths.phone;
    }

    if (FAuth.isSignedIn && AppRoute.isLocation(state, PagePaths.auth)) {
      Settings.routes.add(PagePaths.main);
      return PagePaths.main;
    }

    Settings.routes.add(state.location);

    return null;
  },
  routes: [
    AppRoute(PagePaths.main, (s) => const MainPageView()),
    AppRoute(PagePaths.auth, (s) => const AuthPageView()),
    AppRoute(PagePaths.phone, (s) => const PhonePageView()),
    AppRoute(
        PagePaths.error,
        (s) => const ErrorPage(
              error: "asdkas mkdkas dkasd",
            )),
  ],
);

class AppRoute extends GoRoute {
  AppRoute(String path, Widget Function(GoRouterState s) builder)
      : super(
          path: path,
          pageBuilder: (context, state) => MaterialPage(
            child: builder(state),
          ),
        );

  static bool isLocation(GoRouterState state, String location) {
    return state.location.contains(location);
  }
}
