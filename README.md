# Kashu

Administrador de finanzas personales offline para Android.

Todo se guarda en tu dispositivo, sin internet. Sin cuentas, sin servidores, sin rastreo.

## Funcionalidades

- **Dashboard** — resumen mensual de ingresos, gastos, pagado y disponible
- **Transacciones** — registro de ingresos y gastos por categoria con vista mensual
- **Gastos fijos** — seguimiento de gastos recurrentes mensuales con marcado de pago
- **Creditos** — tracking de deudas con tasa de interes, cuotas, amortizacion y pagos
- **Estadisticas** — graficos de torta y barras por categoria
- **Respaldo** — exportar/importar base de datos, compactar (VACUUM)
- **Seguridad** — PIN de 4 digitos + autenticacion biometrica, bloqueo automatico

## Stack

| Capa | Tecnologia |
|------|-----------|
| Framework | Flutter 3.47 (Dart ^3.13) |
| Arquitectura | Clean Architecture por features |
| Estado | flutter_bloc (Cubit) |
| Base de datos | SQLite via Drift |
| Navegacion | go_router (StatefulShellRoute) |
| DI | get_it |
| UI | Material 3, flex_color_scheme, Plus Jakarta Sans |
| Iconos | phosphoricons_flutter |
| Graficos | fl_chart |
| Auth | flutter_secure_storage, local_auth |

## Estructura del proyecto

```
lib/
  app/            — App widget, router
  core/           — Database, DI, theme, utils, constants
  features/
    auth/         — PIN, biometrics, onboarding, splash
    dashboard/    — Resumen mensual
    transactions/ — CRUD de transacciones
    fixed_expenses/ — Gastos fijos recurrentes
    debts/        — Creditos y amortizacion
    statistics/   — Graficos y breakdown por categoria
    settings/     — Configuracion, creditos, terminos, mantenimiento DB
  shared/         — Widgets reutilizables (KpiCard, MonthSelector, etc.)
```

## Build

```bash
# Debug
flutter build apk --debug

# Release (requiere key.properties + keystore)
flutter build apk --release
```

## Configuracion de firma

1. Generar keystore: `keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias kashu`
2. Crear `android/key.properties`:
   ```
   storePassword=<password>
   keyPassword=<password>
   keyAlias=kashu
   storeFile=upload-keystore.jks
   ```

Ambos archivos estan en `.gitignore`.

## Autor

Dairo Carrasquilla
