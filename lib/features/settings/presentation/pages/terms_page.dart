import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidad y datos'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _section(
            theme,
            'Tus datos son tuyos',
            'Kashu funciona 100% offline. Ningun dato sale de tu dispositivo. '
                'No recopilamos, transmitimos ni almacenamos informacion '
                'personal en servidores externos.',
          ),
          const SizedBox(height: 24),
          _section(
            theme,
            'Almacenamiento local',
            'Todos tus datos financieros se guardan en una base de datos '
                'SQLite en el almacenamiento interno de tu dispositivo. '
                'Solo tu tienes acceso.',
          ),
          const SizedBox(height: 24),
          _section(
            theme,
            'Copias de seguridad',
            'Puedes exportar e importar tu base de datos desde la seccion '
                'de Configuracion. Eres responsable de mantener copias de '
                'seguridad de tus datos.',
          ),
          const SizedBox(height: 24),
          _section(
            theme,
            'Permisos',
            'Kashu solicita permiso de biometria unicamente para el '
                'desbloqueo de la app. No accede a internet, contactos, '
                'ubicacion ni ningun otro recurso.',
          ),
        ],
      ),
    );
  }

  Widget _section(ThemeData theme, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
