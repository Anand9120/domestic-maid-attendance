import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/form_validators.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: FormValidators.phoneFormatters,
      validator: (val) => FormValidators.validateIndianPhoneNumber(val),
      decoration: InputDecoration(
        labelText: 'Mobile Number',
        hintText: '9876543210',
        counterText: '',
        errorText: errorText,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.phone_iphone_rounded, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                '+91',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                height: 20,
                child: VerticalDivider(color: AppColors.border, thickness: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
