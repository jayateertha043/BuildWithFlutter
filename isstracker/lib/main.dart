import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

GoogleMapController mapController;
MapType _currentMapType = MapType.hybrid;
dynamic position;
String _latt,_long;

void main() async {
   await assignPosition();
   runApp(MyApp());
   }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'IssTracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    Marker marker = Marker(markerId: MarkerId('tracker'),
    position: LatLng(double.parse(_latt),double.parse(_long)));
    Set<Marker> _markers = {marker};
  return Scaffold(
    appBar: AppBar(
      title: Text('IssTracker'),
    ),
    body: Stack(
      children: <Widget>[
        GoogleMap(
          markers: _markers,
          mapType: _currentMapType,
          onMapCreated: (GoogleMapController controller){
            mapController = controller;
            print("map created");
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(double.parse(_latt),double.parse(_long)),
            zoom: 10,
          ),

        ),
      Container(
        margin: EdgeInsets.only(
          bottom:50,
          right:10
        ),
        alignment: Alignment(1, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              child: Icon(Icons.map),
              onPressed: (){
                setState(() {
                  _currentMapType = _currentMapType == MapType.normal
          ? MapType.hybrid
          : (_currentMapType == MapType.hybrid
          ? MapType.terrain:
            (_currentMapType == MapType.terrain
          ? MapType.satellite: MapType.normal));
          print(_currentMapType);
                });
              }
            ),
            Container(height: 10,width: 0,),
            Builder(
                builder: (context)=> FloatingActionButton(
                onPressed: () {
                  setState((){
                  assignPosition();
                  mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: 
                  LatLng(double.parse(_latt),double.parse(_long),),zoom:5 )));
                  final snackBar = SnackBar(content: Text('refreshed'),duration: Duration(milliseconds: 500));
                  Scaffold.of(context).showSnackBar(snackBar);
                  });
                },
                child: Icon(Icons.refresh),
              ),
            )
          ],
        ),
      )
      ],
    ),
  );
  }
}

  Future<dynamic> getPosition() async{
    String apiUrl = 'http://api.open-notify.org/iss-now';
    http.Response response = await http.get(apiUrl);
    return json.decode(response.body);
  }

  void assignPosition() async {
    position = await getPosition();
    _latt = position['iss_position']['latitude'];
    _long = position['iss_position']['longitude'];
    print(_latt + " " + _long + " assigned" );
  }