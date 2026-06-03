import '../../utils/exports.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.onSubmitted,
    this.borderColor,
    this.textAlign,
    this.hintColor,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.height,
    this.autofocus = false,
    this.readOnly = false,
    this.expands = false,
    this.radius,
    this.focusNode,
    this.cursorColor,
    this.fillColor,
    this.onTap,
    this.errorBorderSide,
    this.focusedErrorBorderSide,
    this.textInputAction,
    this.textCapitalization,
    this.textStyle,
    this.maxLine = 1,
  });

  final String hintText;
  final int? maxLength;
  final int? maxLine;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final bool obscureText;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final double? height;
  final bool autofocus;
  final bool readOnly;
  final bool expands;
  final BorderRadius? radius;
  final TextAlign? textAlign;
  final TextStyle? textStyle;

  final FocusNode? focusNode;
  final Color? fillColor;
  final Color? hintColor;
  final Color? borderColor;
  final Color? cursorColor;
  final void Function()? onTap;
  final BorderSide? errorBorderSide;
  final BorderSide? focusedErrorBorderSide;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: textAlign ?? TextAlign.left,
      focusNode: focusNode,
      maxLength: maxLength,
      maxLines: maxLine,
      expands: expands,
      readOnly: readOnly,
      onTap: onTap,
      autofocus: autofocus,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      onFieldSubmitted: onSubmitted,
      keyboardType: keyboardType,
      controller: controller,
      cursorColor: cursorColor ?? AppColors.black002432,
      textInputAction: textInputAction ?? TextInputAction.done,
      textCapitalization: textCapitalization != null
          ? textCapitalization!
          : keyboardType == TextInputType.emailAddress
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      textAlignVertical: TextAlignVertical.top,
      style: textStyle ?? AppTextStyle.medium16(),
      decoration: InputDecoration(
        fillColor: AppColors.whiteColor,
        filled: true,
        counterText: '',
        hintText: hintText,
        // hint: Padding(
        //   padding: const EdgeInsets.only(left: 20),
        //   child: Text(hintText, style: AppTextStyle.regular16(color: AppColors.greyADB9BD)),
        // ),
        hintStyle: AppTextStyle.regular16(color: AppColors.greyADB9BD),
        prefixIcon: prefixIcon != null ? SizedBox(height: 24, width: 24, child: Center(child: prefixIcon)) : null,
        suffixIcon: suffixIcon != null ? SizedBox(height: 24, width: 24, child: Center(child: suffixIcon)) : null,
        contentPadding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.025, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: radius ?? BorderRadius.circular(24),
          borderSide: BorderSide(color: borderColor ?? AppColors.greyADB9BD, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius ?? BorderRadius.circular(24),
          borderSide: BorderSide(color: borderColor ?? AppColors.greyADB9BD, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius ?? BorderRadius.circular(24),
          borderSide: BorderSide(color: borderColor ?? AppColors.greyADB9BD, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius ?? BorderRadius.circular(24),
          borderSide: BorderSide(color: borderColor ?? Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius ?? BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.greyADB9BD, width: 1),
        ),
      ),
    );
  }
}
