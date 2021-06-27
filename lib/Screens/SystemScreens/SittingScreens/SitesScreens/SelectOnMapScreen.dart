import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/AddSite.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddLocationMapScreen extends StatefulWidget {
  final Site site;
  final int id;
  AddLocationMapScreen(this.site, this.id);

  @override
  _AddLocationMapScreenState createState() => _AddLocationMapScreenState();
}

class _AddLocationMapScreenState extends State<AddLocationMapScreen> {
  GoogleMapController mapController;

  var pos;
  var zoom = 10.0;
  LatLng latLng = LatLng(30.043490, 31.235290);
  List<Marker> allMarkers = [];
  TextEditingController _lat = TextEditingController();
  TextEditingController _long = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fillLatLong();
  }

  fillLatLong() {
    if (widget.site.lat != 0) {
      setState(() {
        print(widget.site.id);
        zoom = 16.0;
        _long.text = widget.site.long.toString();
        _lat.text = widget.site.lat.toString();
        latLng = LatLng(widget.site.lat, widget.site.long);
        allMarkers.add(Marker(
            markerId: MarkerId('myMarker'),
            onTap: () {
              print('Marker Tapped');
            },
            position: latLng));
      });
    }
  }

  // double getNumber(double input, int precision) => double.parse(
  //     '$input'.substring(0, '$input'.indexOf('.') + precision + 1));

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    return new Scaffold(
      floatingActionButton: Container(
        height: 80.0.h,
        width: 80.w,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Header(nav: false),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    GoogleMap(
                      myLocationButtonEnabled: false,
                      initialCameraPosition:
                          CameraPosition(target: latLng, zoom: zoom),
                      onMapCreated: onMapCreated,
                      markers: Set.from(allMarkers),
                      onTap: (latLng) {
                        setState(() {
                          _lat.text = latLng.latitude.toString();
                          _long.text = latLng.longitude.toString();
                        });
                        print(latLng.latitude);

                        mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                                target:
                                    LatLng(latLng.latitude, latLng.longitude),
                                zoom: 16.0),
                          ),
                        );
                        Marker marker = Marker(
                            markerId: MarkerId('myMarker'),
                            onTap: () {
                              print('Marker Tapped');
                            },
                            position:
                                LatLng(latLng.latitude, latLng.longitude));
                        setState(() {
                          if (allMarkers.isEmpty) {
                            allMarkers.add(marker);
                          } else {
                            allMarkers[0] = marker;
                          }
                          print(allMarkers.length);
                        });
                      },
                    ),
                    Positioned(
                      top: 30.0.h,
                      right: 15.0.w,
                      left: 15.0.w,
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
                                flex: 1,
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  controller: _lat,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'Latitude',
                                    border: InputBorder.none,
                                  ),
                                  // onChanged: (val) {
                                  //   setState(() {
                                  //     print(val);
                                  //     lat = val;
                                  //   });
                                  // },
                                ),
                              ),
                              VerticalDivider(
                                thickness: 2,
                                color: Colors.orange,
                              ),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  onFieldSubmitted: (_) {
                                    searchandNavigate();
                                  },
                                  textInputAction: TextInputAction.done,
                                  controller: _long,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'Longitude',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 15.0.w, right: 15.w),
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                thickness: 2,
                                color: Colors.orange,
                              ),
                              InkWell(
                                onTap: () {
                                  searchandNavigate();
                                },
                                child: Icon(
                                  Icons.search,
                                  size: ScreenUtil()
                                      .setSp(30, allowFontScalingSelf: true),
                                  color: Colors.orange,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10.w,
                      bottom: 10.h,
                      child: Column(
                        children: [
                          SafeArea(
                            child: FlatButton(
                              onPressed: () async {
                                print("ss");
                                await Provider.of<ShiftApi>(context,
                                        listen: false)
                                    .getCurrentLocation();
                                var currentLocation = Provider.of<ShiftApi>(
                                        context,
                                        listen: false)
                                    .currentPosition;
                                setState(() {
                                  _lat.text =
                                      currentLocation.latitude.toString();
                                  _long.text =
                                      currentLocation.longitude.toString();
                                });

                                mapController.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                        target: LatLng(currentLocation.latitude,
                                            currentLocation.longitude),
                                        zoom: 16.0),
                                  ),
                                );
                                Marker marker = Marker(
                                    markerId: MarkerId('myMarker'),
                                    onTap: () {
                                      print('Marker Tapped');
                                    },
                                    position: LatLng(currentLocation.latitude,
                                        currentLocation.longitude));
                                setState(() {
                                  if (allMarkers.isEmpty) {
                                    allMarkers.add(marker);
                                  } else {
                                    allMarkers[0] = marker;
                                  }
                                  print(allMarkers.length);
                                });
                              },
                              splashColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                width: 50.w,
                                height: 50.h,
                                child: Icon(
                                  Icons.my_location,
                                  size: ScreenUtil()
                                      .setSp(30, allowFontScalingSelf: true),
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          allMarkers.isEmpty
                              ? Container()
                              : FlatButton(
                                  onPressed: () {
                                    print(widget.site.id);
                                    print(widget.site.lat);
                                    print(widget.site.name);
                                    if (widget.site.name != "") {
                                      print("not null");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddSiteScreen(
                                              Site(
                                                  id: widget.site.id,
                                                  lat: double.parse(_lat.text),
                                                  long:
                                                      double.parse(_long.text),
                                                  name: widget.site.name),
                                              widget.id,
                                              true,
                                              true),
                                        ),
                                      );
                                    } else {
                                      print(" null");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddSiteScreen(
                                              Site(
                                                  lat: double.parse(_lat.text),
                                                  long:
                                                      double.parse(_long.text),
                                                  name: ""),
                                              0,
                                              false,
                                              true),
                                        ),
                                      );
                                      print(_long.text + _lat.text);
                                    }
                                  },
                                  splashColor: Colors.white,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    width: 50.w,
                                    height: 50.h,
                                    child: Icon(
                                      Icons.check,
                                      size: ScreenUtil().setSp(40,
                                          allowFontScalingSelf: true),
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    // Positioned(
                    //   left: 10,
                    //   bottom: 60,
                    //   child:
                    // )
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 5.0.w,
            top: 5.0.h,
            child: Container(
              width: 50.w,
              height: 50.h,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  searchandNavigate() async {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(double.parse(_lat.text), double.parse(_long.text)),
            zoom: 16.0),
      ),
    );
    Marker marker = Marker(
        markerId: MarkerId('myMarker'),
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(double.parse(_lat.text), double.parse(_long.text)));
    setState(() {
      if (allMarkers.isEmpty) {
        allMarkers.add(marker);
      } else {
        allMarkers[0] = marker;
      }
      print(allMarkers.length);
    });
  }
  // }

  void onMapCreated(controller) {
    mapController = controller;
  }
}
