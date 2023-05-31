import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class Quadra {
  String uuid;
  String name;
  int color;
  List<LatLng> coordinates;

  Quadra({required this.uuid, required this.name, required this.color, required this.coordinates});

  factory Quadra.fromJson(Map<String, dynamic> json) {
    final coordindateList = <LatLng>[];
    for (var coordinate in json['geometry']['coordinates'].first) {
      coordindateList.add(LatLng(coordinate[1], coordinate[0]));
    }
    return Quadra(
      uuid: json['uuid'] ?? const Uuid().v4(),
      name: json['properties']['Name'] ?? 'sem nome',
      color: json['properties']['Color'] ?? Colors.grey.value,
      coordinates: coordindateList,
    );
  }

  toJson() {
    final data = <String, dynamic>{};
    final coordinateList = [];
    final secondaryList = [];
    for (var coordinate in coordinates) {
      secondaryList.add([coordinate.longitude, coordinate.latitude]);
    }
    coordinateList.add(secondaryList);
    data['uuid'] = uuid;
    data['properties'] = {
      'Name': name,
      'Color': color,
    };
    data['geometry'] = {
      'coordinates': coordinateList,
    };

    return data;
  }

  LatLng get center {
    List xCoords = [];
    List yCoords = [];
    List<LatLng> coordinateList = [];

    coordinateList = coordinates;

    for (LatLng point in coordinateList) {
      xCoords.add(point.longitude);
      yCoords.add(point.latitude);
    }

    //Calculo de area e centroid

    double areaObjList = 0;
    double centroidXList = 0;
    double centroidYList = 0;

    for (int i = 0; i < (xCoords.length - 1); i++) {
      double verticeCalc = (xCoords[i] * yCoords[i + 1] - xCoords[i + 1] * yCoords[i]);
      double xVerticeCalc = (xCoords[i] + xCoords[i + 1]) * (verticeCalc);
      double yVerticeCalc = (yCoords[i] + yCoords[i + 1]) * (verticeCalc);

      areaObjList += verticeCalc;
      centroidXList += xVerticeCalc;
      centroidYList += yVerticeCalc;
    }

    double areaObj = areaObjList / 2;

    double centroidX = centroidXList / (6 * areaObj);
    double centroidY = centroidYList / (6 * areaObj);

    LatLng ptoCentral = LatLng(centroidY, centroidX);
    return ptoCentral;
  }
}
