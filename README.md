# ☕ Mi Ruta Cafetera

## 📖 Descripción

**Mi Ruta Cafetera** es una plataforma web desarrollada para dar a conocer la cultura cafetera, los lugares turísticos y las experiencias relacionadas con el café en nuestra región.

El proyecto busca conectar a los visitantes con diferentes destinos cafeteros, permitiéndoles conocer información sobre lugares de interés, rutas y experiencias, contribuyendo así a la promoción del turismo y la cultura cafetera.

---

## 🚀 Stack tecnológico

Para el desarrollo de **Mi Ruta Cafetera** trabajaremos con las siguientes tecnologías:

### Frontend

* HTML5
* CSS3
* JavaScript
* [Tecnología del frontend que utilicen]

### Backend

* Node.js
* Express.js
* Nodemon

### Base de datos

* MongoDB

### Herramientas

* Git
* GitHub
* Visual Studio Code
* npm

---

## ✨ Características del proyecto

Entre las principales funcionalidades de **Mi Ruta Cafetera** se encuentran:

* 🗺️ Visualización de rutas y destinos cafeteros.
* ☕ Información sobre lugares relacionados con la cultura cafetera.
* 📍 Ubicación de sitios turísticos.
* 🏞️ Información sobre atractivos turísticos.
* 👤 Gestión de usuarios.
* 🔐 Sistema de autenticación.
* 📝 Registro y administración de información.
* 🔎 Búsqueda y consulta de lugares.
* 📱 Diseño adaptable a diferentes dispositivos.
* 💾 Almacenamiento de información mediante MongoDB.

> Las funcionalidades pueden ampliarse durante el desarrollo del proyecto.

---

## ⚙️ Instalación y configuración

### 1. Clonar el repositorio

Primero, clona el repositorio desde GitHub:

```bash
git clone URL_DEL_REPOSITORIO
```

Luego ingresa a la carpeta del proyecto:

```bash
cd mi-ruta-cafetera
```

### 2. Instalar Node.js y npm

Descarga e instala **Node.js**, que incluye npm.

Puedes verificar que la instalación sea correcta ejecutando:

```bash
node -v
npm -v
```

### 3. Instalar las dependencias

Desde la carpeta del backend ejecuta:

```bash
npm install
```

### 4. Dependencias principales

El backend utiliza:

```bash
npm install express
npm install mongodb
npm install dotenv
```

Para instalar **Nodemon** como dependencia de desarrollo:

```bash
npm install --save-dev nodemon
```

### 5. Configurar MongoDB

Para ejecutar el proyecto es necesario contar con una base de datos en **MongoDB**.

Crear un archivo `.env` dentro de la carpeta `backend`:

```env
PORT=3000
MONGODB_URI=tu_conexion_de_mongodb
```

> No subir el archivo `.env` a GitHub. Se recomienda agregarlo al archivo `.gitignore`.

---

## ▶️ Ejecutar el servidor

Para iniciar el servidor en modo desarrollo:

```bash
npm run dev
```

Si todo está correctamente configurado, el servidor estará disponible en:

```text
http://localhost:3000
```

---

## 📁 Estructura del proyecto

La estructura general del proyecto será:

```text
mi-ruta-cafetera/
│
├── backend/
│   ├── src/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── config/
│   │   └── app.js
│   │
│   ├── .env
│   ├── .gitignore
│   ├── package.json
│   └── server.js
│
├── frontend/
│   ├── css/
│   ├── js/
│   ├── img/
│   └── index.html
│
└── README.md
```

---

## 👥 Autores

### Aprendices SENA

* **[Nombre del aprendiz 1]**
* **[Nombre del aprendiz 2]**
* **[Nombre del aprendiz 3]**
* **[Nombre del aprendiz 4]**

---

## 🎓 Formación

**Servicio Nacional de Aprendizaje — SENA**

Proyecto desarrollado como parte del proceso de formación de los aprendices.

---

## 📌 Estado del proyecto

🚧 **En desarrollo**

El proyecto se encuentra actualmente en proceso de desarrollo. Se irán agregando nuevas funcionalidades y mejoras durante las diferentes etapas del proyecto.

---

## 📄 Licencia

Este proyecto fue desarrollado con fines educativos como parte del proceso de formación del SENA.
