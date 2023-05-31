import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart' as geodesy;
import 'package:provider/provider.dart';
import 'package:territorio/controllers/pdf_controller.dart';
import 'package:territorio/controllers/quadras.controller.dart';
import 'package:territorio/data/database/ordem%20de%20servico/quadra_database.dart';
import 'package:territorio/data/model/quadra.dart';
import 'package:latlong2/latlong.dart';

class MyMap extends StatefulWidget {
  final QuadrasController quadrasController;
  final MapController mapController;
  final List<Quadra> quadrasList;
  final List<Quadra> selectedList;
  const MyMap(
      {super.key,
      required this.mapController,
      required this.quadrasList,
      required this.selectedList,
      required this.quadrasController});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  @override
  Widget build(BuildContext context) {
    bool selectMode = widget.selectedList.isNotEmpty;
    final dbProvider = Provider.of<QuadraDatabase>(context, listen: false);
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        zoom: 18,
        bounds: LatLngBounds(
          LatLng(-16.639173, -49.191754),
          LatLng(-16.651919, -49.188762),
        ),
        onLongPress: (tapPosition, point) {
          _onLongPressed(point, dbProvider);
        },
        onTap: (tapPosition, point) {
          _onPressed(point, dbProvider, selectMode);
        },
      ),
      children: [
        // All polygons
        PolygonLayer(
          polygons: createPolygons(),
        ),

        StreamBuilder<MapEvent>(
            stream: widget.mapController.mapEventStream,
            builder: (context, stream) {
              return MarkerLayer(
                markers: getQuadraIDMarker(stream.data?.zoom),
              );
            }),
      ],
    );
  }

  _onPressed(LatLng latLng, QuadraDatabase provider, bool selectMode) {
    for (Quadra quadra in widget.quadrasList) {
      bool isPointInPolygon = geodesy.Geodesy().isGeoPointInPolygon(latLng, quadra.coordinates);
      if (isPointInPolygon) {
        if (selectMode) {
          widget.quadrasController.select(quadra);
        } else {
          widget.quadrasController.showPopup(quadra, provider, context);
        }
      }
    }
  }

  _onLongPressed(LatLng latLng, QuadraDatabase provider) {
    for (Quadra quadra in widget.quadrasList) {
      bool isPointInPolygon = geodesy.Geodesy().isGeoPointInPolygon(latLng, quadra.coordinates);
      if (isPointInPolygon) {
        widget.quadrasController.select(quadra);
      }
    }
  }

  List<Marker> getQuadraIDMarker(double? zoom) {
    List<Marker> markers = [];
    if (zoom != null && zoom < 16) return markers;
    for (Quadra quadra in widget.quadrasList) {
      if (widget.selectedList.contains(quadra) && quadra.name != '') {
        markers.add(
          Marker(
            rotate: true,
            point: quadra.center,
            builder: (context) => Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(
                  Icons.done,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        );
      } else {
        markers.add(
          Marker(
            rotate: true,
            point: quadra.center,
            height: 20,
            width: 40,
            builder: (context) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                  border: Border.all(
                    width: 2,
                  ),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Text(
                        quadra.name.toString(),
                        style: const TextStyle(
                          fontFamily: 'HersheySerif',
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    }
    return markers;
  }

  List<Polygon> createPolygons() {
    final polygonsList = <Polygon>[];
    for (Quadra quadra in widget.quadrasList) {
      if (widget.selectedList.contains(quadra)) {
        final Polygon poly = Polygon(
          points: quadra.coordinates,
          borderColor: Colors.green.shade800,
          color: Colors.greenAccent.shade700,
          isFilled: true,
          borderStrokeWidth: 3,
        );
        polygonsList.add(poly);
      } else {
        final Polygon poly = Polygon(
          points: quadra.coordinates,
          color: Color(quadra.color),
          isFilled: true,
        );
        polygonsList.add(poly);
      }
    }
    return polygonsList;
  }
}
