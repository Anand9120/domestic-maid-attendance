import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../../auth/presentation/widgets/custom_button.dart';

class GeofenceMapSetupPage extends StatefulWidget {
  final int employerId;

  const GeofenceMapSetupPage({super.key, required this.employerId});

  @override
  State<GeofenceMapSetupPage> createState() => _GeofenceMapSetupPageState();
}

class _GeofenceMapSetupPageState extends State<GeofenceMapSetupPage> {
  final TextEditingController _houseNameController = TextEditingController(text: 'Sharma Residence - Flat 402');
  final TextEditingController _addressController = TextEditingController(text: 'Green Park Heights, New Delhi');
  final TextEditingController _latController = TextEditingController(text: '28.6315000');
  final TextEditingController _lonController = TextEditingController(text: '77.2167000');

  double _geofenceRadius = 50.0;
  double _dwellTimeMinutes = 3.0;
  bool _isSaving = false;
  bool _isDetectingLocation = false;

  @override
  void dispose() {
    _houseNameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isDetectingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _latController.text = pos.latitude.toStringAsFixed(7);
          _lonController.text = pos.longitude.toStringAsFixed(7);
          _isDetectingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 Coordinates updated from your device GPS (Accuracy: ±${pos.accuracy.toStringAsFixed(1)}m)'),
            backgroundColor: AppColors.present,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDetectingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Could not fetch GPS location: $e'),
            backgroundColor: AppColors.absent,
          ),
        );
      }
    }
  }

  Future<void> _onSaveSetup() async {
    setState(() => _isSaving = true);
    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 5),
      ));

      final payload = {
        'employerId': widget.employerId,
        'houseName': _houseNameController.text.trim(),
        'address': _addressController.text.trim(),
        'latitude': double.tryParse(_latController.text) ?? 28.6315,
        'longitude': double.tryParse(_lonController.text) ?? 77.2167,
        'geofenceRadiusMeters': _geofenceRadius.toInt(),
        'dwellTimeMinutes': _dwellTimeMinutes.toInt(),
      };

      final response = await dio.post(ApiConstants.householdSetup, data: payload);
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Household geofence & dwell settings saved to server!'),
              backgroundColor: AppColors.present,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to save settings');
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Household Geofence Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Visual Map Simulator Card
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circular geofence boundary visual
                  Container(
                    width: _geofenceRadius * 2,
                    height: _geofenceRadius * 2,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryLight, width: 2),
                    ),
                  ),
                  const Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Radius: ${_geofenceRadius.toInt()}m | Dwell: ${_dwellTimeMinutes.toInt()}min',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('House Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _houseNameController,
                    decoration: const InputDecoration(hintText: 'e.g. Home, Villa 12'),
                  ),
                  const SizedBox(height: 16),

                  const Text('Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(hintText: 'Full physical address'),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Latitude', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextFormField(controller: _latController),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Longitude', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextFormField(controller: _lonController),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Button to detect current device GPS
                  SizedBox(
                    width: double.infinity,
                    child: Ux4gButton(
                      text: _isDetectingLocation ? 'Acquiring GPS...' : '📍 Use Current Device GPS Coordinates',
                      variant: Ux4gButtonVariant.secondary,
                      size: Ux4gButtonSize.small,
                      isLoading: _isDetectingLocation,
                      onPressed: _isDetectingLocation ? null : _detectCurrentLocation,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Geofence Radius Slider (PRD US-M01: 50m radius)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Geofence Boundary Radius',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '${_geofenceRadius.toInt()} meters',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  Slider(
                    value: _geofenceRadius,
                    min: 25.0,
                    max: 100.0,
                    divisions: 15,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _geofenceRadius = val),
                  ),

                  // Dwell Time Slider (PRD US-S01: 3-min dwell validation)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pass-By Dwell Validation Time',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '${_dwellTimeMinutes.toInt()} minutes',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  Slider(
                    value: _dwellTimeMinutes,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _dwellTimeMinutes = val),
                  ),
                  const SizedBox(height: 16),

                  CustomButton(
                    text: 'Save Geofence Setup to Server',
                    isLoading: _isSaving,
                    icon: Icons.check_circle_outline,
                    onPressed: _onSaveSetup,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
