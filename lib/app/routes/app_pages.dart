import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/modules/list_favorite/bindings/list_favorite_binding.dart';
import 'package:lelang_fb/app/modules/list_favorite/views/list_favorite_view.dart';
import 'package:lelang_fb/app/modules/myitems/bindings/myitems_binding.dart';
import 'package:lelang_fb/app/modules/myitems/views/myitems_view.dart';
import 'package:lelang_fb/app/modules/notifications/bindings/notifications_binding.dart';
import 'package:lelang_fb/app/modules/notifications/views/notifications_view.dart';
import 'package:lelang_fb/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:lelang_fb/app/modules/onboarding/views/onboarding_view.dart';
import 'package:lelang_fb/app/modules/profile/bindings/profile_binding.dart';
import 'package:lelang_fb/app/modules/profile/views/profile_view.dart';
import 'package:lelang_fb/app/modules/search/bindings/search_binding.dart';
import 'package:lelang_fb/app/modules/search/views/search_view.dart';

import '../modules/addItem/bindings/add_item_binding.dart';
import '../modules/addItem/views/add_item_view.dart';
import '../modules/detailItem/bindings/detail_item_binding.dart';
import '../modules/detailItem/views/detail_item_view.dart';
import '../modules/emailVerification/bindings/email_verification_binding.dart';
import '../modules/emailVerification/views/email_verification_view.dart';
import '../modules/forgotPassword/bindings/forgot_password_binding.dart';
import '../modules/forgotPassword/views/forgot_password_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

abstract class Routes {
  Routes._(); // Private constructor to prevent instantiation

  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const SPLASH = _Paths.SPLASH;
  static const SIGNUP = _Paths.SIGNUP;
  static const EMAIL_VERIFICATION = _Paths.EMAIL_VERIFICATION;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const DETAIL_ITEM = _Paths.DETAIL_ITEM;
  static const ADD_ITEM = _Paths.ADD_ITEM;
  static const PROFILE = _Paths.PROFILE;
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;
  static const LIST_FAVORITE = _Paths.LIST_FAVORITE;
  static const SEARCH = _Paths.SEARCH;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const MYITEMS = _Paths.MYITEMS;
}

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.EMAIL_VERIFICATION,
      page: () => EmailVerificationView(),
      binding: EmailVerificationBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.DETAIL_ITEM,
      page: () => const DetailItemView(),
      binding: DetailItemBinding(),
    ),
    GetPage(
      name: Routes.ADD_ITEM,
      page: () => const AddItemView(),
      binding: AddItemBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotifictaionsView(),
      binding: NotificationsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.LIST_FAVORITE,
      page: () => const ListFavoriteView(),
      binding: ListFavoriteBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.MYITEMS,
      page: () => MyitemsView(),
      binding: MyitemsBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
