import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:territorio/controllers/pdf_controller.dart';
import 'package:territorio/controllers/quadras.controller.dart';
import 'package:territorio/data/model/quadra.dart';
import 'package:territorio/pages/pdf_viewer.dart';

class PrintPage extends StatefulWidget {
  final List<Quadra> quadrasList;
  const PrintPage({super.key, required this.quadrasList});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  final polygonsList = <Polygon>[];
  GlobalKey globalKey = GlobalKey();
  final congregationTextController = TextEditingController();
  final territorioTextController = TextEditingController();
  final cartaoTextController = TextEditingController();

  @override
  initState() {
    for (Quadra quadra in widget.quadrasList) {
      final Polygon poly = Polygon(
        points: quadra.coordinates,
        borderColor: Color(quadra.color),
        borderStrokeWidth: 5,
      );
      polygonsList.add(poly);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printing Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (context, instance) {
              if (instance.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              final territorio = instance.data!.getString('territorio');
              final cartao = instance.data!.getString('cartao');
              territorioTextController.text = territorio ?? '';
              cartaoTextController.text = cartao ?? '';
              return Column(
                children: [
                  TextFormField(
                    controller: territorioTextController,
                    decoration: const InputDecoration(
                      label: Text('Nome do território'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: cartaoTextController,
                    decoration: const InputDecoration(
                      label: Text('Número do cartão'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enquadre a visualização',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 200,
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: RepaintBoundary(
                      key: globalKey,
                      child: FlutterMap(
                        options: MapOptions(
                          zoom: 17,
                          center: widget.quadrasList.first.coordinates[3],
                          //interactiveFlags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            minNativeZoom: 11,
                            minZoom: 11,
                            //subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                            errorTileCallback: (tile, error) => debugPrint('tile: $tile error: $error'),
                            errorImage: const AssetImage('assets/images/grey_background.jpg'),
                            tileProvider: NetworkTileProvider(),
                          ),
                          /* PolygonLayer(
                            polygons: polygonsList,
                          ), */
                          MarkerLayer(
                            markers: getQuadraIDMarker(widget.quadrasList),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final provider = Provider.of<QuadrasController>(context, listen: false);
          provider.clearList();
          final instance = await SharedPreferences.getInstance();
          final image = await _capturePng();
          instance.setString('territorio', territorioTextController.text);
          instance.setString('cartao', cartaoTextController.text);
          generatePdf(
            image: image,
            territorio: territorioTextController.text,
            cartao: cartaoTextController.text,
          ).then(
            (value) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerPage(pdf: value, cartao: cartaoTextController.text),
              ),
            ),
          );
        },
        child: ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (context, isLoading, _) {
              return isLoading ? const CircularProgressIndicator() : const Icon(Icons.picture_as_pdf);
            }),
      ),
    );
  }

  List<Marker> getQuadraIDMarker(List<Quadra> quadrasList) {
    List<Marker> markers = [];
    for (Quadra quadra in quadrasList) {
      markers.add(
        Marker(
          point: quadra.center,
          height: 20,
          width: 40,
          rotate: true,
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
    return markers;
  }

  Future<Uint8List> _capturePng() async {
    RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  }
}
