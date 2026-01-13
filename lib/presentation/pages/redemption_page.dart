import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/utils/code_formatter.dart';
import '../features/redemption/bloc/redemption_bloc.dart';
import '../features/redemption/bloc/redemption_event.dart';
import '../features/redemption/bloc/redemption_state.dart';
import '../../domain/entities/redemption.dart';
import '../../generated/l10n/app_localizations.dart';
import '../widgets/common/app_widgets.dart';
import '../widgets/animations/custom_loader.dart';

/// Merchant redemption page
class RedemptionPage extends StatefulWidget {
  const RedemptionPage({super.key});

  @override
  State<RedemptionPage> createState() => _RedemptionPageState();
}

class _RedemptionPageState extends State<RedemptionPage> with TickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  int _selectedTab = 0;
  bool _isScanning = false;
  bool _isProcessingScan = false;
  String? _scanStatusMessage;
  Color _scanStatusColor = Colors.black;
  Timer? _statusResetTimer;
  String? _lastScannedCode;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    context.read<RedemptionBloc>().add(const LoadRedemptionsEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _selectedTab == 0) {
        _startScanning(showRequestUI: false);
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _scannerController.dispose();
    _statusResetTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return BlocListener<RedemptionBloc, RedemptionState>(
      listener: (context, state) {
        if (state is RedemptionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.response.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          _codeController.clear();
          setState(() {
            _isProcessingScan = false;
            _isScanning = false;
          });
          _showScanStatus(state.response.message, Colors.green);
          // Reload redemptions to update the history
          context.read<RedemptionBloc>().add(const LoadRedemptionsEvent());
        } else if (state is RedemptionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          setState(() {
            _isProcessingScan = false;
            _isScanning = false;
          });
          _showScanStatus(state.message, Colors.red);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.redemption),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.scanQr),
                Tab(text: l10n.manualEntryTitle),
              ],
            ),
            
            // Tab Content
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildQrScanner(),
                  _buildManualEntry(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrScanner() {
    final l10n = AppLocalizations.of(context);
    
    if (!_isScanning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 120,
              color: Color(0xFF1976D2),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.scanQrCode,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.placeQrInFrame,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _startScanning(),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l10n.scan),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            if (_lastScannedCode != null) ...[
              const SizedBox(height: 24),
              Text(
                l10n.scannedCodeMessage(_lastScannedCode!),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      );
    }
    
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String code = barcodes.first.rawValue ?? '';
              if (code.isNotEmpty) {
                _handleScannedCode(code);
              }
            }
          },
        ),
        if (_isProcessingScan)
          Container(
            color: Colors.black.withOpacity(0.45),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLoader(size: 20, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  l10n.processingScan,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        if (_scanStatusMessage != null)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _scanStatusMessage == null ? 0.0 : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: _scanStatusColor.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _scanStatusMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    _stopScanning();
                  },
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
  
  Future<void> _startScanning({bool showRequestUI = true}) async {
    if (!mounted || _isScanning) return;

    var status = await Permission.camera.status;
    if (!status.isGranted) {
      if (!showRequestUI) {
        return;
      }
      status = await Permission.camera.request();
    }

    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

    if (status.isPermanentlyDenied) {
      if (showRequestUI) {
        final shouldOpen = await showDialog<bool>(
          context: context,
          builder: (context) {
            final dialogL10n = AppLocalizations.of(context);
            return AlertDialog(
              title: Text(dialogL10n.cameraPermissionRequired),
              content: Text(dialogL10n.cameraPermissionDenied),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(dialogL10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(dialogL10n.openSettings),
                ),
              ],
            );
          },
        );
        if (shouldOpen == true && mounted) {
          await openAppSettings();
        }
      }
      return;
    }

    if (!status.isGranted) {
      if (showRequestUI) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cameraPermissionRequired),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      await _scannerController.start();
      if (!mounted) return;
      setState(() {
        _isScanning = true;
        _isProcessingScan = false;
      });
    } catch (_) {
      if (!mounted || !showRequestUI) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cameraPermissionRequired),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopScanning() async {
    if (_isScanning) {
      try {
        await _scannerController.stop();
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _isProcessingScan = false;
    });
  }

  Future<void> _handleScannedCode(String code) async {
    if (_isProcessingScan) return;
    setState(() {
      _isProcessingScan = true;
    });

    await _stopScanning();
    if (!mounted) return;

    final normalizedCode = code.trim();
    final cleanedCode = sanitizedVoucherCode(normalizedCode);
    final payloadCode = cleanedCode.isEmpty ? normalizedCode : cleanedCode;
    debugPrint('[Scanner] redeem payload => {"barcode": "$payloadCode"}');

    final l10n = AppLocalizations.of(context);
    final displayCode = payloadCode;
    setState(() {
      _lastScannedCode = displayCode;
    });
    _showScanStatus(
      l10n.scannedCodeMessage(displayCode),
      const Color(0xFF1976D2),
    );

    context.read<RedemptionBloc>().add(RedeemVoucherEvent(barcode: payloadCode));
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final newIndex = _tabController.index;
    if (_selectedTab == newIndex) return;

    setState(() {
      _selectedTab = newIndex;
    });

    if (newIndex == 0) {
      _startScanning(showRequestUI: false);
    } else {
      _stopScanning();
    }
  }

  Widget _buildManualEntry() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Icon(
            Icons.keyboard,
            size: 80,
            color: Color(0xFF1976D2),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.manualEntryTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.enterRedemptionCode,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: l10n.redemptionCode,
              hintText: l10n.redemptionCodeHint,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.confirmation_number),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleRedeem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: BlocBuilder<RedemptionBloc, RedemptionState>(
                builder: (context, state) {
                  if (state is RedemptionLoading) {
                    return const AppLoader(size: 20, color: Colors.white);
                  }
                  return Text(
                    l10n.redeem,
                    style: const TextStyle(fontSize: 18),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRedeem() {
    final l10n = AppLocalizations.of(context);
    
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterRedemptionCode),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cleanedCode = sanitizedVoucherCode(code);
    final payloadCode = cleanedCode.isEmpty ? code : cleanedCode;
    debugPrint('[Manual Redeem] payload => {"code": "$payloadCode"}');

    context.read<RedemptionBloc>().add(RedeemVoucherEvent(code: payloadCode));
  }

  void _showScanStatus(String message, Color color) {
    _statusResetTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _scanStatusMessage = message;
      _scanStatusColor = color;
    });
    _statusResetTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _scanStatusMessage = null;
      });
    });
  }
}

