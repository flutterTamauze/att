import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/SitesScreens/AddSite.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter/services.dart';

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
    super.initState();
    fillLatLong();
  }

  fillLatLong() {
    if (widget.site.lat != 0) {
      setState(() {
        zoom = 16.0;
        _long.text = widget.site.long.toString();
        _lat.text = widget.site.lat.toString();
        latLng = LatLng(widget.site.lat, widget.site.long);
        allMarkers.add(Marker(
            markerId: const MarkerId('myMarker'),
            onTap: () {
              debugPrint('Marker Tapped');
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
      endDrawer: NotificationItem(),
      floatingActionButton: Container(
        height: 80.0.h,
        width: 80.w,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Header(
                nav: false,
                goUserHomeFromMenu: false,
                goUserMenu: false,
              ),
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

                        mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                                target:
                                    LatLng(latLng.latitude, latLng.longitude),
                                zoom: 16.0),
                          ),
                        );
                        final Marker marker = Marker(
                            markerId: const MarkerId('myMarker'),
                            onTap: () {
                              debugPrint('Marker Tapped');
                            },
                            position:
                                LatLng(latLng.latitude, latLng.longitude));
                        setState(() {
                          if (allMarkers.isEmpty) {
                            allMarkers.add(marker);
                          } else {
                            allMarkers[0] = marker;
                          }
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
                                  decoration: const InputDecoration(
                                    hintText: 'Latitude',
                                    border: InputBorder.none,
                                  ),
                                  // onChanged: (val) {
                                  //   setState(() {
                                  //     debugPrint(val);
                                  //     lat = val;
                                  //   });
                                  // },
                                ),
                              ),
                              const VerticalDivider(
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
                              const VerticalDivider(
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
                            // ignore: deprecated_member_use
                            child: FlatButton(
                              onPressed: () async {
                                debugPrint("ss");
                                await Provider.of<ShiftApi>(context,
                                        listen: false)
                                    .getCurrentLocation();
                                final currentLocation = Provider.of<ShiftApi>(
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
                                final Marker marker = Marker(
                                    markerId: const MarkerId('myMarker'),
                                    onTap: () {
                                      debugPrint('Marker Tapped');
                                    },
                                    position: LatLng(currentLocation.latitude,
                                        currentLocation.longitude));
                                setState(() {
                                  if (allMarkers.isEmpty) {
                                    allMarkers.add(marker);
                                  } else {
                                    allMarkers[0] = marker;
                                  }
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
                              // ignore: deprecated_member_use
                              : FlatButton(
                                  onPressed: () {
                                    if (widget.site.name != "") {
                                      debugPrint("not null");
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
                                      debugPrint(" null");
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
    final Marker marker = Marker(
        markerId: const MarkerId('myMarker'),
        onTap: () {
          debugPrint('Marker Tapped');
        },
        position: LatLng(double.parse(_lat.text), double.parse(_long.text)));
    setState(() {
      if (allMarkers.isEmpty) {
        allMarkers.add(marker);
      } else {
        allMarkers[0] = marker;
      }
    });
  }
  // }

  void onMapCreated(controller) {
    mapController = controller;
  }
}
