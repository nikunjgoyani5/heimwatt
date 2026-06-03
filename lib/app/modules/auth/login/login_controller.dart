import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heimwatt/app/utils/app_functions.dart';
import 'package:heimwatt/app/utils/magic_link_service.dart';
import 'package:heimwatt/app/utils/pref_service.dart';
import 'package:heimwatt/main.dart';
import 'package:toastification/toastification.dart';

import '../../../utils/exports.dart';

class LoginController extends GetxController {
  RxBool isEyeOpen = false.obs;
  RxBool isLoading = false.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> loginKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> login(BuildContext context) async {
    if (!(loginKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      isLoading.value = true;
      update();

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await createOrUpdateUserInFirebase(user);
        print('user refresh token:::${user.refreshToken}');

        String idToken = await user.getIdToken() ?? '';
        print('user id token:::$idToken');
        print('user access token:::${userCredential.credential?.accessToken ?? ''}');
        print('user  token:::${userCredential.credential?.token ?? ''}');
        // Store user_id in preferences
        await PrefService.setValue(PrefService.userId, user.uid);
        await PrefService.setValue(PrefService.accessToken, idToken);

        // Create or check project for this user

        await createOrCheckProjectForUser(user.uid);

        isLoading.value = false;
        if (PrefService.getString(PrefService.dealId).isNotEmpty) {
          await MagicLinkService.getDealById(dealId: PrefService.getString(PrefService.dealId), context: context);
        } else {
          context.go(AppRoutes.dealSelection);
        }
        AppFunctions.showToast(message: 'Login successful!!', toastType: ToastificationType.success);
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      update();

      String errorMessage = 'Login failed. Please try again.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid credential';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user account has been disabled.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many requests. Please try again later.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Network error. Please check your connection.';
      }
      print(errorMessage);
      print(e.code);
      AppFunctions.showToast(message: errorMessage, toastType: ToastificationType.error);
    } catch (e) {
      isLoading.value = false;
      update();
      print(e.toString());
      AppFunctions.showToast(
        message: 'An unexpected error occurred. Please try again.',
        toastType: ToastificationType.error,
      );
    }
  }

  Future<void> createOrUpdateUserInFirebase(User user) async {
    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        await userDocRef.set({
          'email': user.email ?? emailController.text.trim(),
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

  Future<void> createOrCheckProjectForUser(String userId) async {
    try {
      // Query to check if a project with this user_id already exists
      final querySnapshot = await _firestore.collection('project').where('user_id', isEqualTo: userId).limit(1).get();

      // If no project exists with this user_id, create a new one
      if (querySnapshot.docs.isEmpty) {
        final projectDocRef = _firestore.collection('project').doc();
        await projectDocRef.set({
          'user_id': userId,
          'created_at': FieldValue.serverTimestamp(),
          "address": {},
          "bulk_upload": {},
          "hubspot_url": "",
          "installation_steps": {}, // Will be initialized from install_form template
          "heatpump": {}, // Will be initialized from install_form template
          "combined": {}, // Will be initialized from install_form template
          "photovoltaics": {}, // Will be initialized from install_form template
          "pdf_url": "",
          "project_name": "Project 1",
        });
        debugPrint('New project created for user: $userId');

        // Initialize installation_steps structure from install_form template
        await _initializeInstallationStepsInProject(projectDocRef);
      } else {
        debugPrint('Project already exists for user: $userId');
        // Ensure installation_steps is initialized even for existing projects
        final existingProjectRef = querySnapshot.docs.first.reference;
        await _initializeInstallationStepsInProject(existingProjectRef);
      }
    } catch (e) {
      debugPrint('Error creating/checking project in Firestore: $e');
    }
  }

  // Initialize installation_steps structure in project (mirroring install_form)
  Future<void> _initializeInstallationStepsInProject(DocumentReference projectRef) async {
    try {
      final projectDoc = await projectRef.get();
      final projectData = projectDoc.data() as Map<String, dynamic>?;

      // Check if installation_steps already exists and has data
      if (projectData != null &&
          projectData.containsKey(PrefService.getString(PrefService.dealName)) &&
          projectData[PrefService.getString(PrefService.dealName)] is Map &&
          (projectData[PrefService.getString(PrefService.dealName)] as Map).isNotEmpty) {
        debugPrint('installation_steps already initialized in project');
        return;
      }

      // Get the template from install_form
      final installFormSnapshot = await _firestore.collection(PrefService.getString(PrefService.dealName)).limit(1).get();

      if (installFormSnapshot.docs.isEmpty) {
        debugPrint('install_form template not found');
        return;
      }

      final installFormData = installFormSnapshot.docs.first.data();
      final steps = installFormData['steps'] as List<dynamic>?;

      if (steps == null) {
        debugPrint('Steps not found in install_form');
        return;
      }

      // Create installation_steps structure with empty images arrays
      final installationSteps = <String, dynamic>{};
      for (int stepIndex = 0; stepIndex < steps.length; stepIndex++) {
        final stepData = steps[stepIndex] as Map<String, dynamic>;
        final dataField = stepData['data'];

        Map<String, dynamic>? processedData;
        if (dataField is List) {
          processedData = {};
          for (int dataIndex = 0; dataIndex < dataField.length; dataIndex++) {
            final dataItem = dataField[dataIndex];
            if (dataItem is Map<String, dynamic>) {
              // Copy the structure but initialize images as empty array
              processedData[dataIndex.toString()] = {
                ...dataItem,
                'images': <String>[], // Initialize empty images array
              };
            }
          }
        } else if (dataField is Map) {
          processedData = {};
          (dataField as Map).forEach((key, value) {
            if (value is Map<String, dynamic>) {
              processedData![key.toString()] = {
                ...value,
                'images': <String>[], // Initialize empty images array
              };
            }
          });
        }

        installationSteps[stepIndex.toString()] = {
          'title': stepData['title'],
          'des': stepData['des'],
          'info_video': stepData['info_video'],
          'data': processedData ?? {},
        };
      }

      // Update project with installation_steps
      await projectRef.update({PrefService.getString(PrefService.dealName): installationSteps});

      debugPrint('installation_steps initialized in project');
    } catch (e) {
      debugPrint('Error initializing installation_steps in project: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
