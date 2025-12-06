import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'salon_detail_screen.dart';

// Pure Dart Code - Admin Salons Screen (Converted from HTML/CSS/JS)
class AdminSalonsScreen extends StatefulWidget {
  const AdminSalonsScreen({super.key});

  @override
  State<AdminSalonsScreen> createState() => _AdminSalonsScreenState();
}

class _AdminSalonsScreenState extends State<AdminSalonsScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _salons = [];
  List<Map<String, dynamic>> _filteredSalons = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadSalons();
  }

  Future<void> _loadSalons() async {
    setState(() => _isLoading = true);
    try {
      final salons = await _apiService.getAdminSalons();
      setState(() {
        _salons = List<Map<String, dynamic>>.from(salons);
        _applyFilter();
      });
    } catch (e) {
      debugPrint('Error loading salons: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading salons: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'ALL') {
      _filteredSalons = _salons;
    } else {
      _filteredSalons = _salons
          .where((s) => s['approvalStatus'] == _selectedFilter)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(24),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Salons',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadSalons,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filter chips
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip('ALL', 'All'),
                    _buildFilterChip('PENDING', 'Pending'),
                    _buildFilterChip('APPROVED', 'Approved'),
                    _buildFilterChip('REJECTED', 'Rejected'),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Card(
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Salon Name')),
                          DataColumn(label: Text('Owner')),
                          DataColumn(label: Text('City')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: _filteredSalons.isEmpty
                            ? [
                                const DataRow(
                                  cells: [
                                    DataCell(Text('No salons found')),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                  ],
                                ),
                              ]
                            : _filteredSalons.map((salon) {
                                final status = salon['approvalStatus'] ?? 'PENDING';
                                return DataRow(
                                  onSelectChanged: (selected) async {
                                    if (selected == true) {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AdminSalonDetailScreen(
                                            salonId: salon['id'],
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadSalons(); // Refresh list after action
                                      }
                                    }
                                  },
                                  cells: [
                                    DataCell(Text('${salon['id'] ?? ''}')),
                                    DataCell(Text(salon['salonName'] ?? '')),
                                    DataCell(Text(salon['ownerName'] ?? '')),
                                    DataCell(Text(salon['city'] ?? '')),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: _getStatusColor(status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (status == 'PENDING') ...[
                                            ElevatedButton(
                                              onPressed: () {
                                                _approveSalon(salon['id']);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                              ),
                                              child: const Text(
                                                'Approve',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                _rejectSalon(salon['id']);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                              ),
                                              child: const Text(
                                                'Reject',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          _applyFilter();
        });
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      case 'NEEDS_CORRECTION':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Future<void> _approveSalon(int salonId) async {
    try {
      await _apiService.approveSalon(salonId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salon approved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadSalons(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving salon: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectSalon(int salonId) async {
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
        await _apiService.rejectSalon(salonId, result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salon rejected'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadSalons(); // Refresh the list
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

