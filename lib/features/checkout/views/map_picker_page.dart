import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/core/services/location_service.dart';
import 'package:location/location.dart' as loc;

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  GoogleMapController? _mapController;
  LatLng _selectedPosition = const LatLng(15.3694, 44.1910); // Default Sana'a
  String _addressText = "جاري تحديد الموقع...";
  bool _isLoading = true;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    loc.LocationData? locationData = await _locationService.getCurrentLocation();
    if (locationData != null) {
      _selectedPosition = LatLng(locationData.latitude!, locationData.longitude!);
      _updateAddress(_selectedPosition.latitude, _selectedPosition.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_selectedPosition, 16));
    } else {
       _updateAddress(_selectedPosition.latitude, _selectedPosition.longitude);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _updateAddress(double lat, double lng) async {
    String addr = await _locationService.getAddressFromLatLng(lat, lng);
    if (mounted) {
      setState(() {
        _addressText = addr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تحديد الموقع على الخريطة", style: TextStyle(color: kTextColor, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _selectedPosition, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onCameraMove: (position) {
              _selectedPosition = position.target;
            },
            onCameraIdle: () {
              _updateAddress(_selectedPosition.latitude, _selectedPosition.longitude);
            },
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: BoxDecoration(
                       color: kPrimaryColor,
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: const Text("موقع التوصيل", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                   ),
                   const Icon(Icons.location_on, size: 45, color: kPrimaryColor),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: _setInitialLocation,
                  mini: true,
                  child: const Icon(Icons.my_location, color: kPrimaryColor),
                ),
                const SizedBox(height: 15),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: kPrimaryColor, size: 24),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("العنوان المحدد:", style: TextStyle(color: kTextLightColor, fontSize: 12)),
                                Text(
                                  _addressText,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kTextColor),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, {
                              'address': _addressText,
                              'lat': _selectedPosition.latitude,
                              'lng': _selectedPosition.longitude,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("تأكيد هذا الموقع", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
