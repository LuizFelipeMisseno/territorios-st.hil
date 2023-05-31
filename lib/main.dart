import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:territorio/controllers/quadras.controller.dart';
import 'package:territorio/data/database/ordem%20de%20servico/quadra_database.dart';
import 'package:territorio/data/json/json.dart';
import 'package:territorio/data/model/quadra.dart';
import 'package:territorio/pages/map.dart';
import 'package:territorio/pages/print_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbData = await QuadraDatabase().readAll();
  if (dbData.isEmpty) {
    await _populateDb();
  }
  runApp(const MyApp());
}

_populateDb() async {
  for (var polygon in json['features'] as List) {
    final quadra = Quadra.fromJson(polygon);
    log(quadra.toString());
    await QuadraDatabase().insert(quadra.toJson());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<QuadraDatabase>(
          create: (_) => QuadraDatabase(),
        ),
        ChangeNotifierProvider<QuadrasController>(
          create: (_) => QuadrasController(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(title: 'Territórios Santo Hilário'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          /* IconButton(
            onPressed: () {
              QuadraDatabase().clearDatabase();
            },
            icon: const Icon(Icons.delete),
          ), */
          /* IconButton(
            onPressed: () async {
              QuadrasController controller = QuadrasController();
              final file = await _pickFile();
              controller.addCoordinatesFromKML(file!.files.first.path!);
            },
            icon: const Icon(Icons.add),
          ), */
        ],
      ),
      body: Consumer<QuadraDatabase>(
        builder: (context, provider, _) {
          return FutureBuilder<List<Quadra>>(
            future: _getQuadras(provider),
            builder: (context, quadrasList) {
              return Consumer<QuadrasController>(
                builder: (context, controller, _) {
                  final selectedList = controller.selectedList;
                  return MyMap(
                    mapController: controller.mapController,
                    quadrasList: quadrasList.data ?? [],
                    selectedList: selectedList,
                    quadrasController: controller,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<QuadrasController>(
        builder: (context, controller, _) {
          final selectedList = controller.selectedList;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: selectedList.isEmpty
                ? Container()
                : FloatingActionButton(
                    onPressed: () {
                      _showPreview(selectedList);
                    },
                    child: const Icon(Icons.print),
                  ),
          );
        },
      ),
    );
  }

  Future<FilePickerResult?> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    await Future.delayed(const Duration(milliseconds: 500));
    return result;
  }

  _showPreview(selectedList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrintPage(quadrasList: selectedList),
      ),
    );
  }

  Future<List<Quadra>> _getQuadras(QuadraDatabase provider) async {
    List<Quadra> quadrasList = [];
    final quadras = await provider.readAll();
    for (var polygon in quadras) {
      quadrasList.add(Quadra.fromJson(polygon));
    }
    return quadrasList;
  }
}
