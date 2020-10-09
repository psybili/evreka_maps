import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:dp/dp.dart';
import 'package:evreka_maps/container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  bool isInternetOn = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    GetConnect(); // calls getconnect method to check which type if connection it
  }

  GoogleMapController controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<MarkerId, Bin> containers = <MarkerId, Bin>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;

  LatLngBounds _visibleRegion = LatLngBounds(
    southwest: const LatLng(0, 0),
    northeast: const LatLng(0, 0),
  );

  bool markerSelected = false;

  String selectedMarkerId = "";
  String nextCollection = "";
  String fullness = "";

  void GetConnect() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isInternetOn = false;
      });
    }
  }

  AlertDialog buildAlertDialog() {
    return AlertDialog(
      title: Text(
        "You are not Connected to Internet",
        style: TextStyle(color: const Color(0xff535a72), fontSize: 16, fontWeight: FontWeight.normal),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    final LatLngBounds visibleRegion = await controller.getVisibleRegion();
    double latMin = visibleRegion.northeast.latitude;
    double lngMin = visibleRegion.southwest.longitude;
    double latMax = visibleRegion.southwest.latitude;
    double lngMax = visibleRegion.northeast.longitude;

    Map<MarkerId, Marker> mMarkers = <MarkerId, Marker>{};

    for (var i = 1; i <= 1000; i++) {
      final Random random = Random();
      double mLat = latMin + (random.nextDouble() * (latMax - latMin));
      double mLng = lngMin + (random.nextDouble() * (lngMax - lngMin));
      LatLng mLatLng = LatLng(mLat, mLng);

      final String markerIdVal = "$_markerIdCounter";
      _markerIdCounter++;
      final MarkerId markerId = MarkerId(markerIdVal);

      final int fullness = random.nextInt(100);
      final randomDays = random.nextInt(5);
      final DateTime nextCollection = DateTime.now().add(Duration(days: randomDays));
      final Bin container = Bin(markerId, fullness, nextCollection);
      containers[markerId] = container;

      final Marker marker = Marker(
        markerId: markerId,
        position: mLatLng,
        infoWindow: InfoWindow(title: markerIdVal, snippet: "%$fullness"),
        onTap: () {
          _onMarkerTapped(markerId);
        },
        onDragEnd: (LatLng position) {
//        _onMarkerDragEnd(markerId, position);
        },
      );
      mMarkers[markerId] = marker;
    }

    setState(() {
      this.controller = controller;
      _visibleRegion = visibleRegion;
      markers = mMarkers;
      CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(LatLng(41.104046, 29.043300), 14.6);
      this.controller.animateCamera(cameraUpdate);
    });
  }

  void _onMarkerTapped(MarkerId markerId) {
    setState(() {
      markerSelected = true;
      selectedMarker = markerId;
      selectedMarkerId = selectedMarker.value;
      nextCollection = containers[selectedMarker].nextCollection.toString();
      fullness = containers[markerId].fullness.toString();
    });
  }

  @override
  Widget build(BuildContext context) {

    GoogleMap map = GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: LatLng(41.1, 29.045),
        zoom: 12.0,
      ),
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // https://github.com/flutter/flutter/issues/28312
      // ignore: prefer_collection_literals
      markers: Set<Marker>.of(markers.values),
      onTap: (LatLng pos) {
        setState(() {
          markerSelected = false;
          selectedMarker = null;
          selectedMarkerId = "";
          nextCollection = "";
          fullness = "";
        });
      },
    );

    gInitDp(context);

    double buttonWidth = gDp(304);

    Widget infoSheet = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
                child: Text(
                  "Container $selectedMarkerId",
                  style: TextStyle(color: const Color(0xff172c49), fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 12.0, 0.0, 0.0),
                child: Text(
                  "Next Collection",
                  style: TextStyle(color: const Color(0xff172c49).withOpacity(0.8), fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 4.0, 0.0, 0.0),
                child: Text(
                  "$nextCollection",
                  style: TextStyle(color: const Color(0xff535a72), fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 12.0, 0.0, 0.0),
                child: Text(
                  "Fullness Rate",
                  style: TextStyle(color: const Color(0xff172c49).withOpacity(0.8), fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 4.0, 0.0, 0.0),
                child: Text(
                  "%$fullness",
                  style: TextStyle(color: const Color(0xff535a72), fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),
              ButtonBar(
                buttonMinWidth: buttonWidth,
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    onPressed: () {
                      double lat = markers[selectedMarker].position.latitude;
                      double lng = markers[selectedMarker].position.longitude;
                      MapsLauncher.launchCoordinates(lat, lng);
                    },
                    color: Color(0xff3ba935),
                    child: const Text('NAVIGATE', style: TextStyle(fontSize: 20)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      final LatLngBounds visibleRegion = await controller.getVisibleRegion();
                      setState(() {
                        _visibleRegion = visibleRegion;
                      });
                    },
                    color: Color(0xff3ba935),
                    child: const Text('RELOCATE', style: TextStyle(fontSize: 20)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );

    return SafeArea(
      child: Scaffold(
        body: isInternetOn ? Stack(
          children: [
            map,
            if (markerSelected)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: infoSheet,
              )
          ],
        ) : buildAlertDialog(),
      ),
    );
  }
}
