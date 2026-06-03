import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:heimwatt/app/utils/app_functions.dart';
import 'package:heimwatt/app/utils/pref_service.dart';
import 'package:heimwatt/repository/main_repository.dart';
import 'package:toastification/toastification.dart';

import 'exports.dart';

class MagicLinkService {
/*  static Future<void> handleLoginWithToken(BuildContext context) async {
    Uri uri = Uri.parse(
      'https://heim-watt.de//login/eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbS9nb29nbGUuaWRlbnRpdHkuaWRlbnRpdHl0b29sa2l0LnYxLklkZW50aXR5VG9vbGtpdCIsImlhdCI6MTc3Mjc3MjkxOSwiZXhwIjoxNzcyNzc2NTE5LCJpc3MiOiJjbG91ZC1ydW4tYXBpQGhlaW13YXR0LXN0YWdpbmcuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLCJzdWIiOiJjbG91ZC1ydW4tYXBpQGhlaW13YXR0LXN0YWdpbmcuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLCJ1aWQiOiJlcmJCZFc3cnZXaHhkWlRrbFBweEtHaWdlUzIyIiwiY2xhaW1zIjp7InJvbGUiOiJjdXN0b21lciIsImNvbnRhY3RfaWQiOiI2NjcyNDEwMzgwNjgiLCJzb3VyY2UiOiJzc28iLCJpc3N1ZWRBdCI6MTc3Mjc3MjkxOTE3MX19.G0xjkiVe0EyUycLSXQnQLBE_yTu7X_P_oWgmEpIVwdvmCnyIZROKmZ9Glg9UWqPih2gdG0FK6MATw_oK9OlttHPLnDhCokjestxFA4nnzLX0r7APsoNwC8M85HiU4TfLzc3lo8xrsZ7Z5ROajtHTyflwYBttfkl4fiRQTv9NL5JedbTa59YMeAmNOyBNI2gfe0CZi24BQOKHN5vivzdFH_MhOviCPdSoYiwJZj-luqFS9Fe-R1tHqvnZFL3Gh58PXSz93i-KIP0LaZPQHh4lZ6rTKPsaw09mlADaqqfWpQ3Tm4KK2-v7ydxsIgxS4r_XmGGCjc6p-UVGjbbZwhDeFQ?dealId=453268516049&contactId=667241038068'
    );
    // Uri uri = Uri.base;
    String token = uri.pathSegments.last;
    String dealId = uri.queryParameters['dealId'] ?? '';
    String contactId = uri.queryParameters['contactId'] ?? '';

    debugPrint(token);
    debugPrint(dealId);
    debugPrint(contactId);

    try {
      await PrefService.setValue(PrefService.accessToken, token);
      await PrefService.setValue(PrefService.dealId, dealId);
      await PrefService.setValue(PrefService.contactId, contactId);
      await MagicLinkService.loginWithToken(context, token: token, dealId: dealId, contactId: contactId);
      debugPrint('Going dahsboard ::::::');
    } catch (e) {
      debugPrint('Login failed: $e');
      context.push(AppRoutes.auth);
    }
  }*/

  static Future<void> loginWithToken(
    BuildContext context, {
    required String token,
    required String dealId,
    required String contactId,
  }) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCustomToken(token);


      final User? user = userCredential.user;

      if (user != null) {
        await createOrUpdateUserInFirebase(user);

        print('user refresh token::: ${user.refreshToken}');
      String idToken=  await user.getIdToken()??"";

        // Store user id
        await PrefService.setValue(PrefService.userId, user.uid);
        await PrefService.setValue(PrefService.accessToken, idToken);

        // Create or check project
        await createOrCheckProjectForUser(user.uid);

        // context.go(AppRoutes.installationSteps);
        await getDealById(dealId: dealId, context: context);
        await getContactById(contactId: contactId, context: context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed. Please try again.';

      if (e.code == 'invalid-custom-token') {
        errorMessage = 'Invalid or expired login token.';
      } else if (e.code == 'custom-token-mismatch') {
        errorMessage = 'Token audience mismatch.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user account has been disabled.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Network error. Please check your connection.';
      }

      print('Token login error: ${e.code}');
      context.go(AppRoutes.auth);
      AppFunctions.showToast(message: errorMessage, toastType: ToastificationType.error);
    } catch (e) {
      print(e.toString());
      AppFunctions.showToast(message: 'An unexpected error occurred.', toastType: ToastificationType.error);
    }
  }

  static Future<void> createOrUpdateUserInFirebase(User user) async {
    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        await userDocRef.set({
          'email': user.email ?? '',
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'approvalStatus': 'pending',
          'display_name': 'Kunde Ausstehend',
          'hubspotContactId': '1002',
          'tokenVersion': 1,
        });
      }
    } catch (e) {
      debugPrint('Error creating/checking user in Firestore: $e');
    }
  }

  static Future<void> createOrCheckProjectForUser(String userId) async {
    try {
      // Query to check if a project with this user_id already exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('project')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      // If no project exists with this user_id, create a new one
      if (querySnapshot.docs.isEmpty) {
        final projectDocRef = FirebaseFirestore.instance.collection('project').doc();
        await projectDocRef.set({
          'user_id': userId,
          'created_at': FieldValue.serverTimestamp(),
          "address": {},
          "bulk_upload": {},
          "hubspot_url": "",
          "installation_steps": {},
          "heatpump": {}, // Will be initialized from install_form template
          "combined": {}, // Will be initialized from install_form template
          "photovoltaics": {},// Will be initialized from install_form template
          "pdf_url": "",
          "project_name": "Project 1",
        });
        debugPrint('New project created for user: $userId');

        // Initialize installation_steps structure from install_form template
        // await _initializeInstallationStepsInProject(projectDocRef);
      } else {
        debugPrint('Project already exists for user: $userId');
        // Ensure installation_steps is initialized even for existing projects
        final existingProjectRef = querySnapshot.docs.first.reference;
        // await _initializeInstallationStepsInProject(existingProjectRef);
      }
    } catch (e) {
      debugPrint('Error creating/checking project in Firestore: $e');
    }
  }

  static Future<void> getDealById({required String dealId, required BuildContext context}) async {
    MainRepository mainRepository = MainRepository();

    await mainRepository.getDealById(
      dealId: dealId,
      onSuccess: (dynamic response) async {
        try {
          debugPrint('success:::${response.toString()} ');
          await PrefService.setValue(PrefService.dealName, response['data']['projectType']);

          context.go(AppRoutes.installationSteps);
          AppFunctions.showToast(message: 'Login successful!!', toastType: ToastificationType.success);
        } catch (e) {
          context.go(AppRoutes.auth);
          debugPrint('error:::${response.toString()} ');
          AppFunctions.showToast(message: 'error');
        }
      },
      onError: (dynamic error) {
        debugPrint('error:::$error');
        String message = error.message;
        context.go(AppRoutes.auth);
        AppFunctions.showToast(message: message);
      },
    );
  }

  static Future<void> getContactById({required String contactId, required BuildContext context}) async {
    MainRepository mainRepository = MainRepository();
    await mainRepository.getContactById(
      contactId: contactId,
      onSuccess: (dynamic response) {
        try {
          debugPrint('success:::${response.toString()} ');
        } catch (e) {
          debugPrint('error:::${response.toString()} ');
        }
      },
      onError: (dynamic error) {
        debugPrint('error:::$error');
        String message = error.message;
      },
    );
  }
}
