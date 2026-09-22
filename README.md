# Asistente de consulta del quechua wanka — aplicación móvil

Aplicación Android que consulta el corpus documental publicado sobre el quechua wanka de
Junín **resolviendo todo en el dispositivo, sin red de ninguna clase**. Ninguna consulta ni
fragmento del corpus sale del teléfono.

Es el incremento móvil del proyecto. La versión de escritorio —servicio, interfaz web,
base de datos e ingesta documental— vive en
[asistente-quechua-wanka](https://github.com/DalgomXD-byte/asistente-quechua-wanka), y de
ahí salen los artefactos que esta aplicación empaqueta.

## Qué hace

Responde a la equivalencia de una palabra del español o del inglés en quechua wanka,
citando siempre el documento y la página de los que sale. **No traduce frases**: cuando no
hay respaldo documental lo dice en lugar de proponer una forma inventada, que es la
salvaguarda central del proyecto.

Las consultas en inglés pasan por el español antes de buscar, porque el corpus está
indexado en español: `love` → `amor` → `Kuyay`.

Ante una pregunta de gramática no afirma nada: entrega los pasajes del corpus, literales y
citados, para que los juzgue quien consulta.

## Cómo resuelve sin modelo

| Pieza | Cómo |
|---|---|
| Recuperación | TF-IDF léxico exportado desde el escritorio; el dispositivo solo hace el producto punto |
| Traducción inglés→español | Tabla de 2257 lemas calculada una sola vez, 177 KB |
| Redacción de la respuesta | Compositor determinista sobre la entrada de diccionario |
| Historial | SQLite local |

No hay ningún modelo de lenguaje embarcado. La medición de viabilidad determinó que
ninguno que quepa en un teléfono lee una entrada lexicográfica con fidelidad: uno de
0,8 B llegó a afirmar que *ashuti* significa «uña», y uno de 2 B invirtió la
correspondencia de *agua*. El compositor determinista acertó las 180 de 180 consultas del
conjunto de evaluación.

## Cifras medidas

| | |
|---|---|
| Paquete de instalación (ARM64) | 21,5 MB |
| Índice completo empaquetado | 12 MB, 3605 fragmentos |
| Arranque | ~1,5 s |
| Consulta | 1,7 – 19 ms |

Las latencias están tomadas en emulador x86_64 y **no sirven para declarar requisitos no
funcionales**: para eso hay que medir en un dispositivo ARM real. La instrumentación está
puesta bajo `kDebugMode` y se lee con `adb logcat | grep MEDICION`.

## Arquitectura

Hexagonal, igual que el escritorio:

```
lib/
  dominio/          entidades, objetos de valor y el puerto de consulta
  aplicacion/       depurador, evaluador de confianza, compositor, detector de idioma
  infraestructura/  contenedor y adaptadores de salida
  presentacion/     pantalla y componentes
```

El paso de depender del servicio de escritorio a resolver en el dispositivo fue **cambiar
una línea del contenedor**: `AsistenteHttp()` por `AsistenteLocal.cargar()`. Ni el dominio,
ni los casos de uso, ni una sola pantalla se tocaron, y las pruebas de interfaz siguieron
pasando sin modificarlas. El adaptador HTTP sigue en el proyecto y sigue siendo válido.

## Ejecutar

```bash
flutter pub get
flutter run -d <dispositivo>
```

Para compilar el paquete de instalación:

```bash
flutter build apk --release --split-per-abi
```

## Pruebas

```bash
flutter test
```

Incluye una prueba de paridad que compara el motor de puntuación del dispositivo con el de
scikit-learn sobre quince consultas escogidas por lo que ponen a prueba: acentos y ñ,
coincidencia de lema por debajo del umbral, términos que solo casan por n-gramas de
caracteres, prosa, inglés, consultas fuera de cobertura y una consulta que es solo fraseo.
La diferencia máxima admitida es el redondeo de precisión simple, porque cualquier
desviación mayor desplazaría el umbral calibrado, que es lo que impide que el sistema
proponga formas no documentadas.

## Actualizar el índice

Los archivos de `assets/indice/` se generan desde el repositorio del escritorio:

```bash
python scripts/exportar_indice_movil.py
python scripts/validar_indice_movil.py
```

y se copian a `assets/indice/`. El umbral de abstención viaja en `manifiesto.json` junto
al índice, para que no pueda quedar desincronizado del ajuste con el que se calculó.

## Alcance

Herramienta de consulta sobre fuentes documentales ya publicadas. No sustituye la
validación por hablantes de la comunidad ni se constituye en autoridad lingüística sobre
la variedad wanka.
