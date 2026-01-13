import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../widgets/additional_info_field_controller.dart';

/// Profile completion page for first-time users
class ProfileCompletionPage extends StatefulWidget {
  const ProfileCompletionPage({super.key});

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  final List<AdditionalInfoFieldController> _additionalInfoEntries = [];
  bool _initialized = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final authState = context.read<AuthBloc>().state;

    void populateFromUser(ProfileCompletionRequired state) {
      final user = state.user;
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _emailController.text = user.email ?? '';
      if (user.dateOfBirth != null) {
        _selectedDateOfBirth = user.dateOfBirth;
        _dateOfBirthController.text = _formatDate(user.dateOfBirth!);
      }
      if (user.gender != null && user.gender!.isNotEmpty) {
        _selectedGender = user.gender;
      }
      final info = user.additionalInfo;
      if (info is Map<String, dynamic>) {
        info.forEach((key, value) {
          if (key.isNotEmpty && value != null && value.toString().isNotEmpty) {
            _additionalInfoEntries.add(
              AdditionalInfoFieldController(
                key: key,
                value: value.toString(),
              ),
            );
          }
        });
      }
    }

    if (authState is ProfileCompletionRequired) {
      populateFromUser(authState);
    } else if (authState is Authenticated) {
      final user = authState.user;
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _emailController.text = user.email ?? '';
      if (user.dateOfBirth != null) {
        _selectedDateOfBirth = user.dateOfBirth;
        _dateOfBirthController.text = _formatDate(user.dateOfBirth!);
      }
      if (user.gender != null && user.gender!.isNotEmpty) {
        _selectedGender = user.gender;
      }
      final info = user.additionalInfo;
      if (info is Map<String, dynamic>) {
        info.forEach((key, value) {
          if (key.isNotEmpty && value != null && value.toString().isNotEmpty) {
            _additionalInfoEntries.add(
              AdditionalInfoFieldController(
                key: key,
                value: value.toString(),
              ),
            );
          }
        });
      }
    }

