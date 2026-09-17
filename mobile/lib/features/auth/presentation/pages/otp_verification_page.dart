import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ux4g_flutter_components/ux4g_flutter_components.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ux4g_civic_bar.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final UserRole role;
  final String fullName;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.role,
    required this.fullName,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  String _otp = '123456';

  void _onVerifyPressed() {
    final cleanOtp = _otp.trim();
    if (cleanOtp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6-digit verification code')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          VerifyOtpSubmitted(
            phoneNumber: widget.phoneNumber,
            otp: cleanOtp,
            role: widget.role,
            fullName: widget.fullName,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;

    return ListenableBuilder(
      listenable: a11y,
      builder: (context, _) {
        final isContrast = a11y.isHighContrast;

        return Scaffold(
          backgroundColor: isContrast ? AppColors.hcBackground : AppColors.background,
          appBar: AppBar(
            backgroundColor: isContrast ? Colors.black : AppColors.primary,
            foregroundColor: Colors.white,
            title: Text(
              a11y.tr('verify_phone'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const Ux4gCivicBar(showTitle: false),
                Expanded(
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthAuthenticated) {
                        Navigator.pop(context);
                      } else if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.absent,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 16),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isContrast
                                        ? Colors.yellow.withOpacity(0.2)
                                        : AppColors.primary.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isContrast ? Colors.yellow : AppColors.primary,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.sms_outlined,
                                    size: 38,
                                    color: isContrast ? Colors.yellow : AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                a11y.tr('enter_code'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isContrast ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${a11y.tr('code_sent_to')} ${widget.phoneNumber}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isContrast ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // UX4G Status Banner for Demo OTP
                              Ux4gStatusBanner(
                                variant: Ux4gBannerVariant.infoLight,
                                title: a11y.tr('test_mode_otp'),
                                leadingIcon: const Icon(Icons.info_outline, size: 20, color: Color(0xFF0B4D8C)),
                              ),
                              const SizedBox(height: 24),

                              // 6-digit OTP Input using Ux4gInputField
                              Ux4gInputField(
                                value: _otp,
                                onValueChange: (val) => setState(() => _otp = val),
                                label: a11y.tr('enter_code'),
                                required: true,
                                placeholder: '123456',
                                maxLength: 6,
                                type: Ux4gInputFieldType.number,
                                textAlign: TextAlign.center,
                                size: Ux4gInputFieldSize.large,
                                leadingIcon: Icons.lock_clock_outlined,
                              ),
                              const SizedBox(height: 28),

                              // UX4G Verify Button
                              SizedBox(
                                width: double.infinity,
                                child: Ux4gButton(
                                  text: a11y.tr('verify_continue'),
                                  size: Ux4gButtonSize.large,
                                  isLoading: state is AuthLoading,
                                  leadingIcon: Icons.check_circle_outline,
                                  onPressed: _onVerifyPressed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
