import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

// Admin Salon Detail Screen - Shows all salon registration details for review
class AdminSalonDetailScreen extends StatefulWidget {
  final int salonId;

  const AdminSalonDetailScreen({
    super.key,
    required this.salonId,
  });

  @override
  State<AdminSalonDetailScreen> createState() => _AdminSalonDetailScreenState();
}

class _AdminSalonDetailScreenState extends State<AdminSalonDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _salonData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSalonDetails();
  }

  Future<void> _loadSalonDetails() async {
    setState(() => _isLoading = true);
    try {
      // Fetch salons list to get full details
      final salons = await _apiService.getAdminSalons();
      final salon = salons.firstWhere(
        (s) => s['id'] == widget.salonId,
        orElse: () => <String, dynamic>{},
      );
      
      // Try to get additional overview data
      Map<String, dynamic> overview = {};
      try {
        overview = await _apiService.getSalonDetailsForReview(widget.salonId);
      } catch (e) {
        debugPrint('Could not fetch overview: $e');
      }
      
      setState(() {
        _salonData = {
          ...salon,
          if (overview.isNotEmpty) 'overview': overview,
        };
      });
    } catch (e) {
      debugPrint('Error loading salon details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading salon: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_salonData?['salonName'] ?? 'Salon Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_salonData != null && _salonData!['approvalStatus'] == 'PENDING') ...[
            TextButton.icon(
              onPressed: _approveSalon,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Approve', style: TextStyle(color: Colors.white)),
            ),
            TextButton.icon(
              onPressed: _rejectSalon,
              icon: const Icon(Icons.close, color: Colors.white),
              label: const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _salonData == null
              ? const Center(child: Text('Salon not found'))
              : Container(
                  color: const Color(0xFFF8FAFC),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Banner
                        _buildStatusBanner(),
                        const SizedBox(height: 24),

                        // Owner Details Section
                        _buildSection(
                          'Owner Details',
                          Icons.person,
                          [
                            _buildInfoRow('Name', _salonData!['ownerName']),
                            _buildInfoRow('Phone', _salonData!['ownerPhone']),
                            _buildInfoRow('Email', _salonData!['ownerEmail']),
                            _buildInfoRow('Age', _salonData!['ownerAge']),
                            _buildInfoRow('Gender', _salonData!['ownerGender']),
                            if (_salonData!['ownerProfileImageUrl'] != null)
                              _buildImageRow('Profile Photo', _salonData!['ownerProfileImageUrl']),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Salon Information Section
                        _buildSection(
                          'Salon Information',
                          Icons.store,
                          [
                            _buildInfoRow('Salon Name', _salonData!['salonName']),
                            _buildInfoRow('Category', _salonData!['category']),
                            _buildInfoRow('Description', _salonData!['description']),
                            _buildInfoRow('Established Year', _salonData!['establishedYear']),
                            _buildInfoRow('Specialities', _salonData!['specialities']),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Location Section
                        _buildSection(
                          'Location & Address',
                          Icons.location_on,
                          [
                            _buildInfoRow('Address', _salonData!['address']),
                            _buildInfoRow('Landmark', _salonData!['landmark']),
                            _buildInfoRow('City', _salonData!['city']),
                            _buildInfoRow('State', _salonData!['state']),
                            _buildInfoRow('Pincode', _salonData!['pincode']),
                            _buildInfoRow('Latitude', _salonData!['latitude']?.toString()),
                            _buildInfoRow('Longitude', _salonData!['longitude']?.toString()),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Business Hours Section
                        _buildSection(
                          'Business Hours & Staff',
                          Icons.schedule,
                          [
                            _buildInfoRow('Open Time', _salonData!['openTime']),
                            _buildInfoRow('Close Time', _salonData!['closeTime']),
                            _buildInfoRow('Working Days', _salonData!['workingDays']),
                            _buildInfoRow('Number of Staff', _salonData!['numberOfStaff']?.toString()),
                            _buildInfoRow('Languages', _salonData!['languages']),
                            _buildInfoRow('Service Area', _salonData!['serviceArea']),
                            _buildInfoRow('Home Service', _salonData!['homeServiceAvailable'] == true ? 'Yes' : 'No'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Documents Section
                        _buildSection(
                          'Documents & Verification',
                          Icons.description,
                          [
                            _buildInfoRow('Aadhaar Number', _salonData!['aadhaarNumber']),
                            if (_salonData!['aadhaarFrontImageUrl'] != null)
                              _buildImageRow('Aadhaar Front', _salonData!['aadhaarFrontImageUrl']),
                            if (_salonData!['aadhaarBackImageUrl'] != null)
                              _buildImageRow('Aadhaar Back', _salonData!['aadhaarBackImageUrl']),
                            _buildInfoRow('PAN Number', _salonData!['panNumber']),
                            if (_salonData!['panCardImageUrl'] != null)
                              _buildImageRow('PAN Card', _salonData!['panCardImageUrl']),
                            _buildInfoRow('Shop License No.', _salonData!['shopLicenseNumber']),
                            if (_salonData!['shopLicenseImageUrl'] != null)
                              _buildImageRow('Shop License', _salonData!['shopLicenseImageUrl']),
                            _buildInfoRow('GST Number', _salonData!['gstNumber']),
                            if (_salonData!['gstCertificateImageUrl'] != null)
                              _buildImageRow('GST Certificate', _salonData!['gstCertificateImageUrl']),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Photos Section
                        _buildSection(
                          'Photo Verification',
                          Icons.photo_camera,
                          [
                            if (_salonData!['liveSelfieImageUrl'] != null)
                              _buildImageRow('Live Selfie', _salonData!['liveSelfieImageUrl']),
                            if (_salonData!['shopFrontImageUrl'] != null)
                              _buildImageRow('Shop Front', _salonData!['shopFrontImageUrl']),
                            if (_salonData!['shopInsideImage1Url'] != null)
                              _buildImageRow('Shop Inside 1', _salonData!['shopInsideImage1Url']),
                            if (_salonData!['shopInsideImage2Url'] != null)
                              _buildImageRow('Shop Inside 2', _salonData!['shopInsideImage2Url']),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        if (_salonData!['approvalStatus'] == 'PENDING')
                          _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatusBanner() {
    final status = _salonData!['approvalStatus'] ?? 'PENDING';
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'APPROVED':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case 'REJECTED':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.cancel;
        break;
      case 'NEEDS_CORRECTION':
        bgColor = Colors.amber.shade100;
        textColor = Colors.amber.shade800;
        icon = Icons.warning;
        break;
      default:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.pending;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $status',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (_salonData!['rejectionReason'] != null &&
                    _salonData!['rejectionReason'].toString().isNotEmpty)
                  Text(
                    'Reason: ${_salonData!['rejectionReason']}',
                    style: TextStyle(color: textColor),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    // Filter out null widgets
    final validChildren = children.where((w) => w is! SizedBox || (w as SizedBox).height != 0).toList();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...validChildren,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageRow(String label, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showFullImage(label, imageUrl),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.startsWith('data:')
                    ? Image.memory(
                        _decodeBase64Image(imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(String title, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                child: imageUrl.startsWith('data:')
                    ? Image.memory(
                        _decodeBase64Image(imageUrl),
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Decode base64 image
  dynamic _decodeBase64Image(String dataUrl) {
    try {
      final base64Data = dataUrl.split(',').last;
      return Uri.parse('data:image/png;base64,$base64Data').data!.contentAsBytes();
    } catch (e) {
      debugPrint('Error decoding base64 image: $e');
      return Uri.parse('data:image/png;base64,').data!.contentAsBytes();
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _approveSalon,
            icon: const Icon(Icons.check),
            label: const Text('Approve Salon'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _rejectSalon,
            icon: const Icon(Icons.close),
            label: const Text('Reject Salon'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _approveSalon() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Salon'),
        content: const Text('Are you sure you want to approve this salon?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.approveSalon(widget.salonId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salon approved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return to list with refresh
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving salon: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectSalon() async {
    final reasonController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Salon'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason',
            hintText: 'Enter reason for rejection...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await _apiService.rejectSalon(widget.salonId, result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salon rejected'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Return to list with refresh
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting salon: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
