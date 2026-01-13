import 'package:flutter/material.dart';

import '../../../generated/l10n/app_localizations.dart';
import '../widgets/common/app_widgets.dart';

class MerchantPartnersPage extends StatefulWidget {
  const MerchantPartnersPage({super.key});

  @override
  State<MerchantPartnersPage> createState() => _MerchantPartnersPageState();
}

class _MerchantPartnersPageState extends State<MerchantPartnersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tous'; // All

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.merchantPartners),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Mock refresh action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refresh functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                AppTextField(
                  controller: _searchController,
                  labelText: l10n.searchPartners,
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    // Mock search functionality
                  },
                ),
                const SizedBox(height: 16),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('Tous', _selectedCategory == 'Tous'),
                      const SizedBox(width: 8),
                      _buildCategoryChip('Restaurants', _selectedCategory == 'Restaurants'),
                      const SizedBox(width: 8),
                      _buildCategoryChip('Shopping', _selectedCategory == 'Shopping'),
                      const SizedBox(width: 8),
                      _buildCategoryChip('Services', _selectedCategory == 'Services'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Partners List - Mock data for now
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5, // Mock data
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Icon(
                        Icons.business,
                        color: Colors.blue[700],
                      ),
                    ),
                    title: Text('Partner ${index + 1}'),
                    subtitle: Text('Category: ${_getMockCategory(index)}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Mock partner detail action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Partner ${index + 1} details coming soon')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? label : 'Tous';
        });
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[700],
    );
  }

  String _getMockCategory(int index) {
    final categories = ['Restaurants', 'Shopping', 'Services', 'Restaurants', 'Shopping'];
    return categories[index % categories.length];
  }
}