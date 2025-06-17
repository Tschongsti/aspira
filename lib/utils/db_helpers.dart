import 'package:aspira/data/database.dart';

Future<List<Map<String, Object?>>> queryById({
  required String table,
  required String id,
}) async {
  final db = await getDatabase();
  return await db.query(
    table,
    where: 'id = ?',
    whereArgs: [id],
  );
}