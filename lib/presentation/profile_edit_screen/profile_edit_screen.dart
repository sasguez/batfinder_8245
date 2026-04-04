import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../services/profile_service.dart';
import '../../widgets/custom_app_bar.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic>? existingProfile;

  const ProfileEditScreen({super.key, this.existingProfile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();
  final _imagePicker = ImagePicker();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _organizationController = TextEditingController();

  String _selectedRole = 'ciudadano';
  bool _isLoading = false;
  bool _isNewProfile = true;
  File? _selectedImage;
  String? _currentPhotoUrl;
  String? _currentPhotoPath;

  // Progressive validation state
  bool _nameValid = false;
  bool _phoneValid = false;
  bool _photoValid = false;
  double _completionPercentage = 0.0;

  // Field touch state for error display
  bool _nameTouched = false;
  bool _phoneTouched = false;

  final List<Map<String, String>> _roles = [
    {'value': 'ciudadano', 'label': 'Ciudadano'},
    {'value': 'autoridad', 'label': 'Autoridad'},
    {'value': 'ONG', 'label': 'ONG'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _loadExistingProfile();
      _isNewProfile = false;
      _loadProfilePhoto();
    }

    // Add listeners for progressive validation
    _fullNameController.addListener(_validateFields);
    _phoneController.addListener(_validateFields);

    // Initial validation
    _validateFields();
  }

  void _validateFields() {
    setState(() {
      // Validate name (required, minimum 3 characters)
      _nameValid = _fullNameController.text.trim().length >= 3;

      // Validate phone (required, minimum 10 digits)
      final phoneDigits = _phoneController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      _phoneValid = phoneDigits.length >= 10;

      // Validate photo (required)
      _photoValid = _selectedImage != null || _currentPhotoUrl != null;

      // Calculate completion percentage
      int completedFields = 0;
      const int totalRequiredFields = 3; // name, phone, photo

      if (_nameValid) completedFields++;
      if (_phoneValid) completedFields++;
      if (_photoValid) completedFields++;

      _completionPercentage = (completedFields / totalRequiredFields) * 100;
    });
  }

  void _loadExistingProfile() {
    final profile = widget.existingProfile!;
    _fullNameController.text = profile['full_name'] ?? '';
    _emailController.text = profile['email'] ?? '';
    _phoneController.text = profile['phone_number'] ?? '';
    _organizationController.text = profile['organization_name'] ?? '';
    _selectedRole = profile['role'] ?? 'ciudadano';
    _currentPhotoPath = profile['profile_image_url'];
  }

  Future<void> _loadProfilePhoto() async {
    if (_currentPhotoPath != null && _currentPhotoPath!.isNotEmpty) {
      try {
        final url = await _profileService.getProfilePhotoUrl(_currentPhotoPath);
        if (mounted) {
          setState(() {
            _currentPhotoUrl = url;
            _validateFields();
          });
        }
      } catch (e) {
        // Silently fail - photo might not exist
        if (mounted) {
          setState(() {
            _currentPhotoUrl = null;
            _validateFields();
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _currentPhotoUrl = null;
          _validateFields();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    // Mark all fields as touched for validation
    setState(() {
      _nameTouched = true;
      _phoneTouched = true;
    });

    if (!_formKey.currentState!.validate()) return;

    // Additional validation for required fields
    if (!_nameValid || !_phoneValid || !_photoValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? uploadedPhotoPath = _currentPhotoPath;

      // Upload new photo if selected
      if (_selectedImage != null) {
        // Delete old photo if exists
        if (_currentPhotoPath != null && _currentPhotoPath!.isNotEmpty) {
          await _profileService.deleteProfilePhoto(_currentPhotoPath!);
        }
        uploadedPhotoPath = await _profileService.uploadProfilePhoto(
          _selectedImage!,
        );
      }

      if (_isNewProfile) {
        await _profileService.createUserProfile(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          role: _selectedRole,
          phoneNumber: _phoneController.text.trim(),
          organizationName: _organizationController.text.trim().isEmpty
              ? null
              : _organizationController.text.trim(),
          profileImageUrl: uploadedPhotoPath,
        );
      } else {
        final userId = widget.existingProfile!['id'];
        await _profileService.updateUserProfile(
          userId: userId,
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          organizationName: _organizationController.text.trim().isEmpty
              ? null
              : _organizationController.text.trim(),
          profileImageUrl: uploadedPhotoPath,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isNewProfile
                  ? 'Perfil creado exitosamente'
                  : 'Perfil actualizado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isNewProfile ? 'Crear Perfil' : 'Editar Perfil',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(4.w),
          children: [
            // Completion Progress Indicator
            _buildCompletionIndicator(),

            SizedBox(height: 3.h),

            if (_isNewProfile) ...[
              Text(
                'Completa los campos requeridos (*) para continuar',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
              ),
              SizedBox(height: 2.h),
            ],

            // Profile Photo Section with validation indicator
            _buildPhotoSection(),

            SizedBox(height: 3.h),

            // Name Field with progressive validation
            _buildNameField(),

            SizedBox(height: 2.h),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              enabled: _isNewProfile,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su correo electrónico';
                }
                if (!value.contains('@')) {
                  return 'Por favor ingrese un correo válido';
                }
                return null;
              },
            ),

            SizedBox(height: 2.h),

            // Phone Field with progressive validation
            _buildPhoneField(),

            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Tipo de Usuario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              items: _roles.map((role) {
                return DropdownMenuItem(
                  value: role['value'],
                  child: Text(role['label']!),
                );
              }).toList(),
              onChanged: _isNewProfile
                  ? (value) {
                      if (value != null) {
                        setState(() => _selectedRole = value);
                      }
                    }
                  : null,
            ),

            if (_selectedRole == 'ONG' || _selectedRole == 'autoridad') ...[
              SizedBox(height: 2.h),
              TextFormField(
                controller: _organizationController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Organización',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if ((_selectedRole == 'ONG' ||
                          _selectedRole == 'autoridad') &&
                      (value == null || value.isEmpty)) {
                    return 'Por favor ingrese el nombre de la organización';
                  }
                  return null;
                },
              ),
            ],

            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isNewProfile ? 'Crear Perfil' : 'Guardar Cambios',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionIndicator() {
    final color = _completionPercentage == 100
        ? Colors.green
        : _completionPercentage >= 66
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withAlpha(77), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completado del perfil',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                '${_completionPercentage.toInt()}%',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: LinearProgressIndicator(
              value: _completionPercentage / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          SizedBox(height: 1.h),
          _buildFieldStatusList(),
        ],
      ),
    );
  }

  Widget _buildFieldStatusList() {
    return Column(
      children: [
        _buildFieldStatus('Nombre completo', _nameValid),
        _buildFieldStatus('Teléfono', _phoneValid),
        _buildFieldStatus('Foto de perfil', _photoValid),
      ],
    );
  }

  Widget _buildFieldStatus(String fieldName, bool isValid) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isValid ? Colors.green : Colors.grey,
          ),
          SizedBox(width: 2.w),
          Text(
            fieldName,
            style: TextStyle(
              fontSize: 12.sp,
              color: isValid ? Colors.green.shade700 : Colors.grey.shade600,
              decoration: isValid ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    final hasPhoto = _selectedImage != null || _currentPhotoUrl != null;
    final borderColor = _photoValid
        ? Colors.green
        : (_nameTouched || _phoneTouched ? Colors.red : Colors.grey);

    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (_currentPhotoUrl != null
                                  ? CachedNetworkImageProvider(
                                      _currentPhotoUrl!,
                                    )
                                  : null)
                              as ImageProvider?,
                    child: !hasPhoto
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey.shade600,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                if (_photoValid)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Foto de perfil *',
          style: TextStyle(
            fontSize: 12.sp,
            color: _photoValid ? Colors.green : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (!_photoValid && (_nameTouched || _phoneTouched))
          Padding(
            padding: EdgeInsets.only(top: 0.5.h),
            child: Text(
              'Foto de perfil requerida',
              style: TextStyle(fontSize: 11.sp, color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildNameField() {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setState(() => _nameTouched = true);
        }
      },
      child: TextFormField(
        controller: _fullNameController,
        decoration: InputDecoration(
          labelText: 'Nombre Completo *',
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: _nameValid
                  ? Colors.green
                  : (_nameTouched && !_nameValid ? Colors.red : Colors.grey),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _nameValid
                  ? Colors.green
                  : (_nameTouched && !_nameValid
                        ? Colors.red
                        : Colors.grey.shade400),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _nameValid ? Colors.green : Colors.blue,
              width: 2,
            ),
          ),
          prefixIcon: Icon(
            Icons.person,
            color: _nameValid
                ? Colors.green
                : (_nameTouched && !_nameValid ? Colors.red : Colors.grey),
          ),
          suffixIcon: _nameValid
              ? Icon(Icons.check_circle, color: Colors.green)
              : (_nameTouched && !_nameValid
                    ? Icon(Icons.error, color: Colors.red)
                    : null),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese su nombre completo';
          }
          if (value.trim().length < 3) {
            return 'El nombre debe tener al menos 3 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneField() {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setState(() => _phoneTouched = true);
        }
      },
      child: TextFormField(
        controller: _phoneController,
        decoration: InputDecoration(
          labelText: 'Teléfono *',
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: _phoneValid
                  ? Colors.green
                  : (_phoneTouched && !_phoneValid ? Colors.red : Colors.grey),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _phoneValid
                  ? Colors.green
                  : (_phoneTouched && !_phoneValid
                        ? Colors.red
                        : Colors.grey.shade400),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _phoneValid ? Colors.green : Colors.blue,
              width: 2,
            ),
          ),
          prefixIcon: Icon(
            Icons.phone,
            color: _phoneValid
                ? Colors.green
                : (_phoneTouched && !_phoneValid ? Colors.red : Colors.grey),
          ),
          suffixIcon: _phoneValid
              ? Icon(Icons.check_circle, color: Colors.green)
              : (_phoneTouched && !_phoneValid
                    ? Icon(Icons.error, color: Colors.red)
                    : null),
          hintText: '1234567890',
        ),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese su teléfono';
          }
          final phoneDigits = value.replaceAll(RegExp(r'[^0-9]'), '');
          if (phoneDigits.length < 10) {
            return 'El teléfono debe tener al menos 10 dígitos';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    super.dispose();
  }
}
