# Delivery Platform — Sistema Inteligente de Delivery para Restaurantes Locales

Plataforma completa de delivery estilo PedidosYa/Rappi, enfocada en restaurantes locales, con pedidos en tiempo real, gestión de repartidores, rutas inteligentes, seguimiento GPS y chatbot IA.

---

## 🏗️ Arquitectura

```
┌─────────────────┐   ┌──────────────────┐   ┌───────────────────┐
│  Flutter App     │   │  Flutter App     │   │  React Admin Web  │
│  (Cliente)       │   │  (Repartidor)    │   │  (Panel Admin)    │
└────────┬────────┘   └────────┬─────────┘   └────────┬──────────┘
         │                     │                      │
         └─────────────────────┼──────────────────────┘
                               │
                        ┌──────▼──────┐
                        │   Nginx     │  Reverse Proxy + SSL
                        │  (Gateway)  │  Rate Limiting + WAF
                        └──────┬──────┘
                               │
                        ┌──────▼──────┐
                        │   Backend   │  Node.js + Express + TypeScript
                        │ (Monolito)  │  Modular Architecture
                        └──────┬──────┘
                               │
               ┌───────────────┼───────────────┐
               │               │               │
        ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐
        │  PostgreSQL  │ │    Redis    │ │  Firebase   │
        │  + PostGIS   │ │ (Cache/Ses) │ │  (FCM/Push) │
        └──────────────┘ └─────────────┘ └─────────────┘
```

## 🚀 Stack Tecnológico

| Componente | Tecnología |
|---|---|
| App Móvil (Cliente) | Flutter + Dart |
| App Móvil (Repartidor) | Flutter + Dart |
| Panel Admin Web | React 18 + TypeScript + Vite + TailwindCSS |
| Backend | Node.js + Express + TypeScript |
| Base de Datos | PostgreSQL 16 + PostGIS |
| Cache / Sesiones | Redis 7 |
| Autenticación | JWT (access + refresh tokens) |
| Mapas / Rutas | Google Maps API |
| Notificaciones Push | Firebase Cloud Messaging |
| Chatbot IA | OpenAI GPT-4o |
| Proxy / Gateway | Nginx |
| Contenedores | Docker + Docker Compose |
| CI/CD | GitHub Actions |
| Infraestructura | AWS (ECS, RDS, ElastiCache, S3) |

## 📱 Aplicaciones Móviles

### App Cliente
- Registro/Login con JWT + biométrico
- Búsqueda de restaurantes por ubicación, categoría, rating
- Exploración de menús con variantes y extras
- Carrito de compras con persistencia
- Checkout con múltiples métodos de pago
- Seguimiento GPS en tiempo real del repartidor
- Chatbot IA para recomendaciones y soporte
- Historial de pedidos con re-orden
- Calificaciones y reviews

### App Repartidor
- Toggle de disponibilidad (ON/OFF)
- Pedidos disponibles cercanos con mapa de demanda
- Aceptación/rechazo de pedidos con notificaciones
- Navegación paso a paso con Google Maps
- Ruta optimizada multi-parada
- Confirmación de recogida y entrega
- Resumen de ganancias (hoy/semana/mes)
- Gestión de documentos (verificación)

## 🌐 Panel Web Administrativo

- **Dashboard**: KPIs en tiempo real, gráficos de ingresos y pedidos
- **Restaurantes**: CRUD completo, aprobación, comisiones, horarios, menú
- **Repartidores**: Gestión de flota, verificación documentos, ubicación en mapa
- **Usuarios**: Gestión de cuentas, roles, estados
- **Pedidos**: Monitoreo global, cancelación, re-asignación
- **Reportes**: Analytics avanzados, exportación CSV/PDF/Excel
- **Auditoría**: Log de todas las acciones administrativas
- **Configuración**: Comisiones, tarifas, métodos de pago, templates

## 🗄️ Base de Datos

- 25+ tablas normalizadas
- PostGIS para consultas geoespaciales
- Particionamiento por mes para historial de ubicaciones
- Triggers para actualización automática de ratings
- Índices compuestos para queries frecuentes
- Transacciones ACID para operaciones críticas

## 🔒 Seguridad

- JWT RS256 con refresh token rotation
- bcrypt para hash de contraseñas (costo 12)
- Rate limiting por endpoint
- Helmet.js para headers de seguridad
- Validación de datos con express-validator
- Auditoría de acciones administrativas
- CORS estricto
- TLS 1.3 en producción

---

## 📋 Requisitos

