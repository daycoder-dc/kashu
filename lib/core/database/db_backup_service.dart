import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import 'app_database.dart';

class InvalidBackupFile implements Exception {
  final String message;
  const InvalidBackupFile(this.message);
  @override
  String toString() => 'InvalidBackupFile: $message';
}

class DbBackupService {
  static const _sqliteMagic = [0x53, 0x51, 0x4C, 0x69, 0x74, 0x65];

  Future<String> get _dbPath async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, AppConstants.databaseName);
  }

  Future<int> fileSizeBytes() async {
    final file = File(await _dbPath);
    if (!await file.exists()) return 0;
    return file.length();
  }

  Future<File> exportCopy() async {
    final dbFile = File(await _dbPath);
    final tempDir = await getTemporaryDirectory();
    final now = DateTime.now();
    final stamp =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final dest = File(p.join(tempDir.path, 'kashu_backup_$stamp.db'));
    return dbFile.copy(dest.path);
  }

  Future<void> importFrom(String sourcePath, AppDatabase db) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const InvalidBackupFile('El archivo no existe');
    }

    final header = await source.openRead(0, 6).fold<List<int>>(
      [],
      (prev, chunk) => prev..addAll(chunk),
    );
    if (header.length < 6 ||
        !_matchesMagic(Uint8List.fromList(header))) {
      throw const InvalidBackupFile(
          'El archivo no es una base de datos SQLite valida');
    }

    await db.close();

    final dbPath = await _dbPath;
    final walFile = File('$dbPath-wal');
    final shmFile = File('$dbPath-shm');
    if (await walFile.exists()) await walFile.delete();
    if (await shmFile.exists()) await shmFile.delete();

    await source.copy(dbPath);
  }

  Future<void> vacuum(AppDatabase db) async {
    await db.customStatement('VACUUM');
  }

  bool _matchesMagic(Uint8List header) {
    for (var i = 0; i < _sqliteMagic.length; i++) {
      if (header[i] != _sqliteMagic[i]) return false;
    }
    return true;
  }
}
