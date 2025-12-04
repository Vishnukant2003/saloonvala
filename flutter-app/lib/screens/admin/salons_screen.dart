import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'salon_detail_screen.dart';

// Pure Dart Code - Admin Salons Screen (Converted from HTML/CSS/JS)
class AdminSalonsScreen extends StatefulWidget {
  const AdminSalonsScreen({super.key});

  @override
  State<AdminSalonsScreen> createState() => _AdminSalonsScreenState();
}

class _AdminSalonsScreenState extends State<AdminSalonsScreen> {
  List<Map<String, dynamic>> _salons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSalons();
  }

  Future<void> _loadSalons() async {
    // TODO: Load salons from API
    setState(() {
      _isLoading = false;
      _salons = []; // Will be loaded from API
    });
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
                const Text(
                  'All Salons',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
                        rows: _salons.isEmpty
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
                            : _salons.map((salon) {
                                final status = salon['approvalStatus'] ?? 'PENDING';
                                return DataRow(
                                  onSelectChanged: (selected) {
                                    if (selected == true) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AdminSalonDetailScreen(
                                            salonId: salon['id'],
                                          ),
                                        ),
                                      );
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _approveSalon(int salonId) {
    // TODO: Approve salon via API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approving salon $salonId...')),
    );
  }

  void _rejectSalon(int salonId) {
    // TODO: Reject salon via API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejecting salon $salonId...')),
    );
  }
}

