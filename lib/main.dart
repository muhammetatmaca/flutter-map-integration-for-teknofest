import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(
    home: MapScreen(),
  ));
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      print('Konum servisi etkin değil');
      return;
    }

    final PermissionStatus permissionStatus = await Permission.locationWhenInUse.status;
    if (permissionStatus == PermissionStatus.denied) {
      final PermissionStatus permissionStatus = await Permission.locationWhenInUse.request();
      if (permissionStatus != PermissionStatus.granted) {
        print('Kullanıcı konum izinlerini reddetti');
        return;
      }
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Konum alınamadı: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ANTARES HARİTA SİSTEMİ'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16.0),
              child: _currentLocation == null
                  ? Center(child: CircularProgressIndicator())
                  : FlutterMap(
                options: MapOptions(
                  center: _currentLocation!,
                  zoom: 13,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: _currentLocation!,
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 40.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(8.0),
            child: _currentLocation == null
                ? Text('Konum bilgisi yükleniyor...')
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enlem: ${_currentLocation!.latitude}'),
                Text('Boylam: ${_currentLocation!.longitude}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
