import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/entity/vendor_info_entity.dart';
import 'package:gaaubesi_vendor/features/vendor_info/presentaion/bloc/vendor_info_bloc.dart';
import 'package:gaaubesi_vendor/features/vendor_info/presentaion/bloc/vendor_info_event.dart';
import 'package:gaaubesi_vendor/features/vendor_info/presentaion/bloc/vendor_info_state.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_state.dart';
import 'package:image_picker/image_picker.dart';

@RoutePage()
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _nearestPickupPointController = TextEditingController();
  String? _selectedPickupPoint;
  LatLng? _selectedCoordinates;
  String? _profilePicturePath;
  bool _isInitialized = false;
  bool _isProfilePictureChanged = false;
  String? _originalProfilePicturePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorInfoBloc>().add(FetchVendorInfoEvent());
      context.read<BranchListBloc>().add(FetchPickupPointsEvent());
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nearestPickupPointController.dispose();
    super.dispose();
  }

  void _initializeWithVendorData(VendorInfoEntity vendorInfo) {
    if (!_isInitialized) {
      _addressController.text = vendorInfo.address;

      if (vendorInfo.vendorLocation.coordinates.length >= 2) {
        _selectedCoordinates = LatLng(
          vendorInfo.vendorLocation.coordinates[1],
          vendorInfo.vendorLocation.coordinates[0],
        );
      }

      if (vendorInfo.profilePicture != null &&
          vendorInfo.profilePicture!.isNotEmpty) {
        _originalProfilePicturePath = vendorInfo.profilePicture;
      }

      _isInitialized = true;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied. Please enable in settings.',
            ),
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedCoordinates = LatLng(position.latitude, position.longitude);
      });

      _showMapScreen();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMapScreen() {
    _selectedCoordinates ??= const LatLng(0, 0);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionScreen(
          initialPosition: _selectedCoordinates!,
          onLocationSelected: (latLng) {
            setState(() {
              _selectedCoordinates = latLng;
            });
          },
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profilePicturePath = pickedFile.path;
        _isProfilePictureChanged = true;
      });
    }
  }

  void _removeProfilePicture() {
    setState(() {
      _profilePicturePath = null;
      _isProfilePictureChanged = true;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCoordinates == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select location coordinates'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      String? profilePictureToSend;
      if (_isProfilePictureChanged) {
        profilePictureToSend = _profilePicturePath;
      }

      context.read<VendorInfoBloc>().add(
        UpdateVendorInfoEvent(
          address: _addressController.text,
          nearestPickupPoint: _selectedPickupPoint != null
              ? int.tryParse(_selectedPickupPoint!)
              : null,
          latitude: _selectedCoordinates!.latitude,
          longitude: _selectedCoordinates!.longitude,
          profilePicture: profilePictureToSend,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<VendorInfoBloc, VendorInfoState>(
            listener: (context, state) {
              if (state is VendorInfoUpdatedState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                Navigator.pop(context);
              } else if (state is VendorInfoUpdateErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<VendorInfoBloc, VendorInfoState>(
          builder: (context, vendorState) {
            if (vendorState is VendorInfoLoadedState) {
              _initializeWithVendorData(vendorState.vendorInfo);
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (vendorState is VendorInfoLoadingState)
                        _buildLoadingState(),

                      if (vendorState is VendorInfoErrorState)
                        _buildErrorState(vendorState),

                      if (vendorState is VendorInfoLoadedState ||
                          _isInitialized) ...[
                        _buildProfilePictureSection(vendorState),

                        const SizedBox(height: 32),

                        _buildCurrentValuesSection(vendorState),

                        const SizedBox(height: 32),

                        _buildAddressField(),

                        const SizedBox(height: 20),

                        _buildPickupPointDropdown(),

                        const SizedBox(height: 20),

                        _buildLocationSection(),

                        const SizedBox(height: 32),

                        _buildSaveButton(vendorState),
                      ],
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

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(VendorInfoErrorState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<VendorInfoBloc>().add(FetchVendorInfoEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection(VendorInfoState vendorState) {
    String? currentProfilePicture;
    if (vendorState is VendorInfoLoadedState) {
      currentProfilePicture = vendorState.vendorInfo.profilePicture;
    }

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundImage: _getProfileImage(currentProfilePicture),
                backgroundColor: Colors.grey[200],
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconButton(
              icon: Icons.camera_alt_rounded,
              label: 'Change',
              onPressed: _pickImage,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            if ((_profilePicturePath != null ||
                (_originalProfilePicturePath != null &&
                    _originalProfilePicturePath!.isNotEmpty)))
              _buildIconButton(
                icon: Icons.delete_rounded,
                label: 'Remove',
                onPressed: _removeProfilePicture,
                color: Colors.red,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getProfileImage(String? currentProfilePicture) {
    if (_profilePicturePath != null) {
      return FileImage(File(_profilePicturePath!));
    } else if (currentProfilePicture != null &&
        currentProfilePicture.isNotEmpty) {
      if (currentProfilePicture.startsWith('http')) {
        return NetworkImage(currentProfilePicture);
      } else if (File(currentProfilePicture).existsSync()) {
        return FileImage(File(currentProfilePicture));
      }
    }
    return const AssetImage('assets/default_avatar.png');
  }

  Widget _buildCurrentValuesSection(VendorInfoState vendorState) {
    if (vendorState is! VendorInfoLoadedState) return const SizedBox();

    final vendorInfo = vendorState.vendorInfo;

    return vendorInfo.address.isNotEmpty
        ? Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Current Information',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Address:', vendorInfo.address),
              ],
            ),
          )
        : const SizedBox();
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Business Address',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: 'Enter your business address',
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          maxLines: 3,
          style: const TextStyle(fontSize: 15),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPickupPointDropdown() {
    return BlocBuilder<BranchListBloc, BranchListState>(
      builder: (context, state) {
        List<DropdownMenuItem<String>> items = [];

        if (state is PickUpPointLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Nearest Pickup Point',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Loading pickup points...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else if (state is PickUpPointLoaded) {
          items = state.pickupPoints.map((pickupPoint) {
            return DropdownMenuItem<String>(
              value: pickupPoint.value,
              child: Text(
                pickupPoint.label,
                style: const TextStyle(fontSize: 15),
              ),
            );
          }).toList();
        } else if (state is PickUpPointError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Nearest Pickup Point',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Could not load pickup points',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Nearest Pickup Point',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedPickupPoint,
              decoration: InputDecoration(
                hintText: 'Select pickup point',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                prefixIcon: Icon(
                  Icons.pin_drop_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              items: items,
              onChanged: (value) {
                setState(() {
                  _selectedPickupPoint = value;
                });
              },
              style: const TextStyle(fontSize: 15),
              dropdownColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Location Coordinates',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildLocationButton(
                      icon: Icons.my_location_rounded,
                      label: 'Current Location',
                      onPressed: _getCurrentLocation,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLocationButton(
                      icon: Icons.map_rounded,
                      label: 'Select on Map',
                      onPressed: _showMapScreen,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              if (_selectedCoordinates != null) ...[
                const SizedBox(height: 16),
                Divider(color: Colors.grey.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Location',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lat: ${_selectedCoordinates!.latitude.toStringAsFixed(6)}\n'
                            'Lng: ${_selectedCoordinates!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Please select location coordinates',
                      style: TextStyle(color: Colors.orange[700], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(VendorInfoState vendorState) {
    return BlocBuilder<VendorInfoBloc, VendorInfoState>(
      builder: (context, state) {
        final isLoading = state is VendorInfoUpdatingState;

        return SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              shadowColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class MapSelectionScreen extends StatefulWidget {
  final LatLng initialPosition;
  final Function(LatLng) onLocationSelected;

  const MapSelectionScreen({
    super.key,
    required this.initialPosition,
    required this.onLocationSelected,
  });

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  late GoogleMapController _mapController;
  LatLng _selectedLocation = LatLng(0, 0);
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialPosition;
    _initialCameraPosition = CameraPosition(
      target: widget.initialPosition,
      zoom: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (latLng) {
              setState(() {
                _selectedLocation = latLng;
              });
              _mapController.animateCamera(CameraUpdate.newLatLng(latLng));
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: _selectedLocation,
                draggable: true,
                onDragEnd: (latLng) {
                  setState(() {
                    _selectedLocation = latLng;
                  });
                },
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
                zIndex: 2,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            buildingsEnabled: true,
            indoorViewEnabled: true,
            trafficEnabled: true,
            mapType: MapType.normal,
            padding: const EdgeInsets.only(bottom: 180),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900]! : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.grey[800],
                                ),
                              ),
                              Text(
                                'Drag the marker or tap on map to select location',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800]! : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Latitude',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              Text(
                                _selectedLocation.latitude.toStringAsFixed(6),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Longitude',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              Text(
                                _selectedLocation.longitude.toStringAsFixed(6),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Icon(Icons.location_pin, color: Colors.red, size: 48),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 200),
        child: FloatingActionButton(
          onPressed: () async {
            Position position = await Geolocator.getCurrentPosition();
            final latLng = LatLng(position.latitude, position.longitude);
            setState(() {
              _selectedLocation = latLng;
            });
            _mapController.animateCamera(CameraUpdate.newLatLng(latLng));
          },
          backgroundColor: isDarkMode ? Colors.grey[900]! : Colors.white,
          child: Icon(
            Icons.my_location_rounded,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
