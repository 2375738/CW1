import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

Future<DatabaseFactory> getDatabaseFactory() async {
  return databaseFactoryIo;
}

Future<String> getDatabasePath(String dbName) async {
  final directory = await getApplicationDocumentsDirectory();
  return p.join(directory.path, dbName);
}
