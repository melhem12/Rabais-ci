import 'package:flutter/material.dart';

import '../../../generated/l10n/app_localizations.dart';
import '../widgets/common/app_widgets.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/animations/scale_tap_widget.dart';
import '../../core/theme/app_theme.dart';

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
                return FadeInWidget(
                  delay: index * 0.1,
                  child: ScaleTapWidget(
                    onTap: () {
                      // Mock partner detail action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Partner ${index + 1} details coming soon')),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              AppTheme.primaryTurquoise.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryOrange,
                                  AppTheme.primaryTurquoise,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.business,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            'Partner ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          subtitle: Text('Category: ${_getMockCategory(index)}'),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ),
                    ),
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
      selectedColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryOrange,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryOrange : AppTheme.navyBlue,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryOrange : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  String _getMockCategory(int index) {
    final categories = ['Restaurants', 'Shopping', 'Services', 'Restaurants', 'Shopping'];
    return categories[index % categories.length];
  }
}