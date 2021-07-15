import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShowLocationMap extends StatefulWidget {
  final double lat;
  final double long;
  final String title;

  ShowLocationMap(this.lat, this.long, this.title);

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
          markerId: MarkerId('myMarker'),
          onTap: () {
            print('Marker Tapped');
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
