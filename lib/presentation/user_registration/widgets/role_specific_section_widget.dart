import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Role-Specific Section Widget
/// Shows different fields based on selected role
class RoleSpecificSectionWidget extends StatelessWidget {
  final String selectedRole;
  final String? selectedMunicipality;
  final String? badgePhotoPath;
  final TextEditingController organizationController;
  final Function(String?) onMunicipalityChanged;
  final Function(String) onBadgePhotoSelected;

  const RoleSpecificSectionWidget({
    super.key,
    required this.selectedRole,
    required this.selectedMunicipality,
    required this.badgePhotoPath,
    required this.organizationController,
    required this.onMunicipalityChanged,
    required this.onBadgePhotoSelected,
  });

  // Colombian municipalities (sample list)
  static final List<String> _colombianMunicipalities = [
    'Bogotá D.C.',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Cúcuta',
    'Bucaramanga',
    'Pereira',
    'Santa Marta',
    'Ibagué',
    'Pasto',
    'Manizales',
    'Neiva',
    'Villavicencio',
    'Armenia',
    'Valledupar',
    'Montería',
    'Sincelejo',
    'Popayán',
    'Tunja',
  ];

  Future<void> _pickBadgePhoto(BuildContext context) async {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final photo = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (photo != null) {
                  HapticFeedback.lightImpact();
                  onBadgePhotoSelected(photo.path);
                }
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final photo = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (photo != null) {
                  HapticFeedback.lightImpact();
                  onBadgePhotoSelected(photo.path);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),

        // Citizen-specific fields
        if (selectedRole == 'Citizen') ...[
          Text(
            'Select Your Municipality',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          DropdownSearch<String>(
            items: (filter, infiniteScrollProps) => _colombianMunicipalities,
            selectedItem: selectedMunicipality,
            onChanged: onMunicipalityChanged,
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                labelText: 'Municipality',
                hintText: 'Search for your municipality',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12),
                  child: CustomIconWidget(
                    iconName: 'location_city',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search municipality...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],

        // Authority-specific fields
        if (selectedRole == 'Authority') ...[
          Text(
            'Badge Verification',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Upload a clear photo of your official badge for verification',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.5.h),
          GestureDetector(
            onTap: () => _pickBadgePhoto(context),
            child: Container(
              width: double.infinity,
              height: 20.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(
                  color: badgePhotoPath != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: badgePhotoPath != null ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: badgePhotoPath != null
                  ? Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'check_circle',
                                color: theme.colorScheme.primary,
                                size: 48,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Badge Photo Uploaded',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'Tap to change',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'add_a_photo',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 48,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Upload Badge Photo',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Tap to take photo or choose from gallery',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ],

        // NGO Representative-specific fields
        if (selectedRole == 'NGO Representative') ...[
          TextFormField(
            controller: organizationController,
            decoration: InputDecoration(
              labelText: 'Organization Name',
              hintText: 'Enter your NGO organization name',
              prefixIcon: Padding(
                padding: EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'business',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ),
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your organization name';
              }
              return null;
            },
          ),
          SizedBox(height: 1.5.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Color(0xFFF57C00).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFF57C00), width: 1),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: Color(0xFFF57C00),
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Your organization will be verified by our team. You\'ll receive a notification once approved.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Color(0xFFF57C00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
