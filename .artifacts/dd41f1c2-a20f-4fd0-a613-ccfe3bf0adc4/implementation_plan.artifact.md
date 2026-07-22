# Implementation Plan - Fix Database Compatibility (WASM & Native)

The current implementation fails to compile because it imports `dart:ffi` (via `sqlite3/sqlite3.dart`) and `sqlite3/wasm.dart` in the same file, which is not allowed in cross-platform Flutter projects. Web does not support `dart:ffi`. Additionally, the common database type needs the correct import path.

## Proposed Changes

### 1. Conditional Imports for Database Loading
To fix the "Dart library 'dart:ffi' is not available on this platform" and other compilation errors, we must separate the Web (WASM) and Mobile (Native) database loading logic into separate files using conditional imports.

#### [MODIFY] [database_factory_interface.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/services/database_factory_interface.dart)
- Update import to `package:sqlite3/common.dart` to correctly access `CommonDatabase`.

#### [MODIFY] [database_factory_mobile.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/services/database_factory_mobile.dart)
- Implements the interface for Mobile platforms using `sqlite3.dart` (FFI).
- Handles copying the asset to the local file system.
- Uses `CommonDatabase` from `common.dart`.

#### [MODIFY] [database_factory_web.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/services/database_factory_web.dart)
- Implements the interface for Web using `wasm.dart`.
- Loads `sqlite3.wasm` and reads the asset into an in-memory or virtual file system.
- Uses `CommonDatabase` from `common.dart`.

#### [MODIFY] [database_factory.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/services/database_factory.dart)
- Uses `conditional imports` to pick the correct implementation at compile time.
- Returns `CommonDatabase`.

### 2. Service Update

#### [MODIFY] [address_service.dart](file:///Users/oldrookie_dx/AndroidStudioProjects/katura_system/lib/services/address_service.dart)
- Change all `Database` types to `CommonDatabase` and use the correct import `package:sqlite3/common.dart`.
- Ensure the initialization logic calls the unified factory.

## Verification Plan

### Manual Verification
1. **Web (Chrome)**: Build and run. Verify that `dart:ffi` errors are gone and address search works.
2. **Android (Pixel Tablet)**: Build and run. Verify that the app starts and searches correctly.

## User Review Required

> [!CAUTION]
> Webとモバイルでライブラリの仕組みが根本的に異なる（WebはWASM、モバイルはFFI）ため、一つのファイルに両方のインポートを書くとコンパイルエラーになります。
> また、`CommonDatabase` 型を正しく認識させるためにインポートパスを `package:sqlite3/common.dart` に修正します。
