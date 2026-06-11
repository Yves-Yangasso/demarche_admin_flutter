import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('terreadmin.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dossiers (
        id INTEGER PRIMARY KEY,
        reference TEXT,
        statut TEXT,
        description TEXT,
        date_soumission TEXT,
        date_echeance TEXT,
        type_demarche TEXT
      )
    ''');
  }

  Future<void> saveDossiers(List<Dossier> dossiers) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var d in dossiers) {
      batch.insert('dossiers', d.toJson(), 
        conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<List<Dossier>> getCachedDossiers() async {
    final db = await instance.database;
    final maps = await db.query('dossiers');
    return maps.map((m) => Dossier.fromJson(m)).toList();
  }
}
