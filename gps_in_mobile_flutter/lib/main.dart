import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pilih Lokasi',
      home: LokasiPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LokasiPage extends StatefulWidget {
  @override
  _LokasiPageState createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  final Map<String, String> lokasiNama = {
    'Jakarta': 'jakarta',
    'Bandung': 'bandung',
    'Surabaya': 'surabaya',
    'Jember': 'jember',
    'Rowotamtu': 'rowotamtu',
  };

  String? selectedLokasi1, selectedLokasi2;
  LatLng? koordinat1, koordinat2;
  double? jarakKm;
  List<LatLng> polylinePoints = [];

  final mapController = MapController();

  Future<LatLng?> fetchCoordinates(String lokasi) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$lokasi&format=json&limit=1',
    );
    final response = await http.get(
      url,
      headers: {'User-Agent': 'flutter-app'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  Future<void> updateKoordinat() async {
    if (selectedLokasi1 != null && selectedLokasi2 != null) {
      koordinat1 = await fetchCoordinates(selectedLokasi1!);
      koordinat2 = await fetchCoordinates(selectedLokasi2!);
      if (koordinat1 != null && koordinat2 != null) {
        setState(() {
          jarakKm =
              Geolocator.distanceBetween(
                koordinat1!.latitude,
                koordinat1!.longitude,
                koordinat2!.latitude,
                koordinat2!.longitude,
              ) /
              1000;
        });
        await fetchRoute();
        mapController.move(koordinat1!, 10);
      }
    }
  }

  Future<void> fetchRoute() async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${koordinat1!.longitude},${koordinat1!.latitude};${koordinat2!.longitude},${koordinat2!.latitude}?overview=full&geometries=geojson',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;
      setState(() {
        polylinePoints =
            coords
                .map(
                  (point) => LatLng(point[1].toDouble(), point[0].toDouble()),
                )
                .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pilih Lokasi via Dropdown")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedLokasi1,
                    hint: Text("Lokasi 1"),
                    isExpanded: true,
                    items:
                        lokasiNama.keys.map((String key) {
                          return DropdownMenuItem<String>(
                            value: lokasiNama[key],
                            child: Text(key),
                          );
                        }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedLokasi1 = val;
                      });
                      updateKoordinat();
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedLokasi2,
                    hint: Text("Lokasi 2"),
                    isExpanded: true,
                    items:
                        lokasiNama.keys.map((String key) {
                          return DropdownMenuItem<String>(
                            value: lokasiNama[key],
                            child: Text(key),
                          );
                        }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedLokasi2 = val;
                      });
                      updateKoordinat();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (jarakKm != null)
              Text("Jarak: ${jarakKm!.toStringAsFixed(2)} km"),
            SizedBox(height: 10),
            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(center: LatLng(-6.2, 106.8), zoom: 5),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.app',
                  ),
                  if (koordinat1 != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: koordinat1!,
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  if (koordinat2 != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: koordinat2!,
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ],
                    ),

                  if (polylinePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: polylinePoints,
                          color: Colors.blue,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
