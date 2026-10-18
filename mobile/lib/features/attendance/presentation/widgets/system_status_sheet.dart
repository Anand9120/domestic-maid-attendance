import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/ux4g/ux4g.dart';

/// System Diagnostics & Security Standards Bottom Sheet
///
/// Provides live cloud backend heartbeat verification, GIGW 3.0 / UX4G
/// anti-fraud security engine telemetry, national emergency directory,
/// and platform architecture credits.
class SystemStatusSheet extends StatefulWidget {
  final Dio? dio;

  const SystemStatusSheet({super.key, this.dio});

  static void show(BuildContext context, {Dio? dio}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SystemStatusSheet(dio: dio),
    );
  }

  @override
  State<SystemStatusSheet> createState() => _SystemStatusSheetState();
}

class _SystemStatusSheetState extends State<SystemStatusSheet> {
  bool _isChecking = true;
  bool _isBackendUp = false;
  int? _latencyMs;
  String _serviceName = 'Domestic Maid Attendance Backend';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final client = widget.dio ??
          (sl.isInitialized ? sl.networkClient.dio : Dio());

      final res = await client.get(
        '${ApiConstants.baseUrl}/health',
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      stopwatch.stop();

      if (mounted) {
        if (res.statusCode == 200 && res.data is Map) {
          final data = res.data as Map<String, dynamic>;
          setState(() {
            _isChecking = false;
            _isBackendUp = data['status'] == 'UP';
            _serviceName = data['service']?.toString() ?? 'Domestic Maid Attendance Backend';
            _latencyMs = stopwatch.elapsedMilliseconds;
          });
        } else {
          setState(() {
            _isChecking = false;
            _isBackendUp = false;
            _latencyMs = stopwatch.elapsedMilliseconds;
            _errorMessage = 'Status code: ${res.statusCode}';
          });
        }
      }
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _isChecking = false;
          _isBackendUp = false;
          _latencyMs = stopwatch.elapsedMilliseconds;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;
    final isContrast = a11y.isHighContrast;
    final isHindi = a11y.isHindi;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isContrast ? AppColors.hcBackground : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isContrast ? AppColors.hcBorder : AppColors.border,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: ListView(
            controller: scrollController,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header with Civic Shield
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isContrast ? AppColors.darkSurface : const Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFF0284C7),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'प्रणाली स्थिति एवं सुरक्षा मानक' : 'System Diagnostics & Security',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isContrast ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          isHindi
                              ? 'राष्ट्रीय नागरिक मानक (GIGW 3.0 & UX4G Compliant)'
                              : 'National Civic Standard (GIGW 3.0 & UX4G Compliant)',
                          style: TextStyle(
                            fontSize: 11,
                            color: isContrast ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Section 1: Live Cloud Backend Health Card
              _buildSectionHeader(
                title: isHindi ? '1. लाइव क्लाउड बैकएंड स्थिति' : '1. Live Cloud Backend Status',
                icon: Icons.cloud_done_rounded,
                isContrast: isContrast,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isContrast ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isContrast ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isChecking
                                ? Colors.amber
                                : _isBackendUp
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isChecking
                                ? (isHindi ? 'सर्वर से संपर्क हो रहा है...' : 'Pinging Cloud Server...')
                                : _isBackendUp
                                    ? (isHindi ? 'क्लाउड बैकएंड सक्रिय (200 OK)' : 'Backend Live & Healthy (200 OK)')
                                    : (isHindi ? 'सर्वर ऑफ़लाइन / स्लीप मोड' : 'Backend Offline / Sleep Mode'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isContrast ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (_latencyMs != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isContrast ? Colors.black38 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_latencyMs}ms',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• Service: $_serviceName',
                      style: TextStyle(
                        fontSize: 11,
                        color: isContrast ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '• Host: domestic-maid-attendance-backend.onrender.com',
                      style: TextStyle(
                        fontSize: 11,
                        color: isContrast ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '• Heartbeat: 24/7 Synthetic Ping via UptimeRobot (0s cold-start)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isContrast ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Alert: $_errorMessage',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626)),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(
                              isHindi ? 'पुनः जांचें' : 'Re-check Ping',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: _isChecking ? null : _checkHealth,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.code_rounded, size: 16),
                            label: Text(
                              isHindi ? 'Swagger API' : 'Swagger Docs',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () => _launchUrl('${ApiConstants.baseUrl}/swagger-ui.html'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Section 2: GIGW 3.0 & Anti-Fraud Security Diagnostics
              _buildSectionHeader(
                title: isHindi ? '2. धोखाधड़ी-रोधी सुरक्षा मानक' : '2. Anti-Fraud & GIGW 3.0 Telemetry',
                icon: Icons.shield_rounded,
                isContrast: isContrast,
              ),
              const SizedBox(height: 8),
              _buildSecurityItem(
                icon: Icons.radar_rounded,
                title: isHindi ? 'जियोफेंस परिधि (50-मीटर दायरा)' : 'Geofence Perimeter (50m Radius)',
                desc: isHindi
                    ? 'हवेरसीन (Haversine) गणना द्वारा कार्यस्थल की 50m परिधि का कड़ाई से सत्यापन।'
                    : 'Strict 50-meter workplace boundary enforced via Haversine spherical formula.',
                badge: 'ENFORCED',
                badgeColor: const Color(0xFF16A34A),
                isContrast: isContrast,
              ),
              const SizedBox(height: 8),
              _buildSecurityItem(
                icon: Icons.phonelink_lock_rounded,
                title: isHindi ? 'मॉक GPS रोकथाम (Anti-Spoofing)' : 'Mock GPS Detection (Anti-Spoofing)',
                desc: isHindi
                    ? 'नकली स्थान ऐप (Fake GPS / mock provider) से हाजिरी को तुरंत अस्वीकार करता है।'
                    : 'Android Location Provider spoof verification blocks simulated mock location apps.',
                badge: 'ACTIVE',
                badgeColor: const Color(0xFF16A34A),
                isContrast: isContrast,
              ),
              const SizedBox(height: 8),
              _buildSecurityItem(
                icon: Icons.timer_outlined,
                title: isHindi ? 'ड्वेल टाइम सत्यापन (30 सेकंड)' : 'Dwell-Time Validation (30 Seconds)',
                desc: isHindi
                    ? 'घर के पास से गुजरने पर गलती से हाजिरी न लगे, इसलिए 30s ठहराव अनिवार्य है।'
                    : 'Requires continuous presence inside premises to prevent accidental drive-by check-ins.',
                badge: 'ACTIVE',
                badgeColor: const Color(0xFF0284C7),
                isContrast: isContrast,
              ),
              const SizedBox(height: 8),
              _buildSecurityItem(
                icon: Icons.offline_bolt_rounded,
                title: isHindi ? 'ऑफ़लाइन रेजिलिएंस (Hive DB)' : 'Offline-First Resilience (Hive DB)',
                desc: isHindi
                    ? 'नेटवर्क न होने पर स्थानीय स्तर पर रिकॉर्ड सुरक्षित, ऑनलाइन आते ही स्वतः सिंक।'
                    : 'Events buffered locally in encrypted Hive DB and auto-synchronized upon network restore.',
                badge: 'READY',
                badgeColor: const Color(0xFF7C3AED),
                isContrast: isContrast,
              ),
              const SizedBox(height: 18),

              // Section 3: National Emergency Helplines
              _buildSectionHeader(
                title: isHindi ? '3. राष्ट्रीय आपातकालीन हेल्पलाइन' : '3. National Emergency Directory',
                icon: Icons.emergency_rounded,
                isContrast: isContrast,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildHelplineCard(
                      number: '112',
                      label: isHindi ? 'राष्ट्रीय आपात' : 'National Emergency',
                      color: const Color(0xFFDC2626),
                      onTap: () => _makeCall('112'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildHelplineCard(
                      number: '181',
                      label: isHindi ? 'महिला सुरक्षा' : 'Women Helpline',
                      color: const Color(0xFFEA580C),
                      onTap: () => _makeCall('181'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildHelplineCard(
                      number: '1091',
                      label: isHindi ? 'महिला पुलिस' : 'Women Police',
                      color: const Color(0xFF7C3AED),
                      onTap: () => _makeCall('1091'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Section 4: Architecture & Developer Credits
              _buildSectionHeader(
                title: isHindi ? '4. आर्किटेक्चर एवं डेवलपर विवरण' : '4. Architecture & Developer Credits',
                icon: Icons.info_outline_rounded,
                isContrast: isContrast,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isContrast ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isContrast ? AppColors.darkBorder : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, color: Color(0xFF0F766E), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Architect: Anand Prakash Jaiswal',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isContrast ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Role: Software Engineer (Flutter Specialist & Backend Systems)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isContrast ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '• Current Location: Indore, Madhya Pradesh, India',
                      style: TextStyle(
                        fontSize: 11,
                        color: isContrast ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '• Stack: Flutter 3.x, BLoC 8.x, Spring Boot 3.2, Docker, PostgreSQL',
                      style: TextStyle(
                        fontSize: 11,
                        color: isContrast ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => _launchUrl('https://github.com/Anand9120/domestic-maid-attendance'),
                      child: const Row(
                        children: [
                          Icon(Icons.link_rounded, size: 16, color: Color(0xFF0284C7)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'github.com/Anand9120/domestic-maid-attendance',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF0284C7),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Close Button
              Ux4gButton(
                size: Ux4gButtonSize.medium,
                backgroundColor: isContrast ? AppColors.darkSurface : const Color(0xFF1E293B),
                contentColor: Colors.white,
                leadingIcon: Icons.check_circle_outline,
                text: isHindi ? 'समझ गया (Close)' : 'Done (Close)',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required bool isContrast,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F766E)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isContrast ? Colors.white : const Color(0xFF0F766E),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String desc,
    required String badge,
    required Color badgeColor,
    required bool isContrast,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isContrast ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isContrast ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isContrast ? Colors.black26 : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF0F766E)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isContrast ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 10,
                    color: isContrast ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineCard({
    required String number,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.call_rounded, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
