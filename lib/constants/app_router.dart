import 'package:auto_route/auto_route.dart';
import 'package:mynotes/constants/app_router.gr.dart';

@AutoRouterConfig(
  replaceInRouteName: 'View,Route',
)
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: CreateUpdateNoteRoute.page),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: RegisterRoute.page),
        AutoRoute(page: VerifyEmailRoute.page),
        AutoRoute(page: NotesRoute.page),
        AutoRoute(page: HomePage.page, path: '/')
      ];
}
