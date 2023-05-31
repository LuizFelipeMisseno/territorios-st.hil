import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:territorio/components/color_option_box.dart';
import 'package:territorio/data/database/ordem%20de%20servico/quadra_database.dart';
import 'package:territorio/data/model/quadra.dart';

ValueNotifier<int?> colorSelected = ValueNotifier<int?>(Colors.grey.value);

class QuadrasController extends ChangeNotifier {
  final MapController mapController = MapController();
  List<Color> colorList = <Color>[
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.brown,
    Colors.black,
    Colors.grey,
  ];

  final selectedList = <Quadra>[];

  void showPopup(Quadra quadra, QuadraDatabase provider, BuildContext context) {
    colorSelected.value = quadra.color;
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Quadra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edite o nome',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                  ),
                ),
                TextFormField(
                  controller: textController,
                  decoration: InputDecoration(
                    //labelText: 'Edite o nome',
                    hintText: quadra.name,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 50,
              width: 300,
              child: ValueListenableBuilder(
                  valueListenable: colorSelected,
                  builder: (context, _, __) {
                    return ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: colorList.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final color = colorList[index];
                        return ColorOptionBox(color: color);
                      },
                    );
                  }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              quadra.name = textController.text.isEmpty ? quadra.name : textController.text;
              quadra.color = colorSelected.value ?? quadra.color;
              provider.update(uuid: quadra.uuid, data: quadra.toJson());
              colorSelected.value = null;

              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          )
        ],
      ),
    );
  }

  addCoordinatesFromKML(String path) async {
    final file = File(path);
    // Converte o Uint8List em uma String
    String kmlText = utf8.decode(file.readAsBytesSync());

    // Analisa o arquivo KML como XML
    var document = xml.XmlDocument.parse(kmlText);

    // Encontra todos os elementos "Polygon"
    var polygons = document.findAllElements('Polygon');

    // Cria um objeto GeoJSON vazio
    Map<String, dynamic> geoJson = {'type': 'FeatureCollection', 'features': []};

    // Loop através de todos os elementos "Polygon"
    for (var polygon in polygons) {
      // Extrai as coordenadas do polígono
      var coordinatesString = polygon.findAllElements('coordinates').single.text;
      var coordinatesList = coordinatesString.split(' ');
      log(polygon.toString());
      log(coordinatesString.toString());
      // Converte as coordenadas do polígono em um formato adequado para GeoJSON
      var coordinates = coordinatesList.map((coordinateString) {
        var parts = coordinateString.trim().split(',');

        return [double.tryParse(parts[0]), double.tryParse(parts[1])];
      }).toList();

      // Cria um objeto GeoJSON Feature com a geometria de polígono
      var feature = {
        'type': 'Feature',
        'properties': {'Name': ''},
        'geometry': {
          'type': 'Polygon',
          'coordinates': [coordinates]
        }
      };

      // Adiciona o objeto Feature ao objeto FeatureCollection
      geoJson['features']?.add(feature);
      log(geoJson.toString());
      for (var polygon in geoJson['features'] as List) {
        final quadra = Quadra.fromJson(polygon);
        await QuadraDatabase().insert(quadra.toJson());
      }
    }
  }

  void clearList() {
    selectedList.clear();
    notifyListeners();
  }

  void select(Quadra quadra) {
    if (selectedList.contains(quadra)) {
      selectedList.remove(quadra);
    } else {
      selectedList.add(quadra);
    }
    notifyListeners();
  }
}
