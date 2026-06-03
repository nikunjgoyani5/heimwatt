import '../../utils/exports.dart';

class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final bool? isTextScroll;

  const AppText(this.data, {super.key, this.style, this.maxLines, this.textAlign, this.isTextScroll});

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      data,
      maxLines: maxLines,

      minLines: 1,
      style: style,
      textAlign: textAlign,
      scrollPhysics: (isTextScroll ?? false) ? null : NeverScrollableScrollPhysics(),
      selectionColor: AppColors.primaryColor.withValues(alpha: 0.4),
    );
  }
}
