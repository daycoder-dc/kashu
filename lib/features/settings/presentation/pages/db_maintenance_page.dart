import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/db_backup_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';

class DbMaintenancePage extends StatefulWidget {
  const DbMaintenancePage({super.key});

  @override
  State<DbMaintenancePage> createState() => _DbMaintenancePageState();
}

class _DbMaintenancePageState extends State<DbMaintenancePage> {
  final _backupService = DbBackupService();
  bool _busy = false;
  String _dbSize = '...';

  @override
  void initState() {
    super.initState();
    _loadSize();
  }

  Future<void> _loadSize() async {
    final bytes = await _backupService.fileSizeBytes();
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
    if (mounted) setState(() => _dbSize = '$mb MB');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimiento de datos'),
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Opacity(
          opacity: _busy ? 0.6 : 1.0,
          child: ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Row(
                    children: [
                      Icon(PhosphorIconsLight.database,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Base de datos',
                                style: theme.textTheme.titleSmall),
                            const SizedBox(height: Spacing.xs),
                            Text('Tamaño: $_dbSize',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                )),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _run(() async {
                          await _backupService.vacuum(sl<AppDatabase>());
                          await _loadSize();
                          _showSnack('Base de datos compactada');
                        }),
                        child: const Text('VACUUM'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text('Copias de seguridad',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: Spacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _run(_exportBackup),
                        icon: Icon(PhosphorIconsLight.export),
                        label: const Text('Exportar copia de seguridad'),
                      ),
                      const SizedBox(height: Spacing.sm),
                      OutlinedButton.icon(
                        onPressed: () => _confirmImport(),
                        icon: Icon(PhosphorIconsLight.downloadSimple),
                        label: const Text('Importar copia de seguridad'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'La exportacion crea una copia de tu base de datos que puedes guardar en cualquier ubicacion. La importacion reemplaza todos los datos actuales.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportBackup() async {
    final copy = await _backupService.exportCopy();
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Guardar copia de seguridad',
      fileName: copy.uri.pathSegments.last,
      bytes: await copy.readAsBytes(),
    );
    if (uri != null) {
      _showSnack('Copia de seguridad exportada');
    }
  }

  void _confirmImport() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importar base de datos'),
        content: const Text(
          'Esto reemplazara todos tus datos actuales con los del archivo seleccionado. Esta accion no se puede deshacer.\n\nDespues de importar, debes reiniciar la app completamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _run(_importBackup);
            },
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  Future<void> _importBackup() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
    );
    if (files.isEmpty || files.single.path == null) return;

    await _backupService.importFrom(
      files.single.path!,
      sl<AppDatabase>(),
    );
    exit(0);
  }
}
