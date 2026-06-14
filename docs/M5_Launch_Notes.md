# M5 First Playable — Launch Notes (Manual Playtest)

Purpose: get one **normal, non-web, locally playable** build running for the
Human Product Owner playtest. Preferred target is **Windows desktop**.

---

## Windows desktop (preferred target)

### Command

```
flutter run -d windows
```

### Known blocker (now fixed in-repo)

Recent CMake (>= 4.0) removed compatibility with `cmake_minimum_required`
below 3.5. The Firebase C++ SDK that `firebase_core` / `firebase_analytics`
download for Windows still declares an older minimum, so configuration failed
with:

```
Compatibility with CMake < 3.5 has been removed from CMake
```

(in `build/windows/x64/extracted/firebase_cpp_sdk_windows/CMakeLists.txt`).

### Fix applied

`windows/CMakeLists.txt` now sets a policy-version floor before the plugin
subprojects are added:

```cmake
if(NOT DEFINED CMAKE_POLICY_VERSION_MINIMUM)
  set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
endif()
```

The Firebase SDK is pulled into the **same** CMake tree via
`add_subdirectory(...)` (see `firebase_core/windows/CMakeLists.txt`), so this
parent-scope variable propagates to it and lets the build configure. This is a
**build-time compatibility shim only** — it does not change the app,
simulation rules, persistence semantics, or analytics behavior.

### If a clean build still errors

If you build from a fully clean tree on a CMake version that ignores the
project-level variable, pass the floor explicitly before running:

PowerShell:
```powershell
$env:CMAKE_POLICY_VERSION_MINIMUM = "3.5"
flutter clean
flutter run -d windows
```

cmd:
```cmd
set CMAKE_POLICY_VERSION_MINIMUM=3.5
flutter clean
flutter run -d windows
```

### Notes

- The app never calls `Firebase.initializeApp()`; analytics runs through
  `SafeAnalyticsService(NoopAnalyticsService())`, so no Firebase configuration
  (`google-services` / `firebase_options`) is required to launch and play.
- Isar remains the production persistence path on desktop (native libs ship via
  `isar_community_flutter_libs`).

---

## Other non-web local targets

Any normal desktop target is acceptable for the playtest (`flutter run -d
windows` is preferred). macOS uses CocoaPods rather than the Firebase Windows
CMake path and is unaffected by the above blocker. Linux desktop also avoids
the blocker (Firebase has no Linux desktop implementation, so it is excluded
from the build) but requires the usual Linux desktop toolchain
(`libgtk-3-dev`, `ninja-build`, `clang`).

---

## Web (Chrome) — not supported for First Playable

```
flutter run -d chrome
```

fails compiling Isar generated code:

```
simulation_save_record.g.dart: integer literal ... can't be represented
exactly in JavaScript
```

The Isar collection schema id is a 64-bit integer that cannot be represented
exactly in JavaScript. Supporting web would require dropping or replacing the
Isar production persistence path on web — an architecture compromise that is
**out of scope** for the M5 launch unblocker (web is deprioritized by the
task). Use a desktop target for the playtest.
