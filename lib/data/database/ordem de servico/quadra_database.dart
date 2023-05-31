import 'package:flutter/cupertino.dart';
import 'package:sembast/sembast.dart';
import 'app_database_instance.dart';

class QuadraDatabase extends ChangeNotifier {
  static const String storeName = 'quadra';
  final store = StoreRef<String, Map<String, dynamic>>.main();
  //Getter para simplificar o código que recebe a instância
  //da base de dados
  Future<Database> get db async => await AppDatabase.instance.database(storeName);

  Future insert(Map<String, dynamic> quadra) async {
    await store.add(
      await db,
      quadra,
    );
  }

  Future<void> update({required dynamic uuid, required Map<String, dynamic> data}) async {
    final finder = Finder(
      filter: Filter.equals(
        "uuid",
        data['uuid'],
      ),
    );
    await store.update(
      await db,
      data,
      finder: finder,
    );
    notifyListeners();
  }

  delete(String uuid) async {
    final finder = Finder(filter: Filter.equals('uuid', uuid));
    await store.delete(
      await db,
      finder: finder,
    );
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final recordSnapshots = await store.find(
      await db,
    );

    return recordSnapshots.map((snapshot) {
      return snapshot.value;
    }).toList();
  }

  Future<void> clearDatabase() async {
    await store.delete(
      await db,
    );
  }

  Future<Map<String, dynamic>?> getSingleQuadra(String uuid) async {
    final finder = Finder(filter: Filter.equals('uuid', uuid));
    var item = await store.findFirst(await db, finder: finder);
    Map<String, dynamic>? quadra;
    if (item != null) {
      quadra = item.value;
    } else {
      quadra = null;
    }
    return quadra;
  }
}