- Node.js 18+
- Docker + Docker Compose
- Flutter 3.16+
- PostgreSQL 16 (o usar Docker)
- Redis 7 (o usar Docker)
- Google Maps API Key
- Firebase project (para FCM)
- OpenAI API Key (opcional, para chatbot)

## 🚀 Inicio Rápido

```bash
# 1. Clonar el repositorio
git clone <repo-url> delivery-platform
cd delivery-platform

# 2. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus API keys

# 3. Ejecutar setup
chmod +x scripts/setup.sh
./scripts/setup.sh

# 4. Iniciar desarrollo
make dev
```

El script de setup:
- Instala dependencias de Node.js (backend + web admin)
- Configura variables de entorno
- Crea directorios necesarios
- Inicia PostgreSQL y Redis con Docker
- Aplica schema de base de datos

## 🐳 Docker (Producción)

```bash
# Construir imágenes
make docker-build

# Iniciar todos los servicios
make docker-up

# Ver logs
make docker-logs

# Detener servicios
make docker-down

# Reset completo (incluye volúmenes)
make docker-reset
```

## 🧪 Testing

```bash
# Backend tests
make test

# Tests específicos
cd backend && npm run test
cd backend && npm run test:e2e
```

## 📦 Estructura del Proyecto

```
delivery-platform/
├── backend/              # API REST (Node.js + Express + TypeScript)
│   ├── src/
│   │   ├── config/       # Configuración (DB, env, logger)
│   │   ├── database/     # Schema SQL, migraciones
│   │   ├── middleware/    # Auth, validation, error handling
│   │   ├── modules/      # Módulos de negocio (11 módulos)
│   │   │   ├── auth/     # Autenticación JWT
│   │   │   ├── users/    # Gestión de usuarios
│   │   │   ├── restaurants/
│   │   │   ├── products/
│   │   │   ├── orders/
│   │   │   ├── payments/
│   │   │   ├── drivers/
│   │   │   ├── routes/
│   │   │   ├── notifications/
│   │   │   ├── chatbot/
│   │   │   └── reports/
│   │   └── shared/       # Interfaces, enums, helpers
│   └── Dockerfile
├── mobile/
│   ├── client_app/       # App Flutter (Cliente)
│   └── driver_app/       # App Flutter (Repartidor)
├── web/
│   └── admin-panel/      # Panel Admin (React + Vite + TailwindCSS)
├── docker/
│   ├── nginx.conf        # Configuración de Nginx
│   ├── secrets/          # Secretos (FCM, etc.)
│   └── ssl/              # Certificados SSL
├── scripts/
│   ├── setup.sh          # Script de instalación
│   └── deploy.sh         # Script de despliegue
├── docker-compose.yml    # Orquestación de servicios
├── Makefile              # Comandos comunes
├── .env.example          # Variables de entorno
└── README.md
```

## 🔌 API Endpoints

Documentación completa de la API disponible en `docs/api/openapi.yaml`.

### Autenticación
| Método | Ruta | Descripción |
|---|---|---|
| POST | /api/v1/auth/register | Registro de usuario |
| POST | /api/v1/auth/login | Inicio de sesión |
| POST | /api/v1/auth/refresh | Refrescar token |
| POST | /api/v1/auth/logout | Cerrar sesión |

### Restaurantes
| Método | Ruta | Descripción |
|---|---|---|
| GET | /api/v1/restaurants | Listar restaurantes |
| GET | /api/v1/restaurants/nearby | Cercanos por ubicación |
| GET | /api/v1/restaurants/:id | Detalle del restaurante |
| GET | /api/v1/restaurants/:id/products | Menú completo |

### Pedidos
| Método | Ruta | Descripción |
|---|---|---|
| POST | /api/v1/orders | Crear pedido |
| GET | /api/v1/orders/:id | Detalle del pedido |
| GET | /api/v1/orders/tracking/:id | Seguimiento en tiempo real |
| PUT | /api/v1/orders/:id/cancel | Cancelar pedido |

Ver documentación completa de la API en `backend/src/modules/*/routes.ts` o importar `docs/api/postman-collection.json` en Postman.

## 🤖 Chatbot IA

El chatbot utiliza OpenAI GPT-4o con arquitectura RAG para:
- Recomendar restaurantes basado en preferencias
- Sugerir platillos del menú
- Consultar estado de pedidos en tiempo real
- Responder preguntas frecuentes
- Escalar a soporte humano cuando es necesario

## 📄 Licencia

Este proyecto es privado. Todos los derechos reservados.

---

## 🤝 Soporte

Para reportar issues o contribuir, contacta al equipo de desarrollo.
