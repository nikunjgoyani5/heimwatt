import 'package:flutter/material.dart';

import 'package:heimwatt/app/modules/auth/authentication/views/desktop_authentication.dart';
import 'package:heimwatt/app/modules/auth/authentication/views/mobile_authentication.dart';
import 'package:heimwatt/app/utils/exports.dart';
import 'package:heimwatt/app/utils/magic_link_service.dart';
import 'package:heimwatt/main.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  @override
  void initState() {
    super.initState();
    // Call handleLoginWithToken after the first frame is built
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(Duration(seconds: 3));
    //   MagicLinkService.handleLoginWithToken(context);
    // });
   /* WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      final token =
          'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbS9nb29nbGUuaWRlbnRpdHkuaWRlbnRpdHl0b29sa2l0LnYxLklkZW50aXR5VG9vbGtpdCIsImlhdCI6MTc3Mjg2ODQ3MywiZXhwIjoxNzcyODcyMDczLCJpc3MiOiJjbG91ZC1ydW4tYXBpQGhlaW13YXR0LXN0YWdpbmcuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLCJzdWIiOiJjbG91ZC1ydW4tYXBpQGhlaW13YXR0LXN0YWdpbmcuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLCJ1aWQiOiJlcmJCZFc3cnZXaHhkWlRrbFBweEtHaWdlUzIyIiwiY2xhaW1zIjp7InJvbGUiOiJjdXN0b21lciIsImNvbnRhY3RfaWQiOiI2NjcyNDEwMzgwNjgiLCJzb3VyY2UiOiJzc28iLCJpc3N1ZWRBdCI6MTc3Mjg2ODQ3MzY2OH19.rt8qSTeskuRY3vPGkWEJQzMfAA436TaYhIPOP1e9-AZLIIOwgtF_YQTjEkZQ_zcHRAsDATNzLrXZ-JdQN1ge1fuAgKs5YvmSTiB8i-FDGlFmHoehCvBsb7bmG52wP04GW0mL7JhFWzCHa3Qb6SDdPz2ps044dUEjqhQ6rs6u0VwNdj1itEsPKF-nszaqrWgF4NCp9uw9UaEpkibE9KD9yJaGNmi2f8QkxBhJCYqBGD8EBUSe6HsID2BWT2jMZULFEoddEmWTjOR3MkqbZrckR-jXsk-V5YxhUvs0VAh5Lp58VQ3P-vGOd8TvLzOpFjyQkUGMMJaafvxEbkaRBDYXow';
      final dealId = '453268516049';
      final contactId = '667241038068';
      MagicLinkService.loginWithToken(context, token: token, dealId: dealId, contactId: contactId);
    });*/
  WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      final token = state.pathParameters['token'] ?? '';
      final dealId = state.uri.queryParameters['dealId'] ?? '';
      final contactId = state.uri.queryParameters['contactId'] ?? '';
      MagicLinkService.loginWithToken(context, token: token, dealId: dealId, contactId: contactId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => const MobileAuthentication(),
      tablet: (context) => const MobileAuthentication(),
      desktop: (context) => const DesktopAuthentication(),
    );
  }
}
