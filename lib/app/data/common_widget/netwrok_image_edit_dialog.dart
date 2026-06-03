import 'package:pro_image_editor/core/models/styles/sub_editor_page_style.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../modules/installation_steps/installation_steps_controller.dart';
import '../../utils/exports.dart';

class EditImageNetworkDialog extends StatefulWidget {



  const EditImageNetworkDialog({super.key, });

  static void show(
      BuildContext context, {
        required String image,
        Function(Uint8List)? onSave,
        VoidCallback? onCancel,

      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: isMobile ? 8 : 40),
          child: _EditImageDialogNetworkContent(
            image: image,
            onSave: onSave,
            onCancel: onCancel,
            dialogContext: dialogContext,
          ),
        );
      },
    );
  }

  @override
  State<EditImageNetworkDialog> createState() => _EditImageNetworkDialogState();
}

class _EditImageDialogNetworkContent extends StatefulWidget {
  final String image;
  final Function(Uint8List)? onSave;
  final VoidCallback? onCancel;
  final BuildContext dialogContext;

  const _EditImageDialogNetworkContent({required this.image, this.onSave, this.onCancel, required this.dialogContext});

  @override
  State<_EditImageDialogNetworkContent> createState() => _EditImageDialogNetworkContentState();
}

class _EditImageDialogNetworkContentState extends State<_EditImageDialogNetworkContent> {
  ProImageEditorConfigs _buildEditorConfigs({
    required bool isMobile,
  }) {
    final radius = BorderRadius.circular(isMobile ? 20 : 24);

    return ProImageEditorConfigs(
      mainEditor: MainEditorConfigs(
        style: MainEditorStyle(
          subEditorPage: SubEditorPageStyle(
            // Keep Paint/Crop/etc. inside the dialog area instead of fullscreen.
            enforceSizeFromMainEditor: true,
            borderRadius: radius,
            positionTop: 0,
            positionLeft: 0,
            positionRight: 0,
            positionBottom: 0,
            // Prevent an extra fullscreen dim layer outside the dialog.
            barrierColor: Colors.transparent,
            barrierDismissible: false,
          ),
        ),
      ),
    );
  }

  void _closeDialog() {
    if (mounted) {
      final navigator = Navigator.of(widget.dialogContext, rootNavigator: false);
      if (navigator.canPop()) {
        navigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isMobile = screenWidth < 600;
    final dialogWidth = isMobile ? screenWidth - 32 : screenWidth * 0.5;
    final dialogHeight = isMobile
        ? (screenHeight * 0.9).clamp(500.0, 500.0)
        : (screenHeight * 0.85).clamp(600.0, 900.0);

    return Container(
      width: dialogWidth,
      height: dialogHeight,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        child:

        ProImageEditor.network(
          widget.image,
          configs: _buildEditorConfigs(isMobile: isMobile),
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (editedImage) async {
              widget.onSave?.call(editedImage);
              _closeDialog();
            },
            onCloseEditor: (mode) {
              widget.onCancel?.call();
              _closeDialog();
            },
          ),
        ),
      ),
    );
  }
}

class _EditImageNetworkDialogState extends State<EditImageNetworkDialog> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
