// @dart=2.9

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locater/Find%20yourself.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as jio;

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {'/home': (context) => Home(), '/main': (context) => MapPage()},
      initialRoute: '/home',
    ));

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  LocationData currentLocation;
  Location location;

  String location_ = 'Press Button';
  String Address = 'search';
  Position currentpos_;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position getpos = await Geolocator.getCurrentPosition();
    setState(() {
      currentpos_ = getpos;
    });
  }

  Future<void> GetAddressFromLatLong() async {
    List<jio.Placemark> placemarks = await jio.placemarkFromCoordinates(
        currentpos_.latitude, currentpos_.longitude);
    jio.Placemark place = placemarks[0];
    Address = '${place.street}';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Locator',
          style: TextStyle(
            fontWeight: FontWeight.w200,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(children: <Widget>[
        GoogleMap(
          myLocationEnabled: true,
          compassEnabled: true,
          tiltGesturesEnabled: false,
          markers: _markers,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(19.0700, 72.8446),
              tilt: 59.440717697143555,
              zoom: 19.151926040649414),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
        Positioned(
          top: 500,
          left: 40,
          child: Card(
            shadowColor: Colors.black,
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(children: <Widget>[
                InkWell(
                  onTap: () {
                    _determinePosition();
                    GetAddressFromLatLong();
                  },
                  child: Text(
                    currentpos_ == null
                        ? 'Tap to Get Location'
                        : currentpos_.toString(),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '${Address}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                )
              ]),
            ),
          ),
        )
      ]),
    );
  }
}
