# Flutter BFSI Project

A Flutter application for Banking, Financial Services, and Insurance (BFSI) sector, featuring secure authentication and simulates a secure transaction dashboard.

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [📥 Download and Run](#-download-and-run)
- [How to Run the App](#how-to-run-the-app)
- [Libraries and Design Decisions](#libraries-and-design-decisions)
- [Project Structure](#project-structure)
- [Features](#features)

## Project Overview

This Flutter application is designed for the BFSI sector, providing a robust and secure platform for managing user authentication and financial transactions. The app demonstrates best practices in Flutter development with a focus on:

- **Secure Authentication**: User login system with token-based authentication stored securely
- **Transaction Management**: Comprehensive transaction listing with pagination and detailed views
- **Modern UI/UX**: Clean, intuitive interface with shimmer loading effects and Material Design 3
- **Offline-First Capability**: Mock data support for development and testing

### Key Features

- User authentication with secure token storage
- Transaction list with infinite scroll pagination
- Transaction detail view
- Pull-to-refresh functionality
- Search and filter capabilities
- Status-based transaction categorization (Success, Failed, Pending)
- Session management with automatic token persistence

## Architecture

This project follows **Clean Architecture** principles combined with the **BLoC (Business Logic Component)** pattern, specifically using **Cubit** for state management. The architecture promotes separation of concerns, testability, and maintainability.

### Architecture Layers

```
lib/
├── auth/                      # Authentication feature module
│   ├── data/                  # Data layer
│   │   └── auth_repository.dart
│   ├── presentation/          # UI layer
│   │   └── login_page.dart
│   ├── security/              # Security utilities
│   │   └── secure_storage_service.dart
│   └── state/                 # Business logic layer
│       ├── auth_cubit.dart
│       └── auth_state.dart
├── transaction/               # Transaction feature module
│   ├── data/                  # Data layer
│   │   └── transaction_repository.dart
│   ├── model/                 # Domain models
│   │   └── transaction_model.dart
│   ├── presentation/          # UI layer
│   │   ├── transaction_list_screen.dart
│   │   └── transaction_details.dart
│   └── state/                 # Business logic layer
│       ├── transaction_cubit.dart
│       └── transaction_state.dart
├── common/                    # Shared utilities
│   ├── colors.dart
│   └── common_widgets.dart
└── main.dart                  # Application entry point
```

### Layer Responsibilities

#### 1. Presentation Layer
- Contains UI widgets and screens
- Observes state changes from Cubits
- Dispatches user actions to Cubits
- Does not contain business logic

#### 2. State Management Layer (Cubit)
- Manages feature-specific state
- Contains business logic
- Communicates with repositories
- Emits state changes to UI
- Uses Equatable for efficient state comparison

#### 3. Data Layer (Repository)
- Handles data operations (API calls, local storage)
- Abstracts data sources from business logic
- Currently uses mock JSON data
- Designed to be easily extended with real API integration

#### 4. Model Layer
- Contains domain entities
- Immutable data classes
- JSON serialization/deserialization logic

### State Management Flow

```
User Interaction → Widget → Cubit (Business Logic) → Repository (Data) → External Data Source
                    ↑                 ↓
                    └─── State Update ←
```

### Design Patterns Used

1. **Repository Pattern**: Abstracts data sources and provides a clean API for data access
2. **Cubit Pattern**: Simplified BLoC for state management
3. **Dependency Injection**: Using flutter_bloc's RepositoryProvider and BlocProvider
4. **Singleton Pattern**: For services like SecureStorageService
5. **Factory Pattern**: For model instantiation from JSON

## 📥 Download and Run

You can download the production-grade APK directly from the [GitHub Releases](https://github.com/sanghavigit/flutterProjectBFSI/releases/tag/v1.0.0).

1. Download the `.apk` file.
2. Install it on an Android device.
3. Use the following mock credentials for login:
   - **Username:** user
   - **Password:** password

## How to Run the App

### Prerequisites

- **Flutter SDK**: Version 3.2.6 or higher
- **Dart SDK**: Version 3.2.6 or higher (comes with Flutter)
- **IDE**: VS Code, Android Studio
- **Platform-specific tools**:
  - For Android: Android Studio with Android SDK
  - For iOS: Xcode (macOS only)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <git clone https://github.com/sanghavigit/flutterProjectBFSI.git>
   cd flutter_project_bfsi
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```
   Resolve any issues reported by this command.

4. **Run the application**

   For mobile (Android/iOS):
   ```bash
   flutter run
   ```

### Login Credentials

The app uses mock authentication. Use these credentials to log in:
- **Username**: Any non-empty string (e.g., `user@example.com`)
- **Password**: Any non-empty string (e.g., `password123`)

### Testing

Run unit and widget tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

### Building for Production

Android APK:
```bash
flutter build apk --release
```

iOS:
```bash
flutter build ios --release
```

## Libraries and Design Decisions

### Core Dependencies

#### State Management
- **flutter_bloc** (^9.1.1) & **bloc** (^9.2.0)
  - **Why**: Industry-standard state management solution that promotes separation of concerns
  - **Alternative considered**: Provider, Riverpod, GetX
  - **Decision rationale**: BLoC provides excellent testability, clear state flow, and scales well with large applications

#### Networking
- **dio** (^5.9.0)
  - **Why**: Powerful HTTP client with interceptors, request/response transformation, and error handling
  - **Alternative considered**: http package
  - **Decision rationale**: Better developer experience, built-in features like request cancellation, interceptors for auth tokens

#### Security
- **flutter_secure_storage** (^9.2.4)
  - **Why**: Secure, encrypted storage for sensitive data like authentication tokens
  - **Alternative considered**: shared_preferences
  - **Decision rationale**: Uses iOS Keychain and Android KeyStore for hardware-backed encryption

#### Utilities
- **equatable** (^2.0.7)
  - **Why**: Simplifies value equality comparisons for state objects
  - **Benefit**: Reduces boilerplate code and prevents unnecessary rebuilds

- **intl** (^0.19.0)
  - **Why**: Internationalization and localization support
  - **Use case**: Date and currency formatting for transactions

- **shimmer** (^3.0.0)
  - **Why**: Creates skeleton loading effects for better UX
  - **Benefit**: Provides visual feedback during data loading

### Development Dependencies

#### Testing
- **flutter_test**: Flutter's built-in testing framework
- **bloc_test** (^10.0.0): Specialized testing utilities for BLoC/Cubit
- **mocktail** (^1.0.4): Mocking library for Dart
  - **Why mocktail over mockito**: Null-safe, no code generation required

#### Code Quality
- **flutter_lints** (^2.0.0): Official Flutter linting rules for consistent code quality

### Design Decisions

#### 1. Feature-First Folder Structure
- **Decision**: Organize code by features (auth, transaction) rather than layers (models, views, controllers)
- **Benefit**: Better encapsulation, easier to locate and modify feature-specific code

#### 2. Cubit over BLoC
- **Decision**: Use Cubit (simplified BLoC) instead of full BLoC pattern
- **Rationale**: Simpler API, less boilerplate, sufficient for most use cases
- **Trade-off**: Full BLoC provides event replay and time-travel debugging, but adds complexity

#### 3. Repository Pattern
- **Decision**: Abstract data access behind repository interfaces
- **Benefit**: Easy to swap mock data with real API calls, improves testability

#### 4. Immutable State
- **Decision**: All state classes are immutable
- **Benefit**: Predictable state changes, easier debugging, better performance

#### 5. Pagination Strategy
- **Decision**: Implement page-based pagination with infinite scroll
- **Implementation**: Load 10 items per page with "load more" trigger at scroll end
- **Benefit**: Better performance with large datasets

#### 6. Secure Token Storage
- **Decision**: Use flutter_secure_storage for authentication tokens
- **Rationale**: Security best practice for sensitive data in BFSI applications

#### 7. Mock Data Approach
- **Decision**: Use local JSON file for transaction data during development
- **Benefit**: Faster development, no backend dependency, easy testing
- **Future**: Repository pattern makes it easy to switch to real API

#### 8. Material Design 3
- **Decision**: Use Material Design 3 (Material You)
- **Benefit**: Modern, adaptive UI with better theming support

## Project Structure

### Auth Module
Handles user authentication and session management.

- **AuthRepository**: Manages authentication API calls
- **AuthCubit**: Controls authentication state and business logic
- **AuthState**: Defines authentication states (Initial, Loading, Authenticated, Error)
- **SecureStorageService**: Handles secure token storage and retrieval
- **LoginPage**: User login interface

### Transaction Module
Manages transaction listing, filtering, and details.

- **TransactionRepository**: Fetches transaction data from mock JSON
- **TransactionCubit**: Handles transaction state and pagination logic
- **TransactionState**: Defines transaction states (Initial, Loading, Loaded, Empty, Error)
- **TransactionModel**: Transaction domain model with JSON parsing
- **TransactionListScreen**: Main transaction listing with search and filters
- **TransactionDetails**: Detailed view of individual transactions

### Common Module
Shared utilities and widgets used across features.

- **colors.dart**: Application color scheme
- **common_widgets.dart**: Reusable UI components

## Features

### Implemented
- ✅ User authentication with token-based security
- ✅ Secure token storage using device keychain
- ✅ Transaction list with pagination (10 items per page)
- ✅ Infinite scroll with "load more" functionality
- ✅ Pull-to-refresh
- ✅ Transaction status filtering (All, Success, Failed, Pending)
- ✅ Search functionality by merchant or description
- ✅ Transaction detail view
- ✅ Shimmer loading effects
- ✅ Error handling and user feedback
- ✅ Session persistence across app restarts

### Future Enhancements
- 🔜 Real API integration
- 🔜 Biometric authentication
- 🔜 Transaction categories and analytics
- 🔜 Export transaction data
- 🔜 Filters
- 🔜 Dark mode support
- 🔜 Push notifications
- 🔜 Offline caching with local database

## Contributing

When contributing to this project, please follow these guidelines:

1. Follow the existing architecture patterns
2. Write unit tests for new features
3. Use meaningful commit messages
4. Update documentation for significant changes
5. Follow Flutter style guide and use `flutter_lints`

## License

This project is private and proprietary.

---

**Developed with Flutter** 💙
