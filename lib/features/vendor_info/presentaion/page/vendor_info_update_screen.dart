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
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch_list_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch_list_state.dart';
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
    // Fetch vendor info and pickup points when screen loads
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

  // Initialize form with vendor data
  void _initializeWithVendorData(VendorInfoEntity vendorInfo) {
    if (!_isInitialized) {
      _addressController.text = vendorInfo.address;
      
      // Set coordinates from vendorLocation
      if (vendorInfo.vendorLocation.coordinates.length >= 2) {
        _selectedCoordinates = LatLng(
          vendorInfo.vendorLocation.coordinates[1], // latitude
          vendorInfo.vendorLocation.coordinates[0], // longitude
        );
      }
      
      // Store original profile picture for comparison
      if (vendorInfo.profilePicture != null && vendorInfo.profilePicture!.isNotEmpty) {
        _originalProfilePicturePath = vendorInfo.profilePicture;
      }
      
      _isInitialized = true;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied. Please enable in settings.'),
          ),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedCoordinates = LatLng(position.latitude, position.longitude);
      });

      // Show map screen
      _showMapScreen();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
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
          ),
        );
        return;
      }

      // Only send profile picture if it was changed
      String? profilePictureToSend;
      if (_isProfilePictureChanged) {
        profilePictureToSend = _profilePicturePath;
      }

      // Dispatch update event
      context.read<VendorInfoBloc>().add(
        UpdateVendorInfoEvent(
          address: _addressController.text,
          nearestPickupPoint: _selectedPickupPoint != null 
            ? int.tryParse(_selectedPickupPoint!)
            : null,
          latitude: _selectedCoordinates!.latitude,
          longitude: _selectedCoordinates!.longitude,
          profilePicture: profilePictureToSend, // Only send if changed
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
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
                  ),
                );
                Navigator.pop(context);
              } else if (state is VendorInfoUpdateErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<VendorInfoBloc, VendorInfoState>(
          builder: (context, vendorState) {
            // Initialize form when vendor info is loaded
            if (vendorState is VendorInfoLoadedState) {
              _initializeWithVendorData(vendorState.vendorInfo);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Loading State
                    if (vendorState is VendorInfoLoadingState)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    
                    // Error State
                    if (vendorState is VendorInfoErrorState)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              vendorState.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<VendorInfoBloc>().add(FetchVendorInfoEvent());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    
                    // Loaded State - Show Form
                    if (vendorState is VendorInfoLoadedState || _isInitialized) ...[
                      // Profile Picture Section
                      _buildProfilePictureSection(vendorState),
                      
                      const SizedBox(height: 24),
                      
                      // Current Values Display
                      _buildCurrentValuesSection(vendorState),
                      
                      const SizedBox(height: 24),
                      
                      // Address Field
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Nearest Pickup Point Dropdown
                      _buildPickupPointDropdown(),
                      
                      const SizedBox(height: 16),
                      
                      // Location Selection
                      _buildLocationSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Submit Button
                      BlocBuilder<VendorInfoBloc, VendorInfoState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is VendorInfoUpdatingState ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: state is VendorInfoUpdatingState
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
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
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _getProfileImage(currentProfilePicture),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Change'),
            ),
            if ((_profilePicturePath != null || 
                (_originalProfilePicturePath != null && _originalProfilePicturePath!.isNotEmpty)))
              TextButton.icon(
                onPressed: _removeProfilePicture,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ],
    );
  }

  ImageProvider _getProfileImage(String? currentProfilePicture) {
    // Show selected image if available
    if (_profilePicturePath != null && File(_profilePicturePath!).existsSync()) {
      return FileImage(File(_profilePicturePath!));
    } 
    // Show original image if no new image selected
    else if (currentProfilePicture != null && currentProfilePicture.isNotEmpty) {
      if (currentProfilePicture.startsWith('http')) {
        return NetworkImage(currentProfilePicture);
      } else if (File(currentProfilePicture).existsSync()) {
        return FileImage(File(currentProfilePicture));
      }
    }
    // Default image
    return const AssetImage('assets/default_profile.png');
  }

  Widget _buildCurrentValuesSection(VendorInfoState vendorState) {
    if (vendorState is! VendorInfoLoadedState) return const SizedBox();
    
    final vendorInfo = vendorState.vendorInfo;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Values',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Address:', vendorInfo.address),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Location:', 
            'Lat: ${vendorInfo.vendorLocation.coordinates.isNotEmpty ? vendorInfo.vendorLocation.coordinates[1].toStringAsFixed(6) : 'N/A'}, '
            'Lng: ${vendorInfo.vendorLocation.coordinates.isNotEmpty ? vendorInfo.vendorLocation.coordinates[0].toStringAsFixed(6) : 'N/A'}'
          ),
          const SizedBox(height: 8),
          if (vendorInfo.profilePicture != null && vendorInfo.profilePicture!.isNotEmpty)
            _buildInfoRow('Profile Picture:', 'Uploaded'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style:  TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickupPointDropdown() {
    return BlocBuilder<BranchListBloc, BranchListState>(
      builder: (context, state) {
        List<DropdownMenuItem<String>> items = [];
        
        if (state is PickUpPointLoading) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nearest Pickup Point',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(),
            ],
          );
        } else if (state is PickUpPointLoaded) {
          items = state.pickupPoints.map((pickupPoint) {
            return DropdownMenuItem<String>(
              value: pickupPoint.value,
              child: Text(pickupPoint.label),
            );
          }).toList();
        } else if (state is PickUpPointError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nearest Pickup Point',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nearest Pickup Point',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedPickupPoint,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select pickup point',
              ),
              items: items,
              onChanged: (value) {
                setState(() {
                  _selectedPickupPoint = value;
                });
              },
              validator: (value) {
                return null; // Optional field
              },
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
        const Text(
          'Location Coordinates',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        
        if (_selectedCoordinates != null)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300] ?? Colors.grey),
                ),
                child: Column(
                  children: [
                    Text(
                      'Latitude: ${_selectedCoordinates!.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Longitude: ${_selectedCoordinates!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showMapScreen(),
                icon: const Icon(Icons.map),
                label: const Text('Select on Map'),
              ),
            ),
          ],
        ),
        
        if (_selectedCoordinates == null)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select location coordinates',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

// Map Selection Screen
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
  LatLng _selectedLocation = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onLocationSelected(_selectedLocation);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {},
            onTap: (latLng) {
              setState(() {
                _selectedLocation = latLng;
              });
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
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          
          // Center marker
          const IgnorePointer(
            child: Center(
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          ),
          
          // Coordinates display
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latitude: ${_selectedLocation.latitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Longitude: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap on map or drag marker to select location',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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