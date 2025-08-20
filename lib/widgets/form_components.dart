import 'package:flutter/material.dart';
import '../utils/theme.dart';

class EnhancedTextField extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          autofocus: autofocus,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onEditingComplete: onEditingComplete,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

class EnhancedDropdownField<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
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
    this.errorText,
    this.value,
    required this.items,
    required this.itemText,
    this.onChanged,
    this.enabled = true,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemText(item),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon,
          ),
          validator: validator,
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
        ),
      ],
    );
  }
}

class EnhancedDateField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final FormFieldValidator<DateTime>? validator;

  const EnhancedDateField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.selectedDate,
    this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
        ],
        TextFormField(
          readOnly: true,
          enabled: enabled,
          controller: TextEditingController(
            text: selectedDate != null
                ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
                : '',
          ),
          decoration: InputDecoration(
            hintText: hint ?? 'Pilih tanggal',
            helperText: helperText,
            errorText: errorText,
            prefixIcon: const Icon(Icons.calendar_today),
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
          ),
          onTap: enabled ? () => _selectDate(context) : null,
          validator: validator != null
              ? (value) {
                  if (selectedDate == null) {
                    return 'Tanggal harus dipilih';
                  }
                  return validator!(selectedDate!);
                }
              : null,
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
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
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && onDateSelected != null) {
      onDateSelected!(picked);
    }
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
  final bool enabled;

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
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
        ],
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${value.toInt()}%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (labelBuilder != null)
                    Text(
                      labelBuilder!(value),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),
              Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: enabled ? onChanged : null,
                activeColor: AppTheme.primaryColor,
                inactiveColor: AppTheme.borderColor,
              ),
            ],
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppTheme.spacing8),
          Text(
            helperText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class EnhancedCheckboxField extends StatelessWidget {
  final String label;
  final String? helperText;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;

  const EnhancedCheckboxField({
    super.key,
    required this.label,
    this.helperText,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: AppTheme.primaryColor,
            ),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: enabled ? AppTheme.textPrimary : AppTheme.textTertiary,
                ),
              ),
            ),
          ],
        ),
        if (helperText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: AppTheme.spacing48),
            child: Text(
              helperText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class EnhancedRadioGroup<T> extends StatelessWidget {
  final String? label;
  final String? helperText;
  final T? value;
  final List<T> items;
  final String Function(T) itemText;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const EnhancedRadioGroup({
    super.key,
    this.label,
    this.helperText,
    this.value,
    required this.items,
    required this.itemText,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
        ],
        ...items.map((item) => RadioListTile<T>(
          title: Text(
            itemText(item),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: enabled ? AppTheme.textPrimary : AppTheme.textTertiary,
            ),
          ),
          value: item,
          groupValue: value,
          onChanged: enabled ? onChanged : null,
          activeColor: AppTheme.primaryColor,
          contentPadding: EdgeInsets.zero,
        )),
        if (helperText != null) ...[
          const SizedBox(height: AppTheme.spacing8),
          Text(
            helperText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
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
  final EdgeInsetsGeometry? padding;

  const FormSection({
    super.key,
    this.title,
    this.subtitle,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.spacing4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spacing20),
          ],
          ...children.map((child) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacing20),
            child: child,
          )),
        ],
      ),
    );
  }
} 