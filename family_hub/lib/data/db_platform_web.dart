import 'package:sembast_web/sembast_web.dart';

Future<DatabaseFactory> getDatabaseFactory() async {
  return databaseFactoryWeb;
}

Future<String> getDatabasePath(String dbName) async {
  return dbName;
}