    if (_additionalInfoEntries.isEmpty) {
      _additionalInfoEntries.add(AdditionalInfoFieldController());
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    for (final entry in _additionalInfoEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileCompletion),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // RouterWrapper will automatically handle navigation based on AuthState
          // No need to manually navigate here
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isSmallScreen = screenWidth < 360 || screenHeight < 640;
            final isTablet = screenWidth > 600;

            final iconSize = isSmallScreen ? 60.0 : (isTablet ? 100.0 : 80.0);
            final titleFontSize = isSmallScreen ? 22.0 : (isTablet ? 32.0 : 28.0);
            final subtitleFontSize = isSmallScreen ? 14.0 : (isTablet ? 18.0 : 16.0);
            final fieldSpacing = isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0);
            final sectionSpacing = isSmallScreen ? 24.0 : (isTablet ? 40.0 : 32.0);
            final topSpacing = isSmallScreen ? 16.0 : (isTablet ? 28.0 : 24.0);
            final horizontalPadding = isSmallScreen ? 16.0 : (isTablet ? 48.0 : 24.0);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: topSpacing,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - kToolbarHeight,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add,
                        size: iconSize,
                        color: const Color(0xFF1976D2),
                      ),
                      SizedBox(height: topSpacing),
                      Text(
                        l10n.completeYourProfile,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4.0 : 8.0),
                      Text(
                        l10n.helpPersonalizeExperience,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: sectionSpacing),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: '${l10n.firstName} *',
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.firstNameRequired;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: fieldSpacing),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: '${l10n.lastName} *',
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.lastNameRequired;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: fieldSpacing),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: l10n.emailOptional,
                          prefixIcon: const Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return l10n.invalidEmailFormat;
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: fieldSpacing),
                      TextFormField(
                        controller: _dateOfBirthController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: l10n.dateOfBirthOptional,
                          prefixIcon: const Icon(Icons.cake_outlined),
                          suffixIcon: _selectedDateOfBirth != null
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedDateOfBirth = null;
                                      _dateOfBirthController.clear();
                                    });
                                  },
                                  tooltip: l10n.clearField,
                                  icon: const Icon(Icons.clear),
                                )
                              : null,
                        ),
                        onTap: _selectDateOfBirth,
                      ),
                      SizedBox(height: fieldSpacing),
                      DropdownButtonFormField<String>(
                        value: _selectedGender != null && _genderOptions.contains(_selectedGender)
                            ? _selectedGender
                            : null,
                        decoration: InputDecoration(
                          labelText: l10n.genderOptional,
                          prefixIcon: const Icon(Icons.wc_outlined),
                        ),
                        items: _genderOptions
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(_genderLabel(l10n, value)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      SizedBox(height: sectionSpacing),
                      Text(
                        l10n.additionalInfoOptional,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        l10n.additionalInfoHint,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12.0 : 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: fieldSpacing),
                      ..._buildAdditionalInfoFields(l10n, fieldSpacing),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _additionalInfoEntries.add(AdditionalInfoFieldController());
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addAdditionalInfoField),
                        ),
                      ),
                      SizedBox(height: sectionSpacing),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleCompleteProfile,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12.0 : 16.0,
                            ),
                          ),
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is AuthLoading) {
                                return const CircularProgressIndicator(color: Colors.white);
                              }
                              return Text(
                                l10n.completeProfile,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14.0 : 16.0,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static const List<String> _genderOptions = [
    'unknown',
    'male',
    'female',
    'non_binary',
    'other',
  ];

  List<Widget> _buildAdditionalInfoFields(AppLocalizations l10n, double spacing) {
    return [
      for (int index = 0; index < _additionalInfoEntries.length; index++)
        Padding(
          padding: EdgeInsets.only(bottom: index == _additionalInfoEntries.length - 1 ? 0 : spacing),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _additionalInfoEntries[index].keyController,
                  decoration: InputDecoration(
                    labelText: l10n.additionalInfoKeyLabel,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: TextFormField(
                  controller: _additionalInfoEntries[index].valueController,
                  decoration: InputDecoration(
                    labelText: l10n.additionalInfoValueLabel,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Tooltip(
                message: l10n.removeAdditionalInfoField,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (_additionalInfoEntries.length == 1) {
                        _additionalInfoEntries[index].keyController.clear();
                        _additionalInfoEntries[index].valueController.clear();
                      } else {
                        _additionalInfoEntries.removeAt(index).dispose();
                      }
                    });
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  Future<void> _selectDateOfBirth() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: AppLocalizations.of(context).selectDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dateOfBirthController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _genderLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'male':
        return l10n.male;
      case 'female':
        return l10n.female;
      case 'non_binary':
        return l10n.nonBinary;
      case 'other':
        return l10n.other;
      default:
        return l10n.unknown;
    }
  }

  void _handleCompleteProfile() {
    if (_formKey.currentState!.validate()) {
      final profileData = <String, dynamic>{
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        if (_emailController.text.trim().isNotEmpty)
          'email': _emailController.text.trim(),
        if (_selectedDateOfBirth != null)
          'date_of_birth': _formatDate(_selectedDateOfBirth!),
        if (_selectedGender != null && _selectedGender!.isNotEmpty)
          'gender': _selectedGender,
      };

      final additionalInfo = <String, dynamic>{};
      for (final entry in _additionalInfoEntries) {
        final key = entry.keyController.text.trim();
        final value = entry.valueController.text.trim();
        if (key.isNotEmpty && value.isNotEmpty) {
          additionalInfo[key] = value;
        }
      }

      if (additionalInfo.isNotEmpty) {
        profileData['additional_info'] = additionalInfo;
      }

      context.read<AuthBloc>().add(UpdateProfileEvent(profileData));
    }
  }
}