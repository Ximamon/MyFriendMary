# MyFriendMary

Aplicación iOS (SwiftUI + SwiftData) para seguimiento menstrual, síntomas, encuentros y anticoncepción (anillo vaginal), con enfoque local-first y privacidad.

## Estado del proyecto

- Plataforma: iOS 26.2+
- Arquitectura: Clean Architecture (`App / Domain / Data / Presentation`)
- Persistencia: SwiftData (local, sin backend)
- Idioma UI: español
- Sin analítica ni publicidad

## Objetivo del repositorio público

Este repositorio es público por transparencia y colaboración técnica.

### Estado de licencia en este proyecto

- Este repositorio se publica como **source-available** con licencia **no comercial**.
- Licencia actual: **PolyForm Noncommercial 1.0.0** (ver archivo `LICENSE`).
- Este proyecto **no es open source OSI** por la restricción de uso comercial.
- Recomendado como siguiente paso: añadir política de marca/nombre/logo para limitar clones que se presenten como app oficial.

## Privacidad y datos sensibles

- Datos de salud y sexualidad tratados localmente.
- No se envían eventos sensibles a terceros.
- Diseño preparado para endurecer cifrado y controles adicionales en siguientes iteraciones.

## Estructura principal

```text
MyFriendMary/
  App/
  Domain/
  Data/
  Presentation/
  Shared/
```

## Desarrollo local

1. Abrir `MyFriendMary.xcodeproj` en Xcode.
2. Seleccionar simulador iOS 26.2+.
3. Build & Run.

## Hoja de ruta breve

- Completar stubs de notificaciones, cifrado y biometría.
- Afinar experiencia de calendario/resumen.
- Endurecer modelo de exportación y controles de privacidad.

## Disclaimer

Este README documenta la intención de licencia del proyecto, pero no sustituye asesoría legal.
