import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/salon_provider.dart';
import '../../models/salon.dart';
import '../../config/theme.dart';

// Pure Dart Code - All Salons Screen
class AllSalonsScreen extends StatefulWidget {
  const AllSalonsScreen({super.key});

  @override
  State<AllSalonsScreen> createState() => _AllSalonsScreenState();
}

class _AllSalonsScreenState extends State<AllSalonsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalonProvider>().loadAllSalons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Salons'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SalonProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.salons.isEmpty) {
            return const Center(child: Text('No salons available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.salons.length,
            itemBuilder: (context, index) {
              return _buildSalonCard(provider.salons[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildSalonCard(Salon salon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to salon details
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salon Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: salon.imageUrl != null
                    ? Image.network(
                        salon.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.store, size: 48);
                        },
                      )
                    : const Icon(Icons.store, size: 48),
              ),
            ),
            // Salon Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salon.salonName ?? 'Salon',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${salon.city ?? ""}, ${salon.state ?? ""}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (salon.category != null) ...[
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(salon.category!),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

