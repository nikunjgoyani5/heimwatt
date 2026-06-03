import '../../utils/exports.dart';

class CommonButton extends StatefulWidget {
  const CommonButton({
    super.key,
    required this.text,
    this.width,
    this.height,
    required this.onTap,
    this.color,
    this.textColor,
    this.icon,
    this.borderRadius,
    this.border,
    this.showArrow = true,
    this.padding,
    this.boxShadow,
    this.hoverColor,
    this.child,
  });

  final String text;
  final double? width;
  final double? height;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final BorderRadius? borderRadius;
  final Border? border;
  final bool showArrow;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final Color? hoverColor;
  final Widget? child; // Custom child widget (if provided, text and icon are ignored)

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? AppColors.primaryColor;
    // Darken the color by blending with black for a more noticeable hover effect
    final hoverColorValue = widget.hoverColor ?? AppColors.hoverColor;
    final currentColor = _isHovered ? hoverColorValue : baseColor;

    return MouseRegion(
      cursor:widget.color==AppColors.lightThemeColor? SystemMouseCursors.basic: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: widget.height ?? 56,
          width: widget.width ?? 260,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(30),
            border: widget.border,
            boxShadow: widget.boxShadow,
          ),
          child:
              widget.child ??
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: widget.textColor ?? AppColors.black002432),
                    const Gap(12),
                  ],
                  Text(widget.text, style: AppTextStyle.semiBold16(color: widget.textColor ?? AppColors.black002432)),
                  if (widget.showArrow && widget.icon == null) ...[
                    const Gap(12),
                    Icon(Icons.arrow_forward_ios, size: 18, color: widget.textColor ?? AppColors.black002432),
                  ],
                ],
              ),
        ),
      ),
    );
  }
}
