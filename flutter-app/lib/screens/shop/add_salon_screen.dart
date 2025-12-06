import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class AddSalonScreen extends StatefulWidget {
  const AddSalonScreen({super.key});

  @override
  State<AddSalonScreen> createState() => _AddSalonScreenState();
}

class _AddSalonScreenState extends State<AddSalonScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;  // Added summary step
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  
  // Step 1: Owner Details
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerAgeController = TextEditingController();
  String _ownerGender = 'Male';
  File? _ownerProfileImage;
  
  // Step 2: Salon Basic Info
  final _salonNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _establishedYearController = TextEditingController();
  String _selectedCategory = 'Unisex';
  final List<String> _categories = ['Unisex', 'Men Only', 'Women Only', 'Kids', 'Beauty Parlour', 'Spa'];
  List<String> _selectedSpecialities = [];
  final List<String> _availableSpecialities = [
    'Hair Cut', 'Hair Color', 'Hair Spa', 'Beard Trim', 'Facial',
    'Makeup', 'Bridal Makeup', 'Manicure', 'Pedicure', 'Waxing',
    'Threading', 'Massage', 'Skin Care', 'Nail Art', 'Tattoo'
  ];
  
  // Step 3: Location & Address
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;
  bool _isFetchingPincode = false;
  
  // Location suggestions for service area
  List<Map<String, dynamic>> _locationSuggestions = [];
  bool _isSearchingLocations = false;
  final FocusNode _serviceAreaFocusNode = FocusNode();
  bool _showSuggestions = false;
  
  // Step 4: Business Hours & Staff
  TimeOfDay _openTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 21, minute: 0);
  final _numberOfStaffController = TextEditingController();
  final _serviceAreaController = TextEditingController();
  List<String> _selectedLanguages = ['Hindi'];
  final List<String> _availableLanguages = [
    'Hindi', 'English', 'Marathi', 'Gujarati', 'Tamil', 
    'Telugu', 'Kannada', 'Malayalam', 'Bengali', 'Punjabi'
  ];
  List<String> _workingDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<String> _allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  bool _homeServiceAvailable = false;
  
  // Step 5: Documents & Verification
  final _aadhaarNumberController = TextEditingController();
  final _panNumberController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _shopLicenseController = TextEditingController();
  File? _aadhaarFrontImage;
  File? _aadhaarBackImage;
  File? _panCardImage;
  File? _shopLicenseImage;
  File? _gstCertificateImage;
  
  // Step 6: Photo Verification
  File? _liveSelfieImage;
  File? _shopFrontImage;
  File? _shopInsideImage1;
  File? _shopInsideImage2;
  bool _termsAccepted = false;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pre-fill owner details from auth
    final authProvider = context.read<AuthProvider>();
    _ownerNameController.text = authProvider.user?.name ?? '';
    _ownerPhoneController.text = authProvider.user?.mobile ?? '';
    _ownerEmailController.text = authProvider.user?.email ?? '';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    _ownerAgeController.dispose();
    _salonNameController.dispose();
    _descriptionController.dispose();
    _establishedYearController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _numberOfStaffController.dispose();
    _serviceAreaController.dispose();
    _serviceAreaFocusNode.dispose();
    _aadhaarNumberController.dispose();
    _panNumberController.dispose();
    _gstNumberController.dispose();
    _shopLicenseController.dispose();
    super.dispose();
  }

  List<String> get _stepTitles => [
    'Owner Details',
    'Salon Info',
    'Location',
    'Business Hours',
    'Documents',
    'Photos',
    'Review & Submit',
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
          _error = null;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _error = null;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Owner Details
        if (_ownerNameController.text.trim().isEmpty) {
          _showError('Please enter owner name');
          return false;
        }
        if (_ownerPhoneController.text.trim().length != 10) {
          _showError('Please enter valid 10-digit phone number');
          return false;
        }
        return true;
      case 1: // Salon Basic Info
        if (_salonNameController.text.trim().isEmpty) {
          _showError('Please enter salon name');
          return false;
        }
        if (_descriptionController.text.trim().isEmpty) {
          _showError('Please enter salon description');
          return false;
        }
        return true;
      case 2: // Location
        if (_addressController.text.trim().isEmpty) {
          _showError('Please enter address');
          return false;
        }
        if (_cityController.text.trim().isEmpty) {
          _showError('Please enter city');
          return false;
        }
        if (_stateController.text.trim().isEmpty) {
          _showError('Please enter state');
          return false;
        }
        if (_pincodeController.text.trim().length != 6) {
          _showError('Please enter valid 6-digit pincode');
          return false;
        }
        return true;
      case 3: // Business Hours
        if (_numberOfStaffController.text.trim().isEmpty) {
          _showError('Please enter number of staff');
          return false;
        }
        if (_workingDays.isEmpty) {
          _showError('Please select at least one working day');
          return false;
        }
        return true;
      case 4: // Documents
        if (_aadhaarNumberController.text.trim().length != 12) {
          _showError('Please enter valid 12-digit Aadhaar number');
          return false;
        }
        if (_panNumberController.text.trim().length != 10) {
          _showError('Please enter valid 10-character PAN number');
          return false;
        }
        if (_aadhaarFrontImage == null) {
          _showError('Please upload Aadhaar front image');
          return false;
        }
        if (_aadhaarBackImage == null) {
          _showError('Please upload Aadhaar back image');
          return false;
        }
        if (_panCardImage == null) {
          _showError('Please upload PAN card image');
          return false;
        }
        return true;
      case 5: // Photos
        if (_liveSelfieImage == null) {
          _showError('Please capture live selfie for verification');
          return false;
        }
        if (_shopFrontImage == null) {
          _showError('Please upload shop front photo');
          return false;
        }
        return true;
      case 6: // Summary - Terms acceptance check
        if (!_termsAccepted) {
          _showError('Please accept terms and conditions to submit');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showError(String message) {
    setState(() {
      _error = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _pickImage(Function(File) onPicked, {bool fromCamera = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          onPicked(File(image.path));
        });
      }
    } catch (e) {
      _showError('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _captureLiveSelfie() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _liveSelfieImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Failed to capture selfie: ${e.toString()}');
    }
  }

  // Search for location suggestions using OpenStreetMap Nominatim API
  Future<void> _searchLocations(String query) async {
    if (query.length < 3) {
      setState(() {
        _locationSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _isSearchingLocations = true;
    });

    try {
      // Add India bias for better results
      final searchQuery = '$query, India';
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(searchQuery)}&format=json&limit=5&addressdetails=1&countrycodes=in',
        ),
        headers: {
          'User-Agent': 'SaloonVala-App/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _locationSuggestions = data.map((item) {
            return {
              'name': item['display_name'] ?? '',
              'lat': item['lat'],
              'lon': item['lon'],
              'type': item['type'] ?? '',
              'shortName': _getShortName(item),
            };
          }).toList();
          _showSuggestions = _locationSuggestions.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('Location search error: $e');
    } finally {
      setState(() {
        _isSearchingLocations = false;
      });
    }
  }

  String _getShortName(Map<String, dynamic> item) {
    final address = item['address'] as Map<String, dynamic>?;
    if (address != null) {
      final parts = <String>[];
      if (address['suburb'] != null) parts.add(address['suburb']);
      if (address['city'] != null) parts.add(address['city']);
      else if (address['town'] != null) parts.add(address['town']);
      else if (address['village'] != null) parts.add(address['village']);
      if (address['state'] != null) parts.add(address['state']);
      return parts.take(3).join(', ');
    }
    final displayName = item['display_name'] as String? ?? '';
    final parts = displayName.split(',').take(3).map((e) => e.trim()).toList();
    return parts.join(', ');
  }

  // Fetch city and state from pincode using India Post API
  Future<void> _fetchLocationFromPincode(String pincode) async {
    if (pincode.length != 6) return;

    setState(() {
      _isFetchingPincode = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.postalpincode.in/pincode/$pincode'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final postOffices = data[0]['PostOffice'] as List<dynamic>;
          if (postOffices.isNotEmpty) {
            final firstPO = postOffices[0];
            setState(() {
              _cityController.text = firstPO['District'] ?? '';
              _stateController.text = firstPO['State'] ?? '';
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Found: ${firstPO['District']}, ${firstPO['State']}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid pincode. Please check and try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // Silently fail - user can enter manually
      debugPrint('Failed to fetch pincode details: $e');
    } finally {
      setState(() {
        _isFetchingPincode = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied');
          setState(() => _isGettingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permission permanently denied. Enable from settings.');
        setState(() => _isGettingLocation = false);
        return;
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            if (_addressController.text.isEmpty) {
              _addressController.text = '${place.street ?? ''}, ${place.subLocality ?? ''}';
            }
            if (_cityController.text.isEmpty) {
              _cityController.text = place.locality ?? '';
            }
            if (_stateController.text.isEmpty) {
              _stateController.text = place.administrativeArea ?? '';
            }
            if (_pincodeController.text.isEmpty) {
              _pincodeController.text = place.postalCode ?? '';
            }
          });
        }
      } catch (e) {
        // Geocoding failed, but we have coordinates
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location fetched successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('Failed to get location: ${e.toString()}');
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _openTime : _closeTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatTimeFor24Hour(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Helper function to convert image file to base64
  Future<String?> _imageToBase64(File? imageFile) async {
    if (imageFile == null) return null;
    try {
      final bytes = await imageFile.readAsBytes();
      return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // Convert images to base64
      final ownerProfileBase64 = await _imageToBase64(_ownerProfileImage);
      final aadhaarFrontBase64 = await _imageToBase64(_aadhaarFrontImage);
      final aadhaarBackBase64 = await _imageToBase64(_aadhaarBackImage);
      final panCardBase64 = await _imageToBase64(_panCardImage);
      final shopLicenseBase64 = await _imageToBase64(_shopLicenseImage);
      final gstCertificateBase64 = await _imageToBase64(_gstCertificateImage);
      final liveSelfieBase64 = await _imageToBase64(_liveSelfieImage);
      final shopFrontBase64 = await _imageToBase64(_shopFrontImage);
      final shopInside1Base64 = await _imageToBase64(_shopInsideImage1);
      final shopInside2Base64 = await _imageToBase64(_shopInsideImage2);
      
      // Call API to register salon
      final response = await ApiService().registerSalon(
        // Owner Details
        ownerName: _ownerNameController.text.trim(),
        ownerPhone: _ownerPhoneController.text.trim(),
        ownerEmail: _ownerEmailController.text.trim(),
        ownerAge: _ownerAgeController.text.trim(),
        ownerGender: _ownerGender,
        ownerProfileImageUrl: ownerProfileBase64,
        
        // Salon Basic Info
        salonName: _salonNameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        establishedYear: _establishedYearController.text.trim(),
        specialities: _selectedSpecialities.join(','),
        
        // Location & Address
        address: _addressController.text.trim(),
        landmark: _landmarkController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        
        // Business Hours & Staff
        openTime: _formatTimeFor24Hour(_openTime),
        closeTime: _formatTimeFor24Hour(_closeTime),
        workingDays: _workingDays.join(','),
        numberOfStaff: int.tryParse(_numberOfStaffController.text) ?? 1,
        languages: _selectedLanguages.join(','),
        serviceArea: _serviceAreaController.text.trim(),
        homeServiceAvailable: _homeServiceAvailable,
        
        // Documents
        aadhaarNumber: _aadhaarNumberController.text.trim(),
        aadhaarFrontImageUrl: aadhaarFrontBase64,
        aadhaarBackImageUrl: aadhaarBackBase64,
        panNumber: _panNumberController.text.trim(),
        panCardImageUrl: panCardBase64,
        shopLicenseNumber: _shopLicenseController.text.trim(),
        shopLicenseImageUrl: shopLicenseBase64,
        gstNumber: _gstNumberController.text.trim(),
        gstCertificateImageUrl: gstCertificateBase64,
        
        // Photos
        liveSelfieImageUrl: liveSelfieBase64,
        shopFrontImageUrl: shopFrontBase64,
        shopInsideImage1Url: shopInside1Base64,
        shopInsideImage2Url: shopInside2Base64,
      );

      debugPrint('Salon registration response: ${response.message}');

      if (mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Application Submitted!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.hourglass_top, color: Colors.blue.shade600, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'Your salon is under review',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You will receive an email/SMS notification about your salon status once the admin reviews your application.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Review typically takes 24-48 hours',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(true); // Return to dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'OK, Got it!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showError('Failed to submit: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1}/${_totalSteps}: ${_stepTitles[_currentStep]}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Error Message
          if (_error != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                  ),
                ],
              ),
            ),
          
          // Form Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1OwnerDetails(),
                _buildStep2SalonInfo(),
                _buildStep3Location(),
                _buildStep4BusinessHours(),
                _buildStep5Documents(),
                _buildStep6Photos(),
                _buildStep7Summary(),
              ],
            ),
          ),
          
          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          bool isCompleted = index < _currentStep;
          bool isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green
                        : isCurrent
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < _totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: isCompleted ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ==================== STEP 1: Owner Details ====================
  Widget _buildStep1OwnerDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Owner Information', Icons.person, 'Personal details of the salon owner'),
          const SizedBox(height: 16),
          
          // Profile Photo
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _pickImage((file) => _ownerProfileImage = file),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _ownerProfileImage != null
                        ? FileImage(_ownerProfileImage!)
                        : null,
                    child: _ownerProfileImage == null
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Tap to upload profile photo', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Owner Name
          TextFormField(
            controller: _ownerNameController,
            decoration: _inputDecoration('Full Name *', Icons.person),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          
          // Phone
          TextFormField(
            controller: _ownerPhoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: _inputDecoration('Phone Number *', Icons.phone, prefix: '+91 '),
          ),
          const SizedBox(height: 16),
          
          // Email
          TextFormField(
            controller: _ownerEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Email (Optional)', Icons.email),
          ),
          const SizedBox(height: 16),
          
          // Age
          TextFormField(
            controller: _ownerAgeController,
            keyboardType: TextInputType.number,
            maxLength: 2,
            decoration: _inputDecoration('Age', Icons.cake),
          ),
          const SizedBox(height: 16),
          
          // Gender
          const Text('Gender', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: ['Male', 'Female', 'Other'].map((gender) {
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(gender, style: const TextStyle(fontSize: 14)),
                  value: gender,
                  groupValue: _ownerGender,
                  onChanged: (value) => setState(() => _ownerGender = value!),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==================== STEP 2: Salon Basic Info ====================
  Widget _buildStep2SalonInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Salon Information', Icons.store, 'Basic details about your salon'),
          const SizedBox(height: 16),
          
          // Salon Name
          TextFormField(
            controller: _salonNameController,
            decoration: _inputDecoration('Salon Name *', Icons.store),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          
          // Category
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: _inputDecoration('Category *', Icons.category),
            items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value!),
          ),
          const SizedBox(height: 16),
          
          // Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 500,
            decoration: _inputDecoration('Description *', Icons.description),
          ),
          const SizedBox(height: 16),
          
          // Established Year
          TextFormField(
            controller: _establishedYearController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: _inputDecoration('Established Year', Icons.calendar_today),
          ),
          const SizedBox(height: 16),
          
          // Specialities
          const Text('Specialities (Select multiple)', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSpecialities.map((spec) {
              bool isSelected = _selectedSpecialities.contains(spec);
              return FilterChip(
                label: Text(spec),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSpecialities.add(spec);
                    } else {
                      _selectedSpecialities.remove(spec);
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==================== STEP 3: Location & Address ====================
  Widget _buildStep3Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Location & Address', Icons.location_on, 'Where is your salon located?'),
          const SizedBox(height: 16),
          
          // Get Current Location Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              icon: _isGettingLocation
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
              label: Text(_isGettingLocation ? 'Getting Location...' : 'Get Current Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          
          if (_latitude != null && _longitude != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '📍 Location: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Address
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: _inputDecoration('Street Address *', Icons.home),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          
          // Landmark
          TextFormField(
            controller: _landmarkController,
            decoration: _inputDecoration('Landmark', Icons.place),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          
          // City & State
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: _inputDecoration('City *', null),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: _inputDecoration('State *', null),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Pincode (with auto-fetch city/state)
          TextFormField(
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Pincode *',
              prefixIcon: const Icon(Icons.pin_drop),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: _isFetchingPincode
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              helperText: 'Enter 6-digit pincode to auto-fill city & state',
            ),
            onChanged: (value) {
              if (value.length == 6) {
                _fetchLocationFromPincode(value);
              }
            },
          ),
        ],
      ),
    );
  }

  // ==================== STEP 4: Business Hours & Staff ====================
  Widget _buildStep4BusinessHours() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Business Hours & Staff', Icons.schedule, 'Operating hours and team details'),
          const SizedBox(height: 16),
          
          // Timing
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectTime(context, true),
                  child: InputDecorator(
                    decoration: _inputDecoration('Opening Time', Icons.access_time),
                    child: Text(_formatTime(_openTime)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _selectTime(context, false),
                  child: InputDecorator(
                    decoration: _inputDecoration('Closing Time', Icons.access_time),
                    child: Text(_formatTime(_closeTime)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Working Days
          const Text('Working Days *', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allDays.map((day) {
              bool isSelected = _workingDays.contains(day);
              return FilterChip(
                label: Text(day.substring(0, 3)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _workingDays.add(day);
                    } else {
                      _workingDays.remove(day);
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // Number of Staff
          TextFormField(
            controller: _numberOfStaffController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Number of Staff *', Icons.people),
          ),
          const SizedBox(height: 16),
          
          // Languages
          const Text('Languages Spoken', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableLanguages.map((lang) {
              bool isSelected = _selectedLanguages.contains(lang);
              return FilterChip(
                label: Text(lang),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedLanguages.add(lang);
                    } else {
                      _selectedLanguages.remove(lang);
                    }
                  });
                },
                selectedColor: Colors.green.withOpacity(0.2),
                checkmarkColor: Colors.green,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // Service Area with Location Autocomplete
          const Text('Service Area', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          const Text(
            'Type to search locations where you provide services',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              TextFormField(
                controller: _serviceAreaController,
                focusNode: _serviceAreaFocusNode,
                decoration: InputDecoration(
                  hintText: 'e.g., Andheri, Bandra, Juhu...',
                  prefixIcon: const Icon(Icons.map),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: _isSearchingLocations
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _serviceAreaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _serviceAreaController.clear();
                                  _locationSuggestions = [];
                                  _showSuggestions = false;
                                });
                              },
                            )
                          : null,
                ),
                onChanged: (value) {
                  _searchLocations(value);
                },
                onTap: () {
                  if (_serviceAreaController.text.length >= 3) {
                    _searchLocations(_serviceAreaController.text);
                  }
                },
              ),
              
              // Location Suggestions Dropdown
              if (_showSuggestions && _locationSuggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _locationSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _locationSuggestions[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.location_on, color: Colors.red, size: 20),
                        title: Text(
                          suggestion['shortName'] ?? '',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          suggestion['name'] ?? '',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          setState(() {
                            _serviceAreaController.text = suggestion['shortName'] ?? '';
                            _showSuggestions = false;
                            _locationSuggestions = [];
                          });
                          _serviceAreaFocusNode.unfocus();
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Home Service
          SwitchListTile(
            title: const Text('Home Service Available'),
            subtitle: const Text('Do you provide services at customer\'s home?'),
            value: _homeServiceAvailable,
            onChanged: (value) => setState(() => _homeServiceAvailable = value),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // ==================== STEP 5: Documents ====================
  Widget _buildStep5Documents() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Documents & Verification', Icons.description, 'Upload required documents for KYC'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All documents are securely stored and used only for verification purposes.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Aadhaar Number
          TextFormField(
            controller: _aadhaarNumberController,
            keyboardType: TextInputType.number,
            maxLength: 12,
            decoration: _inputDecoration('Aadhaar Number *', Icons.credit_card),
          ),
          const SizedBox(height: 12),
          
          // Aadhaar Images
          Row(
            children: [
              Expanded(
                child: _buildDocumentUpload(
                  'Aadhaar Front *',
                  _aadhaarFrontImage,
                  () => _pickImage((file) => _aadhaarFrontImage = file),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDocumentUpload(
                  'Aadhaar Back *',
                  _aadhaarBackImage,
                  () => _pickImage((file) => _aadhaarBackImage = file),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // PAN Number
          TextFormField(
            controller: _panNumberController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 10,
            decoration: _inputDecoration('PAN Number *', Icons.credit_card),
          ),
          const SizedBox(height: 12),
          
          // PAN Image
          _buildDocumentUpload(
            'PAN Card Image *',
            _panCardImage,
            () => _pickImage((file) => _panCardImage = file),
          ),
          const SizedBox(height: 20),
          
          // Shop License (Optional)
          TextFormField(
            controller: _shopLicenseController,
            decoration: _inputDecoration('Shop License Number (Optional)', Icons.store),
          ),
          const SizedBox(height: 12),
          _buildDocumentUpload(
            'Shop License (Optional)',
            _shopLicenseImage,
            () => _pickImage((file) => _shopLicenseImage = file),
          ),
          const SizedBox(height: 20),
          
          // GST (Optional)
          TextFormField(
            controller: _gstNumberController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 15,
            decoration: _inputDecoration('GST Number (Optional)', Icons.receipt_long),
          ),
          const SizedBox(height: 12),
          _buildDocumentUpload(
            'GST Certificate (Optional)',
            _gstCertificateImage,
            () => _pickImage((file) => _gstCertificateImage = file),
          ),
        ],
      ),
    );
  }

  // ==================== STEP 6: Photos ====================
  Widget _buildStep6Photos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Photo Verification', Icons.camera_alt, 'Upload photos for verification'),
          const SizedBox(height: 16),
          
          // Live Selfie
          const Text('Live Selfie Verification *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'Capture a live selfie for identity verification. Make sure your face is clearly visible.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          
          Center(
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _liveSelfieImage != null ? Colors.green : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: _liveSelfieImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_liveSelfieImage!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.face, size: 60, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No selfie captured', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _captureLiveSelfie,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_liveSelfieImage != null ? 'Retake Selfie' : 'Capture Live Selfie'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Shop Photos
          const Text('Shop Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          
          _buildDocumentUpload(
            'Shop Front Photo *',
            _shopFrontImage,
            () => _pickImage((file) => _shopFrontImage = file),
            height: 150,
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildDocumentUpload(
                  'Inside Photo 1',
                  _shopInsideImage1,
                  () => _pickImage((file) => _shopInsideImage1 = file),
                  height: 120,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDocumentUpload(
                  'Inside Photo 2',
                  _shopInsideImage2,
                  () => _pickImage((file) => _shopInsideImage2 = file),
                  height: 120,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== STEP 7: Review & Submit ====================
  Widget _buildStep7Summary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade100, Colors.amber.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please Review Carefully!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This form will be sent to the admin for review. Please ensure all details are correct before submitting. Incorrect information may lead to rejection of your salon registration.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Summary Sections
          _buildSummarySection('👤 Owner Details', [
            _summaryItem('Name', _ownerNameController.text),
            _summaryItem('Phone', '+91 ${_ownerPhoneController.text}'),
            _summaryItem('Email', _ownerEmailController.text.isEmpty ? 'Not provided' : _ownerEmailController.text),
            _summaryItem('Age', _ownerAgeController.text.isEmpty ? 'Not provided' : _ownerAgeController.text),
            _summaryItem('Gender', _ownerGender),
            _summaryItem('Profile Photo', _ownerProfileImage != null ? '✅ Uploaded' : '❌ Not uploaded'),
          ]),

          _buildSummarySection('🏪 Salon Information', [
            _summaryItem('Salon Name', _salonNameController.text),
            _summaryItem('Category', _selectedCategory),
            _summaryItem('Description', _descriptionController.text.length > 50 
                ? '${_descriptionController.text.substring(0, 50)}...' 
                : _descriptionController.text),
            _summaryItem('Established', _establishedYearController.text.isEmpty ? 'Not provided' : _establishedYearController.text),
            _summaryItem('Specialities', _selectedSpecialities.isEmpty ? 'None selected' : _selectedSpecialities.join(', ')),
          ]),

          _buildSummarySection('📍 Location', [
            _summaryItem('Address', _addressController.text),
            _summaryItem('Landmark', _landmarkController.text.isEmpty ? 'Not provided' : _landmarkController.text),
            _summaryItem('City', _cityController.text),
            _summaryItem('State', _stateController.text),
            _summaryItem('Pincode', _pincodeController.text),
            _summaryItem('GPS Location', _latitude != null ? '✅ Captured' : '❌ Not captured'),
          ]),

          _buildSummarySection('⏰ Business Hours', [
            _summaryItem('Opening Time', _formatTime(_openTime)),
            _summaryItem('Closing Time', _formatTime(_closeTime)),
            _summaryItem('Working Days', _workingDays.map((d) => d.substring(0, 3)).join(', ')),
            _summaryItem('Number of Staff', _numberOfStaffController.text),
            _summaryItem('Languages', _selectedLanguages.join(', ')),
            _summaryItem('Service Area', _serviceAreaController.text.isEmpty ? 'Not specified' : _serviceAreaController.text),
            _summaryItem('Home Service', _homeServiceAvailable ? 'Yes' : 'No'),
          ]),

          _buildSummarySection('📄 Documents', [
            _summaryItem('Aadhaar Number', _maskAadhaar(_aadhaarNumberController.text)),
            _summaryItem('Aadhaar Front', _aadhaarFrontImage != null ? '✅ Uploaded' : '❌ Not uploaded'),
            _summaryItem('Aadhaar Back', _aadhaarBackImage != null ? '✅ Uploaded' : '❌ Not uploaded'),
            _summaryItem('PAN Number', _panNumberController.text),
            _summaryItem('PAN Card', _panCardImage != null ? '✅ Uploaded' : '❌ Not uploaded'),
            _summaryItem('Shop License', _shopLicenseController.text.isEmpty ? 'Not provided' : _shopLicenseController.text),
            _summaryItem('GST Number', _gstNumberController.text.isEmpty ? 'Not provided' : _gstNumberController.text),
          ]),

          _buildSummarySection('📸 Photos', [
            _summaryItem('Live Selfie', _liveSelfieImage != null ? '✅ Captured' : '❌ Not captured'),
            _summaryItem('Shop Front', _shopFrontImage != null ? '✅ Uploaded' : '❌ Not uploaded'),
            _summaryItem('Inside Photo 1', _shopInsideImage1 != null ? '✅ Uploaded' : '⚪ Optional'),
            _summaryItem('Inside Photo 2', _shopInsideImage2 != null ? '✅ Uploaded' : '⚪ Optional'),
          ]),

          const SizedBox(height: 20),

          // Terms & Conditions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: CheckboxListTile(
              value: _termsAccepted,
              onChanged: (value) => setState(() => _termsAccepted = value ?? false),
              title: const Text(
                'I confirm that all information provided is accurate and complete. I agree to the Terms & Conditions and Privacy Policy.',
                style: TextStyle(fontSize: 13),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // Info about review process
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'What happens next?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Your application will be sent to admin for review\n'
                  '2. Admin will verify your documents and details\n'
                  '3. You will receive a notification about approval/rejection\n'
                  '4. Once approved, your salon will be live on the platform',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade800,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _maskAadhaar(String aadhaar) {
    if (aadhaar.length >= 8) {
      return 'XXXX-XXXX-${aadhaar.substring(aadhaar.length - 4)}';
    }
    return aadhaar;
  }

  // Helper Widgets
  Widget _buildSectionHeader(String title, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon, {String? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      prefixText: prefix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildDocumentUpload(String label, File? file, VoidCallback onTap, {double height = 100}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: file != null ? Colors.green : Colors.grey.shade400,
                width: file != null ? 2 : 1,
              ),
            ),
            child: file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(file, fit: BoxFit.cover),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload, size: 32, color: Colors.grey.shade500),
                      const SizedBox(height: 4),
                      Text('Tap to upload', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final bool isLastStep = _currentStep == _totalSteps - 1;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : (isLastStep ? _submitForm : _nextStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep ? Colors.green : AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSubmitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Submitting...',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    )
                  : Text(
                      isLastStep ? '🚀 Submit for Approval' : 'Next',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
