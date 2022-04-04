import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowLocationMap extends StatefulWidget {
  final double lat;
  final double long;
  final String title;

  const ShowLocationMap(this.lat, this.long, this.title);

  @override
  _ShowLocationMapState createState() => _ShowLocationMapState();
}

class _ShowLocationMapState extends State<ShowLocationMap> {
  GoogleMapController mapController;
  List<Marker> allMarkers = [];

  @override
  void initState() {
    super.initState();

    addMarker();
  }

  addMarker() {
    setState(() {
      allMarkers.add(Marker(
          markerId: const MarkerId('myMarker'),
          onTap: () {
            debugPrint('Marker Tapped');
          },
          position: LatLng(widget.lat, widget.long)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: <Widget>[
              GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(widget.lat, widget.long), zoom: 16.0),
                onMapCreated: onMapCreated,
                markers: Set.from(allMarkers),
              ),
              Positioned(
                top: 5.0.h,
                right: 5.0.w,
                left: 5.0.w,
                child: Container(
                  height: 50.0.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white),
                  child: Padding(
                    padding: EdgeInsets.only(right: 5.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            widget.title,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenUtil()
                                    .setSp(20, allowFontScalingSelf: true)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void onMapCreated(controller) {
    mapController = controller;
  }
}

class ShowSateliteMap extends StatefulWidget {
  final double lat;
  final double long;
  final double siteLat;
  final double siteLong;
  ShowSateliteMap(this.lat, this.long, this.siteLat, this.siteLong);

  @override
  _ShowSateliteMapState createState() => _ShowSateliteMapState();
}

class _ShowSateliteMapState extends State<ShowSateliteMap> {
  GoogleMapController mapController;
  List<Marker> allMarkers = [];
  BitmapDescriptor customIcon;
  @override
  void initState() {
    super.initState();

// make sure to initialize before map loading
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(12, 12)),
      'resources/marker.png',
    ).then((d) {
      customIcon = d;
    }).whenComplete(() => addMarker());
  }

  addMarker() {
    setState(() {
      allMarkers.add(Marker(
          markerId: const MarkerId('myMarker'),
          onTap: () {
            launch("google.navigation:q=${widget.siteLat},${widget.siteLong}");
          },
          position: LatLng(widget.siteLat, widget.siteLong)));
      allMarkers.add(Marker(
          markerId: MarkerId('userMarker'),
          icon: customIcon,
          onTap: () {
            debugPrint('Marker Tapped');
          },
          position: LatLng(widget.lat, widget.long)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
        bottomRight: Radius.circular(15),
        bottomLeft: Radius.circular(15),
      ),
      child: Stack(
        children: [
          GoogleMap(
            mapToolbarEnabled: true,
            circles: Set.from(
              [
                Circle(
                  circleId: const CircleId('currentCircle'),
                  center: LatLng(widget.siteLat, widget.siteLong),
                  radius: 100,
                  fillColor: Colors.blue.shade100.withOpacity(0.5),
                  strokeColor: Colors.blue.shade100.withOpacity(0.1),
                ),
              ],
            ),
            initialCameraPosition: CameraPosition(
                target: LatLng(widget.siteLat, widget.siteLong), zoom: 15.0),
            onMapCreated: onMapCreated,
            buildingsEnabled: true,
            markers: Set.from(allMarkers),
            mapType: MapType.normal,
          ),
        ],
      ),
    );
  }

  void onMapCreated(controller) {
    mapController = controller;
  }
}
