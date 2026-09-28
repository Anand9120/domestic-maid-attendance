import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../../../core/widgets/ux4g_civic_bar.dart';
import '../../../attendance/presentation/widgets/live_gps_map_radar_widget.dart';

class GeofenceMapSetupPage extends StatefulWidget {
  final int employerId;

  const GeofenceMapSetupPage({super.key, required this.employerId});

  @override
  State<GeofenceMapSetupPage> createState() => _GeofenceMapSetupPageState();
}

class _GeofenceMapSetupPageState extends State<GeofenceMapSetupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _houseName = 'Sudama Nagar Residence - 3962E';
  String _address = '3962E, Sector E, Sudama Nagar, Indore, MP 452001';
  String _latStr = '22.6914000';
  String _lonStr = '75.8325000';

  String? _houseNameError;
  String? _addressError;
  String? _latError;
  String? _lonError;

  double _geofenceRadius = 50.0;
  double _dwellTimeMinutes = 3.0;
  bool _isSaving = false;
  bool _isDetectingLocation = false;
  Position? _currentDevicePosition;

  @override
  void initState() {
    super.initState();
    _fetchInitialGpsPosition();
  }

  Future<void> _fetchInitialGpsPosition() async {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getLastKnownPosition();
        if (pos != null && mounted) {
          setState(() => _currentDevicePosition = pos);
        }
      }
    } catch (_) {}
  }

  Future<void> _detectCurrentLocation() async {
    final a11y = AccessibilityController.instance;
    final isHindi = a11y.isHindi;

    setState(() => _isDetectingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _isDetectingLocation = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isHindi
                    ? 'स्थान अनुमति स्थायी रूप से अस्वीकृत है। सेटिंग्स में सक्षम करें।'
                    : 'Location permission permanently denied. Enable in app settings.',
              ),
              backgroundColor: AppColors.absent,
            ),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentDevicePosition = pos;
          _latStr = pos.latitude.toStringAsFixed(7);
          _lonStr = pos.longitude.toStringAsFixed(7);
          _latError = null;
          _lonError = null;
          _isDetectingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isHindi
                  ? '📍 लाइव GPS स्थान अधिग्रहित (सटीकता: ±${pos.accuracy.toStringAsFixed(1)}m)'
                  : '📍 Live GPS coordinates acquired (Accuracy: ±${pos.accuracy.toStringAsFixed(1)}m)',
            ),
            backgroundColor: AppColors.present,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDetectingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ GPS error: $e'),
            backgroundColor: AppColors.absent,
          ),
        );
      }
    }
  }

  bool _validateForm({required bool isHindi}) {
    final hErr = FormValidators.validateHouseName(_houseName, isHindi: isHindi);
    final aErr = FormValidators.validateAddress(_address, isHindi: isHindi);
    final latErr = FormValidators.validateLatitude(_latStr, isHindi: isHindi);
    final lonErr = FormValidators.validateLongitude(_lonStr, isHindi: isHindi);

    setState(() {
      _houseNameError = hErr;
      _addressError = aErr;
      _latError = latErr;
      _lonError = lonErr;
    });

    return hErr == null && aErr == null && latErr == null && lonErr == null;
  }

  Future<void> _onSaveSetup() async {
    final a11y = AccessibilityController.instance;
    final isHindi = a11y.isHindi;

    if (!_validateForm(isHindi: isHindi)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi
                ? 'कृपया फॉर्म की त्रुटियों को सुधारें'
                : 'Please fix validation errors in the form',
          ),
          backgroundColor: AppColors.absent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final parsedLat = double.parse(_latStr.trim());
      final parsedLon = double.parse(_lonStr.trim());

      final payload = {
        'employerId': widget.employerId,
        'houseName': _houseName.trim(),
        'address': _address.trim(),
        'latitude': parsedLat,
        'longitude': parsedLon,
        'geofenceRadiusMeters': _geofenceRadius.toInt(),
        'dwellTimeMinutes': _dwellTimeMinutes.toInt(),
      };

      await sl.setupHouseholdUseCase.execute(payload);
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isHindi
                  ? '✅ घरेलू जियोफेंस व समय सीमा सर्वर पर सुरक्षित सहेजी गई!'
                  : '✅ Household geofence & dwell settings saved to server!',
            ),
            backgroundColor: AppColors.present,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Server error: $e'),
            backgroundColor: AppColors.absent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;

    return ListenableBuilder(
      listenable: a11y,
      builder: (context, _) {
        final isContrast = a11y.isHighContrast;
        final isHindi = a11y.isHindi;

        final currentTargetLat = double.tryParse(_latStr) ?? 28.6315;
        final currentTargetLon = double.tryParse(_lonStr) ?? 77.2167;

        return Scaffold(
          backgroundColor: isContrast ? AppColors.hcBackground : AppColors.background,
          appBar: AppBar(
            backgroundColor: isContrast ? AppColors.hcSurface : AppColors.primary,
            elevation: 0,
            title: Text(
              isHindi ? 'जियोफेंस एवं उपस्थिति परिधि' : 'Household Geofence Calibration',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            actions: [
              IconButton(
                tooltip: a11y.isHindi ? 'Switch to English' : 'हिंदी में बदलें',
                icon: const Icon(Icons.translate_rounded),
                onPressed: () => a11y.toggleLocale(),
              ),
              IconButton(
                tooltip: a11y.isHighContrast ? 'Standard Contrast' : 'High Contrast (WCAG AAA)',
                icon: Icon(a11y.isHighContrast ? Icons.contrast_rounded : Icons.tonality_rounded),
                onPressed: () => a11y.toggleHighContrast(),
              ),
            ],
          ),
          body: Column(
            children: [
              const Ux4gCivicBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Live GPS Sonar Radar Widget
                        LiveGpsMapRadarWidget(
                          targetLat: currentTargetLat,
                          targetLon: currentTargetLon,
                          houseName: _houseName.isNotEmpty ? _houseName : 'Household Geofence',
                          geofenceRadiusMeters: _geofenceRadius,
                          currentPosition: _currentDevicePosition,
                          isContrast: isContrast,
                          isInteractive: true,
                          onRefreshGps: _detectCurrentLocation,
                          onCoordinateTapped: (coords) {
                            setState(() {
                              _latStr = coords.lat.toStringAsFixed(7);
                              _lonStr = coords.lon.toStringAsFixed(7);
                              _latError = null;
                              _lonError = null;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isHindi
                              ? '💡 टिप: नक्शे पर कहीं भी टैप करके घर का केंद्र बिंदु बदलें।'
                              : '💡 Tip: Tap anywhere on radar canvas to relocate household center pin.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isContrast ? Colors.white70 : AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Form Fields Card (UX4G Card)
                        Ux4gCard(
                          elevation: 2.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isHindi ? 'घर / परिसर का विवरण' : 'Premises & Geofence Details',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isContrast ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isHindi
                                    ? 'उपस्थिति सत्यापन हेतु सटीक पता और निर्देशांक निर्धारित करें।'
                                    : 'Set exact coordinates for zero-touch physical dwell verification.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isContrast ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // House Name Input
                              Ux4gInputField(
                                value: _houseName,
                                onValueChange: (val) {
                                  setState(() {
                                    _houseName = val;
                                    if (_houseNameError != null) {
                                      _houseNameError = FormValidators.validateHouseName(val, isHindi: isHindi);
                                    }
                                  });
                                },
                                label: isHindi ? 'घर / फ्लैट का नाम' : 'House / Flat Name',
                                required: true,
                                placeholder: 'e.g. Sharma Residence - Flat 402',
                                caption: _houseNameError,
                                status: _houseNameError != null
                                    ? Ux4gInputFieldStatus.error
                                    : Ux4gInputFieldStatus.defaultStatus,
                                leadingIcon: Icons.home_outlined,
                                size: Ux4gInputFieldSize.large,
                              ),
                              const SizedBox(height: 14),

                              // Address Input
                              Ux4gInputField(
                                value: _address,
                                onValueChange: (val) {
                                  setState(() {
                                    _address = val;
                                    if (_addressError != null) {
                                      _addressError = FormValidators.validateAddress(val, isHindi: isHindi);
                                    }
                                  });
                                },
                                label: isHindi ? 'विस्तृत पता' : 'Physical Street Address',
                                required: true,
                                placeholder: 'Full physical address with locality & PIN',
                                caption: _addressError,
                                status: _addressError != null
                                    ? Ux4gInputFieldStatus.error
                                    : Ux4gInputFieldStatus.defaultStatus,
                                leadingIcon: Icons.location_on_outlined,
                                size: Ux4gInputFieldSize.large,
                              ),
                              const SizedBox(height: 14),

                              // Coordinates Row (Latitude / Longitude)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Ux4gInputField(
                                      value: _latStr,
                                      onValueChange: (val) {
                                        setState(() {
                                          _latStr = val;
                                          if (_latError != null) {
                                            _latError = FormValidators.validateLatitude(val, isHindi: isHindi);
                                          }
                                        });
                                      },
                                      label: isHindi ? 'अक्षांश (Lat)' : 'Latitude',
                                      required: true,
                                      placeholder: '28.6315',
                                      caption: _latError,
                                      status: _latError != null
                                          ? Ux4gInputFieldStatus.error
                                          : Ux4gInputFieldStatus.defaultStatus,
                                      leadingIcon: Icons.explore_outlined,
                                      size: Ux4gInputFieldSize.large,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Ux4gInputField(
                                      value: _lonStr,
                                      onValueChange: (val) {
                                        setState(() {
                                          _lonStr = val;
                                          if (_lonError != null) {
                                            _lonError = FormValidators.validateLongitude(val, isHindi: isHindi);
                                          }
                                        });
                                      },
                                      label: isHindi ? 'देशांतर (Lon)' : 'Longitude',
                                      required: true,
                                      placeholder: '77.2167',
                                      caption: _lonError,
                                      status: _lonError != null
                                          ? Ux4gInputFieldStatus.error
                                          : Ux4gInputFieldStatus.defaultStatus,
                                      leadingIcon: Icons.explore_outlined,
                                      size: Ux4gInputFieldSize.large,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Use Current Device GPS Button
                              SizedBox(
                                width: double.infinity,
                                child: Ux4gButton(
                                  text: _isDetectingLocation
                                      ? (isHindi ? 'GPS सिग्नल खोज रहे हैं...' : 'Acquiring Live GPS Fix...')
                                      : (isHindi ? '📍 वर्तमान डिवाइस GPS स्थान लें' : '📍 Use Current Device GPS Coordinates'),
                                  variant: Ux4gButtonVariant.secondary,
                                  size: Ux4gButtonSize.medium,
                                  isLoading: _isDetectingLocation,
                                  onPressed: _isDetectingLocation ? null : _detectCurrentLocation,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Geofence Radius Slider
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isHindi ? 'जियोफेंस परिधि त्रिज्या' : 'Geofence Boundary Radius',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isContrast ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isContrast ? AppColors.darkPrimary.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${_geofenceRadius.toInt()} ${isHindi ? "मीटर" : "meters"}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isContrast ? AppColors.darkPrimary : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _geofenceRadius,
                                min: 25.0,
                                max: 100.0,
                                divisions: 15,
                                activeColor: isContrast ? AppColors.darkPrimary : AppColors.primary,
                                onChanged: (val) => setState(() => _geofenceRadius = val),
                              ),
                              Text(
                                isHindi
                                    ? 'अनुशंसित: बहुमंजिला इमारतों के लिए 50 मीटर'
                                    : 'Standard recommendation: 50m for residential apartments',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isContrast ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Dwell Time Slider
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isHindi ? 'पास-बाई ड्वेल सत्यापन समय' : 'Pass-By Dwell Validation Time',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isContrast ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isContrast ? AppColors.darkPrimary.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${_dwellTimeMinutes.toInt()} ${isHindi ? "मिनट" : "min"}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isContrast ? AppColors.darkPrimary : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _dwellTimeMinutes,
                                min: 1.0,
                                max: 10.0,
                                divisions: 9,
                                activeColor: isContrast ? AppColors.darkPrimary : AppColors.primary,
                                onChanged: (val) => setState(() => _dwellTimeMinutes = val),
                              ),
                              Text(
                                isHindi
                                    ? 'सड़क पर चलते हुए आकस्मिक हाजिरी रोकने हेतु न्यूनतम 3 मिनट अनिवार्य है'
                                    : 'PRD US-S01: 3-min dwell validation to filter street commuters',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isContrast ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                child: Ux4gButton(
                                  text: _isSaving
                                      ? (isHindi ? 'सहेज रहे हैं...' : 'Saving Geofence Setup...')
                                      : (isHindi ? 'जियोफेंस सेटिंग्स सुरक्षित करें' : 'Save Geofence Setup to Server'),
                                  variant: Ux4gButtonVariant.primary,
                                  size: Ux4gButtonSize.large,
                                  isLoading: _isSaving,
                                  leadingIcon: Icons.check_circle_outline,
                                  onPressed: _isSaving ? null : _onSaveSetup,
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
            ],
          ),
        );
      },
    );
  }
}
