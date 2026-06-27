import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/business/bloc/business_bloc.dart';
import '../features/business/bloc/business_event.dart';
import '../features/business/bloc/business_state.dart';
import '../../data/datasources/business_remote_datasource.dart';
import '../../di/service_locator.dart';
import '../../domain/entities/business_options.dart';
import '../../domain/entities/voucher.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/image_url_helper.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/common/app_widgets.dart';
import '../widgets/animations/custom_loader.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/animations/scale_tap_widget.dart';
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

  // Real categories loaded from the backend (`/business/options`). The chip
  // value sent to the partners endpoint is the category NAME, which the
  // backend matches case-insensitively against the business category.
  List<BusinessCategoryOption> _categories = [];

  @override
  void initState() {
    super.initState();
    context.read<BusinessBloc>().add(const LoadBusinessPartnersEvent());
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await getIt<BusinessRemoteDataSource>()
          .getBusinessOptions();
      if (!mounted) return;
      setState(() => _categories = categories);
    } catch (_) {
      // Filters are optional; ignore load failures and keep the "All" chip.
    }
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
        title: Text(AppLocalizations.of(context).ourPartners),
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
                    children: [
                      // "All" chip clears the category filter.
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(l10n.all),
                          selected: _selectedCategory == null,
                          onSelected: (_) {
                            setState(() => _selectedCategory = null);
                            _applyFilters();
                          },
                        ),
                      ),
                      ..._categories.map((category) {
                        final isSelected = _selectedCategory == category.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory =
                                    selected ? category.name : null;
                              });
                              _applyFilters();
                            },
                          ),
                        );
                      }),
                    ],
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
                  return const Center(child: AppLoader());
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
                      return FadeInWidget(
                        delay: 0.05 * index,
                        child: _buildPartnerCard(context, partner),
                      );
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
    return ScaleTapWidget(
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
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppTheme.primaryOrange.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Business Logo
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryOrange.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                    backgroundImage: partner.logoUrl != null
                        ? NetworkImage(ImageUrlHelper.buildImageUrl(partner.logoUrl))
                        : null,
                    child: partner.logoUrl == null
                        ? const Icon(Icons.business, size: 40, color: AppTheme.primaryOrange)
                        : null,
                  ),
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
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (partner.category != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTurquoise.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryTurquoise.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            partner.category!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryTurquoise,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if (partner.address != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                partner.address!,
                                style: TextStyle(
                                  fontSize: 13,
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
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green[300]!),
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
                Icon(Icons.chevron_right, color: AppTheme.primaryOrange),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

