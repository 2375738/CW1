import 'package:sembast/sembast.dart';
import 'db_platform_io.dart'
    if (dart.library.js_interop) 'db_platform_web.dart' as db_platform;

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  final StoreRef<String, Object?> _store = stringMapStoreFactory.store('familyhub_state');
  Database? _database;

  Future<Database> _open() async {
    if (_database != null) return _database!;
    final factory = await db_platform.getDatabaseFactory();
    final path = await db_platform.getDatabasePath('familyhub.db');
    _database = await factory.openDatabase(path);
    return _database!;
  }

  Future<Map<String, dynamic>?> readState() async {
    final db = await _open();
    final raw = await _store.record('state').get(db);
    if (raw is Map<String, Object?>) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  Future<void> writeState(Map<String, dynamic> state) async {
    final db = await _open();
    await _store.record('state').put(db, state);
  }
}
