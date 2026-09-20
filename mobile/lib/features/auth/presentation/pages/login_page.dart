import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ux4g_civic_bar.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'otp_verification_page.dart';
import '../../../household/presentation/pages/employer_registration_page.dart';
import '../../../household/presentation/pages/maid_profile_setup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _phone = '9811122233';
  String _name = 'Sunita Devi';
  UserRole _selectedRole = UserRole.maid;

  void _quickDemoLogin(UserRole role) {
    final phone = role == UserRole.maid ? '+919811122233' : '+919876543210';
    final name = role == UserRole.maid ? 'Sunita Devi' : 'Priya Sharma';
    context.read<AuthBloc>().add(
          VerifyOtpSubmitted(
            phoneNumber: phone,
            otp: '123456',
            role: role,
            fullName: name,
          ),
        );
  }

  void _onGetOtpPressed() {
    final cleanPhone = _phone.trim();
    if (cleanPhone.isEmpty || cleanPhone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    final formattedPhone = cleanPhone.startsWith('+') ? cleanPhone : '+91$cleanPhone';

    context.read<AuthBloc>().add(SendOtpRequested(formattedPhone));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: OtpVerificationPage(
            phoneNumber: formattedPhone,
            role: _selectedRole,
            fullName: _name.trim(),
          ),
        ),
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
          body: SafeArea(
            child: Column(
              children: [
                // UX4G Civic Accessibility Bar (Tricolor + A-/A/A+ + High Contrast + Bilingual)
                const Ux4gCivicBar(),

                // Scrollable Login Content
                Expanded(
                  child: BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.absent,
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Civic Portal Header
                            Center(
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: isContrast
                                      ? Colors.yellow.withOpacity(0.2)
                                      : AppColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isContrast ? Colors.yellow : AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.account_balance_rounded,
                                  size: 36,
                                  color: isContrast ? Colors.yellow : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              a11y.tr('gov_portal_title'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isContrast ? Colors.white : AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              a11y.tr('zero_touch_desc'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isContrast ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // UX4G Styled Form Card
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: isContrast ? AppColors.hcSurface : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isContrast ? AppColors.hcBorder : AppColors.border,
                                  width: isContrast ? 2 : 1,
                                ),
                                boxShadow: isContrast
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 14,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Role Selector
                                  Text(
                                    a11y.tr('select_role'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isContrast ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildRoleButton(
                                          role: UserRole.maid,
                                          label: a11y.tr('maid_role'),
                                          icon: Icons.person_outline_rounded,
                                          isContrast: isContrast,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildRoleButton(
                                          role: UserRole.employer,
                                          label: a11y.tr('employer_role'),
                                          icon: Icons.home_work_outlined,
                                          isContrast: isContrast,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Full Name Field (Ux4gInputField)
                                  Ux4gInputField(
                                    value: _name,
                                    onValueChange: (val) => setState(() => _name = val),
                                    label: a11y.tr('full_name'),
                                    required: true,
                                    placeholder: 'e.g. Sunita Devi',
                                    leadingIcon: Icons.badge_outlined,
                                    size: Ux4gInputFieldSize.large,
                                  ),
                                  const SizedBox(height: 18),

                                  // Phone Number Field (Ux4gInputField)
                                  Ux4gInputField(
                                    value: _phone,
                                    onValueChange: (val) => setState(() => _phone = val),
                                    label: a11y.tr('phone_number'),
                                    required: true,
                                    placeholder: '9811122233',
                                    prefixText: '+91 ',
                                    type: Ux4gInputFieldType.number,
                                    leadingIcon: Icons.phone_android_rounded,
                                    size: Ux4gInputFieldSize.large,
                                  ),
                                  const SizedBox(height: 26),

                                  // Submit Button (Ux4gButton)
                                  BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                      return SizedBox(
                                        width: double.infinity,
                                        child: Ux4gButton(
                                          text: a11y.tr('get_otp'),
                                          variant: Ux4gButtonVariant.primary,
                                          size: Ux4gButtonSize.large,
                                          isLoading: state is AuthLoading,
                                          leadingIcon: Icons.verified_user_outlined,
                                          onPressed: _onGetOtpPressed,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                   // 1-Tap Offline Demo Mode (Works with or without backend server)
                                   Container(
                                     padding: const EdgeInsets.all(14),
                                     decoration: BoxDecoration(
                                       color: isContrast ? AppColors.hcSurface : const Color(0xFFF0FDF4),
                                       borderRadius: BorderRadius.circular(10),
                                       border: Border.all(
                                         color: isContrast ? Colors.yellow : const Color(0xFF86EFAC),
                                         width: isContrast ? 2 : 1.5,
                                       ),
                                     ),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.stretch,
                                       children: [
                                         Row(
                                           children: [
                                             Icon(
                                               Icons.bolt_rounded,
                                               size: 20,
                                               color: isContrast ? Colors.yellow : const Color(0xFF16A34A),
                                             ),
                                             const SizedBox(width: 8),
                                             Expanded(
                                               child: Text(
                                                 '1-Tap Offline Demo (बिना सर्वर के लॉगिन)',
                                                 style: TextStyle(
                                                   fontSize: 12,
                                                   fontWeight: FontWeight.bold,
                                                   color: isContrast ? Colors.yellow : const Color(0xFF15803D),
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ),
                                         const SizedBox(height: 10),
                                         Row(
                                           children: [
                                             Expanded(
                                               child: SizedBox(
                                                 height: 48,
                                                 child: ElevatedButton(
                                                   style: ElevatedButton.styleFrom(
                                                     backgroundColor: isContrast ? Colors.yellow : const Color(0xFF16A34A),
                                                     foregroundColor: isContrast ? Colors.black : Colors.white,
                                                     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                     elevation: 0,
                                                   ),
                                                   onPressed: () => _quickDemoLogin(UserRole.maid),
                                                   child: Row(
                                                     mainAxisAlignment: MainAxisAlignment.center,
                                                     children: [
                                                       const Icon(Icons.person_rounded, size: 16),
                                                       const SizedBox(width: 4),
                                                       Flexible(
                                                         child: FittedBox(
                                                           fit: BoxFit.scaleDown,
                                                           child: Text(
                                                             'Maid Demo\nसुनीता देवी',
                                                             textAlign: TextAlign.center,
                                                             style: TextStyle(
                                                               fontSize: 11,
                                                               fontWeight: FontWeight.bold,
                                                               height: 1.15,
                                                               color: isContrast ? Colors.black : Colors.white,
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                     ],
                                                   ),
                                                 ),
                                               ),
                                             ),
                                             const SizedBox(width: 8),
                                             Expanded(
                                               child: SizedBox(
                                                 height: 48,
                                                 child: ElevatedButton(
                                                   style: ElevatedButton.styleFrom(
                                                     backgroundColor: isContrast ? Colors.black : const Color(0xFF4338CA),
                                                     foregroundColor: Colors.white,
                                                     side: isContrast ? const BorderSide(color: Colors.yellow) : null,
                                                     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                     elevation: 0,
                                                   ),
                                                   onPressed: () => _quickDemoLogin(UserRole.employer),
                                                   child: const Row(
                                                     mainAxisAlignment: MainAxisAlignment.center,
                                                     children: [
                                                       Icon(Icons.home_work_rounded, size: 16),
                                                       SizedBox(width: 4),
                                                       Flexible(
                                                         child: FittedBox(
                                                           fit: BoxFit.scaleDown,
                                                           child: Text(
                                                             'Employer Demo\nप्रिया शर्मा',
                                                             textAlign: TextAlign.center,
                                                             style: TextStyle(
                                                               fontSize: 11,
                                                               fontWeight: FontWeight.bold,
                                                               height: 1.15,
                                                               color: Colors.white,
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                     ],
                                                   ),
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ),
                                       ],
                                     ),
                                   ),
                                   const SizedBox(height: 20),

                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: isContrast ? Colors.white38 : Colors.grey.shade300)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          'NEW REGISTRATION',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                            color: isContrast ? Colors.yellow : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: isContrast ? Colors.white38 : Colors.grey.shade300)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Register Employer Household
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(double.infinity, 48),
                                        side: BorderSide(
                                          color: isContrast ? Colors.yellow : AppColors.primary,
                                        ),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      icon: Icon(
                                        Icons.add_home_work_rounded,
                                        size: 18,
                                        color: isContrast ? Colors.yellow : AppColors.primary,
                                      ),
                                      label: Text(
                                        'Register New Household (नया घर जोड़ें)',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isContrast ? Colors.yellow : AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const EmployerRegistrationPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Maid Profile & Linking
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(double.infinity, 48),
                                        side: BorderSide(
                                          color: isContrast ? Colors.white70 : Colors.grey.shade400,
                                        ),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      icon: Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: 18,
                                        color: isContrast ? Colors.white : AppColors.textPrimary,
                                      ),
                                      label: Text(
                                        'Maid Profile & Onboarding (सहायिका प्रोफ़ाइल)',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isContrast ? Colors.white : AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const MaidProfileSetupPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleButton({
    required UserRole role,
    required String label,
    required IconData icon,
    required bool isContrast,
  }) {
    final isSelected = _selectedRole == role;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Role selection: $label',
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = role;
            if (role == UserRole.employer) {
              _phone = '9876543210';
              _name = 'Priya Sharma';
            } else {
              _phone = '9811122233';
              _name = 'Sunita Devi';
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 52, // >= 48dp GIGW touch target
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isContrast ? Colors.yellow : AppColors.primary.withOpacity(0.08))
                : (isContrast ? Colors.black : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? (isContrast ? Colors.yellow : AppColors.primary)
                  : (isContrast ? Colors.white38 : AppColors.border),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? (isContrast ? Colors.black : AppColors.primary)
                    : (isContrast ? Colors.white70 : AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (isContrast ? Colors.black : AppColors.primary)
                        : (isContrast ? Colors.white : AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
