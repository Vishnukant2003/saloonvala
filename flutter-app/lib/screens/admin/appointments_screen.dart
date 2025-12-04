import 'package:flutter/material.dart';
import '../../config/theme.dart';

// Pure Dart Code - Admin Appointments Screen (Converted from HTML/CSS/JS)
class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL'; // ALL, REQUESTED, ACCEPTED, COMPLETED, REJECTED

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    // TODO: Load appointments from API
    setState(() {
      _isLoading = false;
      _appointments = []; // Will be loaded from API
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Appointments',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Filter Dropdown
              DropdownButton<String>(
                value: _selectedFilter,
                items: ['ALL', 'REQUESTED', 'ACCEPTED', 'COMPLETED', 'REJECTED']
                    .map((filter) => DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value ?? 'ALL';
                    _loadAppointments();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Card(
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Booking ID')),
                          DataColumn(label: Text('Salon')),
                          DataColumn(label: Text('Customer')),
                          DataColumn(label: Text('Service')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: _appointments.isEmpty
                            ? [
                                const DataRow(
                                  cells: [
                                    DataCell(Text('No appointments found')),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                  ],
                                ),
                              ]
                            : _appointments.map((apt) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text('${apt['bookingId'] ?? ''}')),
                                    DataCell(Text(apt['salonName'] ?? '')),
                                    DataCell(Text(apt['userName'] ?? '')),
                                    DataCell(Text(apt['serviceName'] ?? '')),
                                    DataCell(Text(apt['scheduledAt'] ?? '')),
                                    DataCell(
                                      _buildStatusChip(apt['status'] ?? 'PENDING'),
                                    ),
                                    DataCell(
                                      apt['status'] == 'REQUESTED' ||
                                              apt['status'] == 'ACCEPTED'
                                          ? ElevatedButton(
                                              onPressed: () {
                                                _forceCancel(apt['bookingId']);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                              ),
                                              child: const Text(
                                                'Force Cancel',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
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

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        color = Colors.green;
        break;
      case 'REJECTED':
      case 'CANCELLED':
        color = Colors.red;
        break;
      case 'COMPLETED':
        color = Colors.blue;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _forceCancel(int bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Cancel Booking'),
        content: const Text('Are you sure you want to force cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Force cancel via API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cancelling booking $bookingId...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Force Cancel'),
          ),
        ],
      ),
    );
  }
}

