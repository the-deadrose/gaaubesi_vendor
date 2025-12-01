# Gaaubesi Vendor App

This project is a production-ready Flutter application using Clean Architecture, BLoC, and other best practices.

## 1. Architecture Overview

The project follows **Clean Architecture** principles, divided into:

- **Core**: Shared infrastructure, utilities, and global configurations.
- **Features**: Feature-specific code (Auth, Home, etc.), each containing:
  - **Data**: Data sources, models, repositories implementation.
  - **Domain**: Entities, repositories interfaces, use cases.
  - **Presentation**: BLoC, pages, widgets.

## 2. Folder Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants (URLs, keys)
│   ├── di/                 # Dependency Injection (get_it)
│   ├── error/              # Global error handling (Failures, Exceptions)
│   ├── network/            # Dio client & interceptors
│   ├── router/             # GoRouter configuration
│   ├── services/           # External services (SecureStorage)
│   ├── theme/              # App Theme & TextStyles
│   ├── usecase/            # Base UseCase class
│   └── utils/              # Helper functions
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/ # Remote/Local data sources
│       │   ├── models/      # DTOs (Data Transfer Objects)
│       │   └── repositories/# Repository Implementation
│       ├── domain/
│       │   ├── entities/    # Core business objects
│       │   ├── repositories/# Repository Interfaces
│       │   └── usecases/    # Business logic units
│       └── presentation/
│           ├── bloc/        # State Management
│           ├── pages/       # UI Screens
│           └── widgets/     # Feature-specific widgets
├── presentation/
│   ├── pages/              # Global pages (Error, Splash)
│   └── widgets/            # Global reusable widgets (Buttons, Inputs)
└── main.dart               # Entry point
```

## 3. Key Components

- **State Management**: `flutter_bloc` is used for managing state.
- **Navigation**: `go_router` handles routing with support for nested routes and guards.
- **Networking**: `dio` is used for API calls, configured with interceptors for token handling.
- **Dependency Injection**: `get_it` manages service location.
- **Storage**: `flutter_secure_storage` securely stores tokens.
- **Functional Programming**: `fpdart` is used for `Either<Failure, T>` result types.

## 4. Getting Started

1.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

2.  **Generate Code** (for JSON serialization):
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

3.  **Run App**:
    ```bash
    flutter run
    ```