/// Redemption history page
class RedemptionHistoryPage extends StatefulWidget {
  const RedemptionHistoryPage({super.key});

  @override
  State<RedemptionHistoryPage> createState() => _RedemptionHistoryPageState();
}

class _RedemptionHistoryPageState extends State<RedemptionHistoryPage> {
  final List<String> _statusOptions = const ['completed', 'pending', 'failed'];
  final List<String> _methodOptions = const ['qr_code', 'manual_code'];
  final List<int> _limitOptions = const [20, 50, 100];

  String? _selectedStatus;
  String? _selectedMethod;
  DateTimeRange? _selectedDateRange;
  int _limit = 20;
  int _currentPage = 1;

  bool get _hasActiveFilters =>
      _selectedStatus != null ||
      _selectedMethod != null ||
      _selectedDateRange != null ||
      _limit != _limitOptions.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _dispatchRedemptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.redemptionHistory),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: () => _loadRedemptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(l10n),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<RedemptionBloc, RedemptionState>(
              builder: (context, state) {
                if (state is RedemptionLoading) {
                  return const Center(child: AppLoader());
                } else if (state is RedemptionsLoaded) {
                  if (state.redemptions.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => _loadRedemptions(resetPage: true),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 120),
                          Center(
                            child: Text(
                              l10n.noRedemptionsFound,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => _loadRedemptions(resetPage: true),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemBuilder: (context, index) => _buildRedemptionCard(state.redemptions[index], l10n),
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemCount: state.redemptions.length,
                    ),
                  );
                } else if (state is RedemptionError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => _loadRedemptions(resetPage: true),
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

  Future<void> _loadRedemptions({bool resetPage = false}) async {
    final nextPage = resetPage ? 1 : _currentPage;
    if (!mounted) return;
    setState(() {
      _currentPage = nextPage;
    });
    _dispatchRedemptions(page: nextPage);
  }

  void _dispatchRedemptions({int? page}) {
    final targetPage = page ?? _currentPage;

    final startDate = _selectedDateRange != null
        ? DateTime(
            _selectedDateRange!.start.year,
            _selectedDateRange!.start.month,
            _selectedDateRange!.start.day,
          ).toUtc()
        : null;
    final endDate = _selectedDateRange != null
        ? DateTime(
            _selectedDateRange!.end.year,
            _selectedDateRange!.end.month,
            _selectedDateRange!.end.day,
            23,
            59,
            59,
          ).toUtc()
        : null;

    context.read<RedemptionBloc>().add(
          LoadRedemptionsEvent(
            page: targetPage,
            limit: _limit,
            status: _selectedStatus,
            method: _selectedMethod,
            startDate: startDate?.toIso8601String(),
            endDate: endDate?.toIso8601String(),
          ),
        );
  }

  void _toggleStatus(String? status) {
    final newValue = status == null ? null : (_selectedStatus == status ? null : status);
    if (_selectedStatus == newValue) return;

    setState(() {
      _selectedStatus = newValue;
      _currentPage = 1;
    });
    _dispatchRedemptions(page: 1);
  }

  void _toggleMethod(String? method) {
    final newValue = method == null ? null : (_selectedMethod == method ? null : method);
    if (_selectedMethod == newValue) return;

    setState(() {
      _selectedMethod = newValue;
      _currentPage = 1;
    });
    _dispatchRedemptions(page: 1);
  }

  Future<void> _pickDateRange() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5);
    final lastDate = DateTime(now.year + 1);

    final initialRange = _selectedDateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );

    final newRange = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialRange,
      helpText: l10n.selectDateRange,
      locale: Localizations.localeOf(context),
    );

    if (newRange != null) {
      setState(() {
        _selectedDateRange = newRange;
        _currentPage = 1;
      });
      _dispatchRedemptions(page: 1);
    }
  }

  void _clearDateRange() {
    if (_selectedDateRange == null) return;
    setState(() {
      _selectedDateRange = null;
      _currentPage = 1;
    });
    _dispatchRedemptions(page: 1);
  }

  void _clearFilters() {
    if (!_hasActiveFilters) return;
    setState(() {
      _selectedStatus = null;
      _selectedMethod = null;
      _selectedDateRange = null;
      _limit = _limitOptions.first;
      _currentPage = 1;
    });
    _dispatchRedemptions(page: 1);
  }

  Widget _buildFilters(AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.filters,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: _hasActiveFilters ? _clearFilters : null,
                icon: const Icon(Icons.clear_all),
                label: Text(l10n.clearFilters),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.status, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: l10n.all,
                selected: _selectedStatus == null,
                onSelected: () => _toggleStatus(null),
              ),
              ..._statusOptions.map(
                (status) => _buildChoiceChip(
                  label: _statusLabel(status, l10n),
                  selected: _selectedStatus == status,
                  onSelected: () => _toggleStatus(status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.method, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: l10n.all,
                selected: _selectedMethod == null,
                onSelected: () => _toggleMethod(null),
              ),
              ..._methodOptions.map(
                (method) => _buildChoiceChip(
                  label: _methodLabel(method, l10n),
                  selected: _selectedMethod == method,
                  onSelected: () => _toggleMethod(method),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.dateRange, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _selectedDateRange == null
                          ? l10n.selectDateRange
                          : _formatDateRangeLabel(_selectedDateRange!),
                    ),
                  ),
                ),
              ),
              if (_selectedDateRange != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _clearDateRange,
                  icon: const Icon(Icons.close),
                  tooltip: l10n.clearFilters,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<int>(
              value: _limit,
              items: _limitOptions
                  .map(
                    (value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null || value == _limit) return;
                setState(() {
                  _limit = value;
                  _currentPage = 1;
                });
                _dispatchRedemptions(page: 1);
              },
              decoration: InputDecoration(
                labelText: l10n.limit,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: theme.colorScheme.primary.withOpacity(0.15),
      labelStyle: TextStyle(
        color: selected ? theme.colorScheme.primary : null,
        fontWeight: selected ? FontWeight.bold : null,
      ),
      side: selected ? BorderSide(color: theme.colorScheme.primary) : null,
    );
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'completed':
        return l10n.redemptionStatusCompleted;
      case 'pending':
        return l10n.redemptionStatusPending;
      case 'failed':
        return l10n.redemptionStatusFailed;
      default:
        return status;
    }
  }

  String _methodLabel(String method, AppLocalizations l10n) {
    switch (method.toLowerCase()) {
      case 'qr_code':
        return l10n.redemptionMethodQrCode;
      case 'manual_code':
        return l10n.redemptionMethodManualCode;
      default:
        return method;
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }

  String _formatTime(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateRangeLabel(DateTimeRange range) {
    final start = _formatDate(range.start);
    final end = _formatDate(range.end);
    if (start == end) {
      return start;
    }
    return '$start - $end';
  }

  String _formatAmount(Redemption redemption) {
    if (redemption.amountMinor % 100 == 0) {
      return (redemption.amountMinor ~/ 100).toString();
    }
    return (redemption.amountMinor / 100).toStringAsFixed(2);
  }

  Widget _buildRedemptionCard(Redemption redemption, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    redemption.voucherTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(redemption.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(redemption.status, l10n),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.amount}: ${_formatAmount(redemption)} ${redemption.currency}',
              style: theme.textTheme.bodyMedium,
            ),
            if (redemption.coinAmount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.coins}: ${redemption.coinAmount}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (redemption.customerPhone != null && redemption.customerPhone!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.customer}: ${redemption.customerPhone}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (redemption.method != null && redemption.method!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.method}: ${_methodLabel(redemption.method!, l10n)}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (redemption.businessName != null && redemption.businessName!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.business}: ${redemption.businessName}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${l10n.date}: ${_formatDate(redemption.redemptionDate)} • ${_formatTime(redemption.redemptionDate)}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
