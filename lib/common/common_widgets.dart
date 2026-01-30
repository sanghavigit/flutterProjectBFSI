import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? letterSpacing;
  final double? height;

  const CustomText(
    this.text, {
    super.key,
    this.fontSize,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.letterSpacing,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize ?? 14,
        color: color ?? Colors.black,
        fontWeight: fontWeight ?? FontWeight.normal,
        letterSpacing: letterSpacing,
        height: height,
      ),
    );
  }
}

class CommonTextFormField extends StatefulWidget {
  const CommonTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final bool showObscureToggle;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  @override
  State<CommonTextFormField> createState() => _CommonTextFormFieldState();
}

class _CommonTextFormFieldState extends State<CommonTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.showObscureToggle ? _obscureText : widget.obscureText,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const UnderlineInputBorder(),
        prefixIcon:
        widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.showObscureToggle
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
      ),
    );
  }
}


class Space extends StatelessWidget {
  final double width;
  final double height;

  const Space({super.key, this.width = 0, this.height = 0});

  /// Vertical spacing helper
  static Widget vertical(double height) => SizedBox(height: height);

  /// Horizontal spacing helper
  static Widget horizontal(double width) => SizedBox(width: width);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}

enum ButtonType { elevated, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;

  static const EdgeInsets _defaultPadding = EdgeInsets.symmetric(vertical: 16);

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.elevated,
    this.width,
    this.height = 50,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius = 8,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final effectiveBorderRadius = borderRadius ?? 8;
    final effectivePadding = padding ?? _defaultPadding;

    switch (type) {
      case ButtonType.elevated:
        final effectiveBg = backgroundColor ?? primaryColor;
        final effectiveTextColor = textColor ?? Colors.white;
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: effectiveBg,
              foregroundColor: effectiveTextColor,
              padding: effectivePadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
              ),
            ),
            onPressed: onPressed,
            child: CustomText(
              text,
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: effectiveTextColor,
            ),
          ),
        );

      case ButtonType.outlined:
        final effectiveFg = textColor ?? primaryColor;
        final effectiveBorder = borderColor ?? primaryColor;
        return SizedBox(
          width: width,
          height: height,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: effectiveFg,
              side: BorderSide(color: effectiveBorder),
              padding: effectivePadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
              ),
            ),
            onPressed: onPressed,
            child: CustomText(
              text,
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: effectiveFg,
            ),
          ),
        );

      case ButtonType.text:
        final effectiveFg = textColor ?? primaryColor;
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: effectiveFg,
              padding: effectivePadding,
            ),
            onPressed: onPressed,
            child: CustomText(
              text,
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: effectiveFg,
            ),
          ),
        );
    }
  }
}

