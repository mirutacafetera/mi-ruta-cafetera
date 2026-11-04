# ☕ Mi Ruta Mágica del Café

<p align="center">
  **Una experiencia para descubrir la cultura cafetera y el turismo de nuestra región.**
</p>

## 📖 Descripción del proyecto

**Mi Ruta Mágica del Café**, también conocido como **Mi Ruta Cafetera**, es una plataforma móvil desarrollada para promover la cultura cafetera, el turismo y las experiencias de nuestra región.

Su propósito es conectar a los visitantes con los destinos turísticos y cafeteros, facilitando el descubrimiento de lugares de interés, la consulta de información turística y la planificación de recorridos.

La aplicación permite explorar sitios turísticos, conocer sus actividades, productos y contenidos, consultar reseñas de otros visitantes y visualizar rutas mediante herramientas de geolocalización y navegación.

Además, cuenta con módulos de administración que permiten gestionar la información de los sitios y sus diferentes contenidos, contribuyendo a mantener una plataforma organizada y actualizada.

## 🎯 Objetivo general

Desarrollar una aplicación móvil que facilite la promoción y exploración de los destinos turísticos y cafeteros de la región, integrando herramientas de geolocalización, consulta de información, planificación de rutas e interacción entre visitantes y establecimientos, con el fin de fortalecer el turismo y difundir la riqueza cultural y cafetera del territorio.

## ✨ Funcionalidades principales

### 👤 Módulo de usuarios

- Registro e inicio de sesión.
- Autenticación y gestión de cuentas.
- Exploración y búsqueda de sitios turísticos.
- Filtrado de sitios por categorías.
- Consulta de información detallada de cada destino.
- Visualización de imágenes y galerías.
- Consulta de actividades, productos y contenidos.
- Reproducción de audioguías.
- Registro y consulta de reseñas y calificaciones.
- Gestión de sitios favoritos.
- Consulta de ubicación de los destinos.
- Visualización y planificación de recorridos turísticos.

### 🗺️ Mapas y rutas turísticas

- Visualización de sitios turísticos en el mapa.
- Ubicación de los destinos mediante coordenadas geográficas.
- Integración con la ubicación GPS del dispositivo.
- Búsqueda y filtrado de sitios.
- Visualización de rutas predefinidas.
- Creación de recorridos personalizados mediante la selección de destinos.
- Cálculo de rutas por carretera.
- Consulta de distancias y tiempos estimados de recorrido.

### 🏪 Módulo de propietarios de sitios

Permite a los responsables de los establecimientos administrar la información y los servicios asociados a sus sitios turísticos.

Entre sus funcionalidades se encuentran:

- Gestión del perfil e información del establecimiento.
- Administración de imágenes y contenido multimedia.
- Gestión de actividades y experiencias.
- Administración de productos.
- Creación y gestión de contenidos turísticos.
- Administración de audioguías.
- Consulta y gestión de reseñas.
- Gestión de reservas.
- Generación y consulta de reportes.
- Administración de la información relacionada con el establecimiento.

### 🛠️ Módulo de administración

Permite gestionar y supervisar la información general de la plataforma.

Incluye herramientas para:

- Administración de sitios turísticos.
- Gestión de categorías.
- Gestión de actividades.
- Administración de contenidos.
- Gestión de productos.
- Supervisión de reseñas.
- Administración de reservas.
- Gestión de cuentas de propietarios de sitios.
- Administración de rutas predefinidas.

## 🧰 Tecnologías utilizadas

### Frontend

- **Flutter:** desarrollo de la aplicación móvil.
- **Dart:** lenguaje de programación del frontend.
- **Material Design:** componentes y elementos de interfaz.
- **flutter_map:** visualización de mapas.
- **latlong2:** manejo de coordenadas geográficas.
- **geolocator:** acceso a la ubicación del dispositivo.
- **just_audio:** reproducción de audioguías.
- **HTTP:** comunicación con el backend mediante peticiones HTTP.

### Backend

- **Node.js:** entorno de ejecución de JavaScript.
- **Express.js:** desarrollo de servicios y API REST.
- **Mongoose:** modelado y gestión de datos.
- **JWT:** autenticación mediante tokens.
- **Nodemon:** herramienta de desarrollo para reiniciar el servidor automáticamente.

### Base de datos

- **MongoDB:** almacenamiento de la información de usuarios, sitios turísticos, categorías, actividades, productos, contenidos, reseñas, reservas y demás registros de la plataforma.

### Almacenamiento multimedia

- **Cloudinary:** almacenamiento y gestión de imágenes y recursos multimedia.

### Herramientas de desarrollo

- Git.
- GitHub.
- Visual Studio Code.
- npm.
- Android Studio.
- Flutter SDK.

