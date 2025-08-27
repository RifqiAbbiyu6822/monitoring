// lib/widgets/form_components.dart - Complete Enhanced Form Components
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class EnhancedTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  const EnhancedTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.validator,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.inputFormatters,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;

  late Animation<Color?> _borderColorAnimation;

  bool get _hasText => widget.controller?.text.isNotEmpty ?? false;
  bool get _isFocused => _focusNode.hasFocus;
  bool get _shouldFloatLabel => _isFocused || _hasText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );



    _borderColorAnimation = ColorTween(
      begin: AppTheme.borderColor,
      end: AppTheme.primaryColor,
    ).animate(_animationController);

    _focusNode.addListener(_onFocusChange);
    widget.controller?.addListener(_onTextChange);

    // Set initial animation state
    if (_shouldFloatLabel) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_isFocused || _hasText) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {});
  }

  void _onTextChange() {
    final shouldAnimate = _hasText || _isFocused;
    if (shouldAnimate && !_animationController.isCompleted) {
      _animationController.forward();
    } else if (!shouldAnimate && _animationController.isCompleted) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _isFocused ? AppTheme.primaryColor : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                enabled: widget.enabled,
                onTap: widget.onTap,
                onChanged: widget.onChanged,
                validator: widget.validator,
                autofocus: widget.autofocus,
                textInputAction: widget.textInputAction,
                onEditingComplete: widget.onEditingComplete,
                onFieldSubmitted: widget.onFieldSubmitted,
                inputFormatters: widget.inputFormatters,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  helperText: widget.helperText,
                  errorText: widget.errorText,
                  prefixIcon: widget.prefixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: widget.prefixIcon,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  counterText: widget.maxLength != null ? '' : null,
                  filled: true,
                  fillColor: _isFocused
                      ? Colors.white
                      : const Color(0xFFF8FAFC),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: widget.prefixIcon != null ? 12 : 20,
                    vertical: widget.maxLines == 1 ? 16 : 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.borderColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _borderColorAnimation.value ?? AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.errorColor,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.errorColor,
                      width: 2,
                    ),
                  ),
                  hintStyle: TextStyle(
                    color: AppTheme.textTertiary,
                    fontWeight: FontWeight.w400,
                  ),
                  helperStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EnhancedDropdownField<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final T? value;
  final List<T> items;
  final String Function(T) itemText;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final Widget? prefixIcon;
  final FormFieldValidator<T>? validator;

  const EnhancedDropdownField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.value,
    required this.items,
    required this.itemText,
    this.onChanged,
    this.enabled = true,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<EnhancedDropdownField<T>> createState() => _EnhancedDropdownFieldState<T>();
}

class _EnhancedDropdownFieldState<T> extends State<EnhancedDropdownField<T>> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: _isFocused ? AppTheme.primaryColor : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            focusNode: _focusNode,
            items: widget.items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    widget.itemText(item),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: widget.enabled ? widget.onChanged : null,
            decoration: InputDecoration(
              hintText: widget.hint,
              helperText: widget.helperText,
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: widget.prefixIcon,
                    )
                  : null,
              filled: true,
              fillColor: _isFocused ? Colors.white : const Color(0xFFF8FAFC),
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? 12 : 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.borderColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              hintStyle: TextStyle(
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.w400,
              ),
            ),
            validator: widget.validator,
            icon: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _isFocused ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
            isExpanded: true,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
          ),
        ),
      ],
    );
  }
}

class EnhancedDateField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final bool enabled;
  final Widget? prefixIcon;
  final FormFieldValidator<DateTime>? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const EnhancedDateField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.selectedDate,
    this.onDateSelected,
    this.enabled = true,
    this.prefixIcon,
    this.validator,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
        ],
        FormField<DateTime>(
          initialValue: selectedDate,
          validator: validator,
          builder: (FormFieldState<DateTime> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: enabled ? () => _selectDate(context, state) : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.hasError 
                            ? AppTheme.errorColor 
                            : AppTheme.borderColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (prefixIcon != null) ...[
                          prefixIcon!,
                          const SizedBox(width: 12),
                        ] else ...[
                          Icon(
                            Icons.calendar_today,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            selectedDate != null
                                ? _formatDate(selectedDate!)
                                : hint ?? 'Pilih tanggal',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: selectedDate != null
                                  ? AppTheme.textPrimary
                                  : AppTheme.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.hasError) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.errorText!,
                    style: const TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (helperText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    helperText!,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, FormFieldState<DateTime> state) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      state.didChange(picked);
      onDateSelected?.call(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class EnhancedSliderField extends StatelessWidget {
  final String? label;
  final String? helperText;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final String Function(double)? labelBuilder;

  const EnhancedSliderField({
    super.key,
    this.label,
    this.helperText,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.onChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  labelBuilder?.call(value) ?? value.toStringAsFixed(0),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: AppTheme.borderColor,
            thumbColor: AppTheme.primaryColor,
            overlayColor: AppTheme.primaryColor.withOpacity(0.1),
            valueIndicatorColor: AppTheme.primaryColor,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: Colors.transparent,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            label: labelBuilder?.call(value) ?? value.toStringAsFixed(0),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 8),
          Text(
            helperText!,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class FormSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;

  const FormSection({
    super.key,
    this.title,
    this.subtitle,
    required this.children,
    this.action,
    this.padding,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...children.map((child) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: child,
        )),
        if (showDivider) ...[
          const SizedBox(height: 8),
          Divider(
            color: AppTheme.borderColor.withOpacity(0.3),
            height: 1,
            thickness: 0.5,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final bool isOutlined;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double elevation;
  final double? width;

  const EnhancedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.isOutlined = false,
    this.padding,
    this.borderRadius = 12,
    this.elevation = 0,
    this.width,
  });

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? 
        (widget.isOutlined ? Colors.transparent : AppTheme.primaryColor);
    final foregroundColor = widget.foregroundColor ?? 
        (widget.isOutlined ? AppTheme.primaryColor : Colors.white);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width ?? double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: widget.elevation > 0 && !widget.isOutlined
                  ? [
                      BoxShadow(
                        color: backgroundColor.withOpacity(0.3),
                        blurRadius: widget.elevation * 2,
                        offset: Offset(0, widget.elevation),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed,
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Container(
                  padding: widget.padding ?? 
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: widget.isOutlined
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          border: Border.all(
                            color: AppTheme.primaryColor,
                            width: 1.5,
                          ),
                        )
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading) ...[
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ] else if (widget.icon != null) ...[
                        widget.icon!,
                        const SizedBox(width: 12),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: foregroundColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool hasShadow;
  final double borderRadius;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.hasShadow = true,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.1),
          width: 0.5,
        ),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}