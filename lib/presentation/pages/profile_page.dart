import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../features/auth/bloc/auth_state.dart';
import '../../domain/entities/user.dart';
import '../../generated/l10n/app_localizations.dart';
import '../widgets/additional_info_field_controller.dart';
import '../../di/service_locator.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../core/utils/image_url_helper.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/animations/custom_loader.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/animations/slide_in_widget.dart';
import '../widgets/animations/scale_tap_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final List<AdditionalInfoFieldController> _additionalInfoEntries = [];

  bool _initialized = false;
  bool _isSubmitting = false;
  bool _isLoading = false;
  bool _requestedAuthCheck = false;

  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  User? _currentUser;
  File? _selectedProfileImage;
  String? _profileImageUrl; // Store uploaded image URL

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _populateFromUser(authState.user);
      _initialized = true;
    } else if (authState is ProfileCompletionRequired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).completeProfile),
          ),
        );
      });
    } else {
      _maybeRequestAuthCheck();
    }

    if (_additionalInfoEntries.isEmpty) {
      _additionalInfoEntries.add(AdditionalInfoFieldController());
    }
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
        title: Text(l10n.profile),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => current is! AuthLoading || _isSubmitting,
        listener: (context, state) {
          if (state is AuthLoading && _isSubmitting) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is Authenticated) {
            if (!_initialized) {
              _populateFromUser(state.user);
              setState(() {
                _initialized = true;
              });
              return;
            }

            if (_isSubmitting) {
              _populateFromUser(state.user);
              setState(() {
                _isSubmitting = false;
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.profileUpdated),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else if (state is AuthError && _isSubmitting) {
            setState(() {
              _isSubmitting = false;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is Unauthenticated && mounted) {
            Navigator.of(context).pop();
          }
        },
        child: _buildContent(l10n),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (!_initialized && !_isLoading) {
      return const Center(child: AppLoader());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final isSmallScreen = screenWidth < 360 || screenHeight < 640;
        final isTablet = screenWidth > 600;

        final subtitleFontSize = isSmallScreen ? 14.0 : (isTablet ? 18.0 : 16.0);
        final fieldSpacing = isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0);
        final sectionSpacing = isSmallScreen ? 24.0 : (isTablet ? 40.0 : 32.0);
        final horizontalPadding = isSmallScreen ? 16.0 : (isTablet ? 48.0 : 24.0);

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: sectionSpacing / 2,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(l10n),
                    SizedBox(height: sectionSpacing),
                    Text(
                      l10n.profileInformation,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: fieldSpacing),
                    _buildNameFields(fieldSpacing, l10n),
                    SizedBox(height: fieldSpacing),
                    _buildEmailField(l10n),
                    SizedBox(height: fieldSpacing),
                    _buildDateOfBirthField(l10n),
                    SizedBox(height: fieldSpacing),
                    _buildGenderField(l10n),
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
                      'Ces informations supplémentaires sont optionnelles et peuvent être utilisées pour personnaliser votre expérience. Vous pouvez les laisser vides si vous ne souhaitez pas les remplir.',
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
                        onPressed: _isLoading ? null : _handleSaveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12.0 : 16.0,
                          ),
                        ),
                        child: _isLoading
                            ? const AppLoader(size: 20, color: Colors.white)
                            : Text(
                                l10n.saveChanges,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14.0 : 16.0,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader(AppLocalizations l10n) {
    final user = _currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return FadeInWidget(
      delay: 0.1,
      child: SlideInWidget(
        delay: 0.1,
        begin: const Offset(0, -0.2),
        child: Card(
          elevation: 2,
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
                  AppTheme.primaryOrange.withOpacity(0.1),
                  AppTheme.primaryTurquoise.withOpacity(0.1),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                            backgroundImage: _selectedProfileImage != null
                                ? FileImage(_selectedProfileImage!)
                                : (_getProfileImageUrl() != null
                                    ? NetworkImage(_getProfileImageUrl()!)
                                    : null) as ImageProvider?,
                            child: _selectedProfileImage == null && _getProfileImageUrl() == null
                                ? Text(
                                    (user.firstName ?? user.lastName ?? user.phone).substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryOrange,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: ScaleTapWidget(
                              onTap: _pickProfileImage,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppTheme.primaryOrange,
                                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.firstName != null
                                  ? '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()
                                  : user.phone,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.phone,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        label: l10n.role,
                        value: user.role,
                      ),
                      if (user.email != null && user.email!.isNotEmpty)
                        _buildInfoChip(
                          label: l10n.email,
                          value: user.email!,
                        ),
                      if (user.gender != null && user.gender!.isNotEmpty)
                        _buildInfoChip(
                          label: l10n.gender,
                          value: _genderLabel(l10n, user.gender!),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.darkGray,
        ),
      ),
    );
  }

  Widget _buildNameFields(double fieldSpacing, AppLocalizations l10n) {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: l10n.emailOptional,
          prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryOrange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
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
    );
  }

  Widget _buildDateOfBirthField(AppLocalizations l10n) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _dateOfBirthController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: l10n.dateOfBirthOptional,
          prefixIcon: Icon(Icons.cake_outlined, color: AppTheme.primaryOrange),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onTap: _selectDateOfBirth,
      ),
    );
  }

  Widget _buildGenderField(AppLocalizations l10n) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender != null && _genderOptions.contains(_selectedGender) ? _selectedGender : null,
        decoration: InputDecoration(
          labelText: l10n.genderOptional,
          prefixIcon: Icon(Icons.wc_outlined, color: AppTheme.primaryOrange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
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
    );
  }

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

  void _handleSaveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profileData = <String, dynamic>{
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      if (_emailController.text.trim().isNotEmpty) 'email': _emailController.text.trim(),
      if (_selectedDateOfBirth != null) 'date_of_birth': _formatDate(_selectedDateOfBirth!),
      if (_selectedGender != null && _selectedGender!.isNotEmpty) 'gender': _selectedGender,
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

    setState(() {
      _isSubmitting = true;
    });
    context.read<AuthBloc>().add(UpdateProfileEvent(profileData));
  }

  void _populateFromUser(User user) {
    _currentUser = user;
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _emailController.text = user.email ?? '';
    
    // Set profile image URL from user data
    if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
      _profileImageUrl = ImageUrlHelper.buildImageUrl(user.profileImageUrl);
    }

    if (user.dateOfBirth != null) {
      _selectedDateOfBirth = user.dateOfBirth;
      _dateOfBirthController.text = _formatDate(user.dateOfBirth!);
    } else {
      _selectedDateOfBirth = null;
      _dateOfBirthController.clear();
    }

    if (user.gender != null && user.gender!.isNotEmpty) {
      _selectedGender = user.gender;
    } else {
      _selectedGender = null;
    }

    for (final entry in _additionalInfoEntries) {
      entry.dispose();
    }
    _additionalInfoEntries
      ..clear()
      ..addAll(
        _mapAdditionalInfo(user.additionalInfo).entries.map(
              (entry) => AdditionalInfoFieldController(
                key: entry.key,
                value: entry.value,
              ),
            ),
      );

    if (_additionalInfoEntries.isEmpty) {
      _additionalInfoEntries.add(AdditionalInfoFieldController());
    }
  }

  Map<String, String> _mapAdditionalInfo(Map<String, dynamic>? info) {
    if (info == null || info.isEmpty) return {};
    final mapped = <String, String>{};
    info.forEach((key, value) {
      if (key.isNotEmpty && value != null && value.toString().isNotEmpty) {
        mapped[key] = value.toString();
      }
    });
    return mapped;
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

  static const List<String> _genderOptions = [
    'unknown',
    'male',
    'female',
    'non_binary',
    'other',
  ];

  void _maybeRequestAuthCheck() {
    if (_requestedAuthCheck) return;
    _requestedAuthCheck = true;
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
  }

  String? _getProfileImageUrl() {
    if (_selectedProfileImage != null) return null; // Use FileImage for selected
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return _profileImageUrl;
    }
    if (_currentUser?.profileImageUrl != null && _currentUser!.profileImageUrl!.isNotEmpty) {
      return ImageUrlHelper.buildImageUrl(_currentUser!.profileImageUrl);
    }
    return null;
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir une photo'), // Will be localized
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Caméra'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (image != null) {
        setState(() {
          _selectedProfileImage = File(image.path);
        });
        
        // Upload image to backend
        try {
          final authRepo = getIt<AuthRepositoryImpl>();
          final imageUrl = await authRepo.uploadProfileImage(image.path);
          
          setState(() {
            // Build full URL from relative path returned by backend
            _profileImageUrl = ImageUrlHelper.buildImageUrl(imageUrl);
          });
          
          // Refresh user data to get updated profile_image_url
          context.read<AuthBloc>().add(const CheckAuthStatusEvent());
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo de profil mise à jour avec succès'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de l\'upload: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}


