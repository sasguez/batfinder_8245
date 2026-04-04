import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Search Location Widget
/// Provides location search functionality with Colombian address format
class SearchLocationWidget extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  final VoidCallback onClose;

  const SearchLocationWidget({
    super.key,
    required this.onLocationSelected,
    required this.onClose,
  });

  @override
  State<SearchLocationWidget> createState() => _SearchLocationWidgetState();
}

class _SearchLocationWidgetState extends State<SearchLocationWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  final List<Map<String, dynamic>> _mockLocations = [
    {
      "name": "Plaza de Bolívar",
      "address": "Carrera 7 #11-10, Bogotá",
      "location": {"lat": 4.5981, "lng": -74.0758},
    },
    {
      "name": "Parque Nacional",
      "address": "Carrera 7 #32-16, Bogotá",
      "location": {"lat": 4.6097, "lng": -74.0817},
    },
    {
      "name": "Centro Comercial Andino",
      "address": "Carrera 11 #82-71, Bogotá",
      "location": {"lat": 4.6697, "lng": -74.0547},
    },
    {
      "name": "Aeropuerto El Dorado",
      "address": "Calle 26 #103-09, Bogotá",
      "location": {"lat": 4.7016, "lng": -74.1469},
    },
    {
      "name": "Universidad Nacional",
      "address": "Carrera 45 #26-85, Bogotá",
      "location": {"lat": 4.6389, "lng": -74.0831},
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final results = _mockLocations.where((location) {
      final name = (location["name"] as String).toLowerCase();
      final address = (location["address"] as String).toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || address.contains(searchQuery);
    }).toList();

    setState(() => _searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Buscar ubicación...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.5.h,
                      ),
                    ),
                    onChanged: _performSearch,
                  ),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          if (_searchResults.isNotEmpty)
            Container(
              constraints: BoxConstraints(maxHeight: 40.h),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final location = _searchResults[index];
                  return ListTile(
                    leading: CustomIconWidget(
                      iconName: 'location_on',
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    title: Text(
                      location["name"] as String,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      location["address"] as String,
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () {
                      final locationData =
                          location["location"] as Map<String, dynamic>;
                      widget.onLocationSelected(
                        LatLng(
                          (locationData["lat"] as num).toDouble(),
                          (locationData["lng"] as num).toDouble(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