## 🏗️ Arquitectura general

El proyecto utiliza una arquitectura cliente-servidor:

1. **Frontend:** aplicación móvil desarrollada en Flutter, encargada de la interfaz y la interacción con los usuarios.
2. **Backend:** servidor desarrollado con Node.js y Express.js, encargado de procesar solicitudes, gestionar la lógica de negocio y exponer los servicios de la aplicación.
3. **Base de datos:** MongoDB, utilizada para almacenar y consultar la información.
4. **Almacenamiento multimedia:** Cloudinary, utilizado para gestionar recursos gráficos y fotografías.

La comunicación entre el frontend y el backend se realiza mediante una API REST.

## 📁 Estructura del proyecto

La organización general del repositorio es la siguiente:

```text
mi-ruta-cafetera/
│
├── backend/
│   ├── config/
│   ├── controllers/
│   ├── middlewares/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── .env
│   ├── index.js
│   ├── package.json
│   └── package-lock.json
│
├── frontend/
│   └── mi_ruta_cafetera/
│       ├── android/
│       ├── ios/
│       ├── lib/
│       │   ├── config/
│       │   ├── controllers/
│       │   ├── models/
│       │   ├── screens/
│       │   ├── services/
│       │   ├── theme/
│       │   └── widgets/
│       ├── test/
│       ├── web/
│       ├── windows/
│       ├── pubspec.yaml
│       └── pubspec.lock
│
├── .gitignore
└── README.md
```

## ⚙️ Instalación y configuración

### Requisitos previos

Antes de ejecutar el proyecto, es necesario contar con:

- Node.js y npm.
- Flutter SDK.
- Dart SDK (incluido con Flutter).
- MongoDB o una instancia de MongoDB Atlas.
- Un editor de código, como Visual Studio Code.
- Android Studio o un dispositivo Android para ejecutar la aplicación.

### 1. Clonar el repositorio

```bash
git clone https://github.com/mirutacafetera/mi-ruta-cafetera.git
```

Ingresar a la carpeta:

```bash
cd mi-ruta-cafetera
```

### 2. Configurar el backend

Ingresar a la carpeta del backend:

```bash
cd backend
```

Instalar las dependencias:

```bash
npm install
```

Crear el archivo `.env` con las variables de entorno necesarias para la conexión a la base de datos y los servicios del backend.

Ejemplo de configuración:

```env
PORT=3000
MONGO_URI=tu_uri_de_mongodb
```

También deben configurarse las credenciales de los servicios externos utilizados por el backend, como Cloudinary y los mecanismos de autenticación.

**Importante:** el archivo `.env` contiene información privada y no debe publicarse en GitHub.

### 3. Ejecutar el backend

Desde la carpeta `backend`, iniciar el servidor con:

```bash
npm start
```

Si el proyecto tiene configurado el script de desarrollo:

```bash
npm run dev
```

### 4. Configurar el frontend

Abrir una segunda terminal e ingresar a:

```bash
cd frontend/mi_ruta_cafetera
```

Instalar las dependencias de Flutter:

```bash
flutter pub get
```

Verificar la configuración del proyecto:

```bash
flutter doctor
```

Configurar la dirección de la API para que la aplicación pueda comunicarse con el backend.

### 5. Ejecutar la aplicación

Conectar un dispositivo Android o iniciar un emulador y ejecutar:

```bash
flutter run
```

## 📱 Generar APK

Para generar el archivo de instalación de Android, ejecutar desde la carpeta `frontend/mi_ruta_cafetera`:

```bash
flutter build apk --release
```

El APK generado se encontrará en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Este archivo permite instalar la aplicación en dispositivos Android compatibles.

## 🔐 Seguridad y configuración

El proyecto utiliza mecanismos de autenticación para proteger el acceso a las funcionalidades correspondientes a cada tipo de usuario.

Las credenciales y configuraciones privadas se administran mediante variables de entorno. Se recomienda no publicar contraseñas, tokens, claves de servicios externos ni archivos `.env` en el repositorio.

## 👥 Equipo de desarrollo

### Aprendices SENA

- **Ana María Ramos Rojas**
- **Sofia Durán Medina**
- **Elver Mauricio Fernández Elizalde**

## 🎓 Formación

**Servicio Nacional de Aprendizaje — SENA**

Proyecto desarrollado como parte del proceso de formación de los aprendices.

## 📌 Estado del proyecto

🚧 **En desarrollo y mejora continua.**

Mi Ruta Mágica del Café continúa evolucionando mediante la incorporación de nuevas funcionalidades, optimizaciones y mejoras en la experiencia de usuario, con el propósito de fortalecer la promoción turística y cultural de la región.

## 📄 Licencia

La licencia del proyecto está pendiente de definición.
