import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/entity/vendor_info_entity.dart';
import 'package:gaaubesi_vendor/features/vendor_info/presentaion/bloc/vendor_info_bloc.dart';
import 'package:gaaubesi_vendor/features/vendor_info/presentaion/bloc/vendor_info_event.dart';
import 'package:gaaubesi_vendor/features/vendor_info/presentaion/bloc/vendor_info_state.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

@RoutePage()
class VendorInfoScreen extends StatefulWidget {
  const VendorInfoScreen({super.key});

  @override
  State<VendorInfoScreen> createState() => _VendorInfoScreenState();
}

class _VendorInfoScreenState extends State<VendorInfoScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VendorInfoBloc>().add(FetchVendorInfoEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extra;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: const Text('Vendor Information'),
        centerTitle: true,
      ),
      body: BlocConsumer<VendorInfoBloc, VendorInfoState>(
        listener: (context, state) {
          if (state is VendorInfoErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VendorInfoLoadingState) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (state is VendorInfoLoadedState) {
            final vendor = state.vendorInfo;
            final location = vendor.vendorLocation;

            return RefreshIndicator(
              color: theme.colorScheme.primary,
              onRefresh: () async {
                context.read<VendorInfoBloc>().add(FetchVendorInfoEvent());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileSection(vendor, theme, colors),

                    _buildContactSection(vendor, theme, colors),

                    _buildMapSection(location, theme, colors),
                  ],
                ),
              ),
            );
          }

          if (state is VendorInfoErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Unable to load vendor information',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<VendorInfoBloc>().add(
                          FetchVendorInfoEvent(),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_mall_directory_rounded,
                  size: 64,
                  color: colors.darkGray,
                ),
                const SizedBox(height: 16),
                Text(
                  'No vendor information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.darkGray,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(
    VendorInfoEntity vendor,
    ThemeData theme,
    AdditionalColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              child: vendor.profilePicture != null
                  ? CachedNetworkImage(
                      imageUrl: vendor.profilePicture!,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 38,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) => CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,
                        backgroundImage: const AssetImage(
                          'assets/default_avatar.png',
                        ),
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 38,
                      backgroundImage: const AssetImage(
                        'assets/default_avatar.png',
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.fullName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.store_rounded, size: 18, color: colors.darkGray),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vendor.primaryBranch,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.darkGray,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    context.router.push(const EditProfileRoute());
                  },
                  child: Chip(
                    label: Text(
                      "Edit Info",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(
    VendorInfoEntity vendor,
    ThemeData theme,
    AdditionalColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_page_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            icon: Icons.email_rounded,
            label: 'Email',
            value: vendor.email,
            theme: theme,
            colors: colors,
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.phone_rounded,
            label: 'Phone',
            value: vendor.phoneNumber,
            theme: theme,
            colors: colors,
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.location_on_rounded,
            label: 'Address',
            value: vendor.address,
            theme: theme,
            colors: colors,
          ),
          if (vendor.website != null && vendor.website!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Icons.language_rounded,
              label: 'Website',
              value: vendor.website!,
              theme: theme,
              colors: colors,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required AdditionalColors colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colors.lightGray.withValues(alpha: 0.3),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(
    VendorLocationEntity location,
    ThemeData theme,
    AdditionalColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.map_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Location on Map',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (location.coordinates.length < 2)
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colors.lightGray.withValues(alpha: 0.3),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_rounded,
                      size: 48,
                      color: colors.darkGray,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Location data not available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      location.coordinates[1],
                      location.coordinates[0],
                    ),
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.vendor.gaaubesi.gaaubesiVendor',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            location.coordinates[1],
                            location.coordinates[0],
                          ),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
