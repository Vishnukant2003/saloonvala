import 'package:flutter/material.dart';
import '../../models/salon.dart';
import '../../models/service.dart';
import '../../config/theme.dart';
import '../../widgets/calendar_widget.dart';

// Pure Dart Code - Complete Booking Screen with Calendar
class BookingScreen extends StatefulWidget {
  final Salon salon;
  final List<Service>? preSelectedServices;

  const BookingScreen({
    super.key,
    required this.salon,
    this.preSelectedServices,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? _selectedStaffId;
  List<int> _selectedServiceIds = [];
  List<Service> _services = [];
  List<Map<String, dynamic>> _staffList = [];
  bool _isLoading = false;

  // Time slots
  final List<String> _morningSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
  ];
  final List<String> _afternoonSlots = [
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
  ];
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    if (widget.preSelectedServices != null) {
      _selectedServiceIds = widget.preSelectedServices!
          .map((s) => s.id ?? -1)
          .where((id) => id != -1)
          .toList();
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // TODO: Load services and staff from API
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.salon.salonName ?? 'Book Appointment'),
        backgroundColor: const Color(0xFF880E4F), // booking_magenta
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar Section
                  CalendarWidget(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    maxDate: DateTime.now().add(const Duration(days: 3)),
                  ),

                  // Time Slots Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 40,
                              color: const Color(0xFF5D0434), // booking_maroon
                              margin: const EdgeInsets.only(right: 16),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Morning Section
                                  const Text(
                                    'Morning',
                                    style: TextStyle(
                                      color: Color(0xFF5D0434),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _morningSlots
                                        .map((slot) => _buildTimeSlotButton(slot))
                                        .toList(),
                                  ),
                                  const SizedBox(height: 24),
                                  // Afternoon Section
                                  const Text(
                                    'Afternoon',
                                    style: TextStyle(
                                      color: Color(0xFF5D0434),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _afternoonSlots
                                        .map((slot) => _buildTimeSlotButton(slot))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Specialist Selection
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose Hair Specialist',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _staffList.length,
                            itemBuilder: (context, index) {
                              return _buildSpecialistCard(_staffList[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Service Selection
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Service',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_services.isEmpty)
                          const Text('No services available')
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _services.length,
                            itemBuilder: (context, index) {
                              return _buildServiceCard(_services[index]);
                            },
                          ),
                      ],
                    ),
                  ),

                  // Book Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canBook() ? _handleBooking : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF880E4F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeSlotButton(String time) {
    final isSelected = _selectedTimeSlot == time;
    return ChoiceChip(
      label: Text(time),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTimeSlot = selected ? time : null;
        });
      },
      selectedColor: const Color(0xFF880E4F),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildSpecialistCard(Map<String, dynamic> staff) {
    final isSelected = _selectedStaffId == staff['id'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStaffId = staff['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: isSelected
                  ? const Color(0xFF880E4F)
                  : Colors.grey[300],
              child: Text(
                (staff['name'] ?? 'S')[0].toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 70,
              child: Text(
                staff['name'] ?? 'Staff',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    final isSelected = _selectedServiceIds.contains(service.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(service.serviceName ?? 'Service'),
        subtitle: Text('₹${service.price ?? 0} - ${service.durationMinutes ?? 0} min'),
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              if (service.id != null) {
                _selectedServiceIds.add(service.id!);
              }
            } else {
              _selectedServiceIds.remove(service.id);
            }
          });
        },
      ),
    );
  }

  bool _canBook() {
    return _selectedDate != null &&
        _selectedTimeSlot != null &&
        _selectedStaffId != null &&
        _selectedServiceIds.isNotEmpty;
  }

  void _handleBooking() {
    if (!_canBook()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    // TODO: Submit booking via API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking submitted successfully!')),
    );
    Navigator.pop(context);
  }
}
