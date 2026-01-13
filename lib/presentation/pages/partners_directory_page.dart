import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/business/bloc/business_bloc.dart';
import '../features/business/bloc/business_event.dart';
import '../features/business/bloc/business_state.dart';
import '../../domain/entities/voucher.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/image_url_helper.dart';
import '../widgets/common/app_widgets.dart';
import 'vouchers_page.dart';

/// Partners directory page showing all business partners
class PartnersDirectoryPage extends StatefulWidget {
  const PartnersDirectoryPage({super.key});

  @override
  State<PartnersDirectoryPage> createState() => _PartnersDirectoryPageState();
}

class _PartnersDirectoryPageState extends State<PartnersDirectoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  
  // Category values that match the API (not localized)
  // These are the actual category values sent to the backend
  static const List<Map<String, String?>> _categoryOptions = [
    {'value': null, 'key': 'all'}, // null means all
    {'value': 'Restaurant', 'key': 'restaurants'},
    {'value': 'Shopping', 'key': 'shopping'},
    {'value': 'Services', 'key': 'services'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<BusinessBloc>().add(const LoadBusinessPartnersEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nos Partenaires'), // Will be localized
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchPartners,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categoryOptions.map((option) {
                      final categoryValue = option['value'];
                      final localizationKey = option['key']!;
                      final categoryLabel = _getLocalizedCategory(localizationKey);
                      final isSelected = _selectedCategory == categoryValue;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(categoryLabel),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? categoryValue : null;
                            });
                            _applyFilters();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Partners List
          Expanded(
            child: BlocBuilder<BusinessBloc, BusinessState>(
              builder: (context, state) {
                if (state is BusinessLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BusinessPartnersLoaded) {
                  if (state.partners.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noPartnersFound,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.partners.length,
                    itemBuilder: (context, index) {
                      final partner = state.partners[index];
                      return _buildPartnerCard(context, partner);
                    },
                  );
                } else if (state is BusinessError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () {
                      _applyFilters();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedCategory(String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'all':
        return l10n.all;
      case 'restaurants':
        return l10n.restaurants;
      case 'shopping':
        return l10n.shopping;
      case 'services':
        return l10n.services;
      default:
        return key;
    }
  }

  void _applyFilters() {
    final category = _selectedCategory; // Already null or the actual API value
    final search = _searchController.text.trim().isEmpty 
        ? null 
        : _searchController.text.trim();
    
    context.read<BusinessBloc>().add(
      LoadBusinessPartnersEvent(
        category: category,
        search: search,
      ),
    );
  }

  Widget _buildPartnerCard(BuildContext context, Business partner) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navigate to vouchers page filtered by this business
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VouchersPage(
                businessId: partner.id,
                businessName: partner.name,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Business Logo
              CircleAvatar(
                radius: 40,
                backgroundImage: partner.logoUrl != null
                    ? NetworkImage(ImageUrlHelper.buildImageUrl(partner.logoUrl))
                    : null,
                child: partner.logoUrl == null
                    ? const Icon(Icons.business, size: 40)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (partner.category != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        partner.category!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (partner.address != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              partner.address!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (partner.activeVouchersCount != null && partner.activeVouchersCount! > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          '${partner.activeVouchersCount} ${l10n.activeVouchers}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

