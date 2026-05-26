📌 Descripción General

Workspace Management System es una aplicación web fullstack diseñada para la gestión de workspaces, proyectos, tareas y colaboración entre equipos dentro de un entorno centralizado.
La plataforma fue desarrollada utilizando una arquitectura moderna basada en Angular 21 y .NET 9, siguiendo buenas prácticas de escalabilidad, separación de responsabilidades y despliegue contenerizado mediante Docker.

▶️ Levantar Toda la Aplicación

Desde la raíz del proyecto ejecutar:
docker compose up --build

Este comando realizará automáticamente:

Construcción de contenedores frontend y backend
Creación del contenedor SQL Server
Ejecución de migraciones
Inserción de datos iniciales
Inicio completo de la aplicación

🌐 Acceso a la Aplicación

| Servicio    | URL                             |
| ----------- | ------------------------------- |
| Frontend    | `http://localhost:4200`         |
| Backend API | `http://localhost:5000`         |

🔐 Credenciale
La aplicación incluye datos precargados para pruebas funcionales.
