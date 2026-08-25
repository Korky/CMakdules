# CMakdules

A lightweight CMake template demonstrating a modular architecture.
The repository contains an external program (the *app*) which serves as the entry point and a collection of C++20 modules in the `modules/` directory. The build system uses **CMake 3.30+** with presets for cross‑platform builds.

## Prerequisites

- **CMake** (v3.30 or newer) using presets to define global build settings.
- **Clang** (v14 or newer) with **lld** linker.  
  > ⚠️
  > MSVC is not supported because module support in this configuration relies on Clang’s implementation.
- On Windows, the easiest way to install Clang/Lld is via **winget**:

```bash
winget install --id LLVM.LLVM
```

After installation, ensure that `clang++` and `lld` are available on your PATH.  
On Linux you can install them through your distribution’s package manager (e.g., `sudo apt install clang lldb lld`).

## Project Structure

```
├── cmake
│   ├── Modules.cmake      # Helper functions: register_module, discover_modules
│   ├── ConfigVcpkg.cmake  # Optional helper to bootstrap vcpkg
│   └── CMakdules.cmake    # Script for project initialization and module generation
├── CMakeLists.txt          # Root CMake file – discovers modules and builds app/test
├── CMakePresets.json       # Build presets for Windows/Linux, Debug/Release
├── LICENSE
├── app                     # External program (the entry point)
│   ├── CMakeLists.txt
│   │   ├── include
│   │   │   └── app.h
│   │   └── src
│   │       └── app.cpp          # Uses the `a_module` module
├── modules                 # Collection of C++20 modules
│   └── a_module            # Example module
│       ├── CMakeLists.txt
│       ├── include
│       │   └── a_module.h   # Header (optional)
│       └── src
│           └── a_module.cppm
├── tests                   # Simple test harness
│   └── main.cpp             # Imports `a_module` and runs a function
└── README.md
```

The CMake project is named **ProjectName** (see `project("ProjectName")`).  All targets are prefixed with this name, e.g. `ProjectNameApp`, `ProjectNameTest`.

## Building

The project uses CMake presets. The following commands build the default **Debug** configuration for Windows.

```bash
# Configure
cmake --preset Windows-Debug

# Build
cmake --build --preset Windows-Debug
```

For Linux, replace `Windows` with `Linux`.  
To build in Release mode use the corresponding `-Release` preset.

## Running

After a successful build, run the application:

```bash
./staged_builds/Windows-Debug/bin/ProjectNameApp   # on Windows
# or
./staged_builds/Linux-Debug/bin/ProjectNameApp      # on Linux
```

The test executable is built as `ProjectNameTest` and can be run directly or via CTest:

```bash
ctest --preset Windows-Debug   # runs the tests
```

## Adding a New Module

Use the helper script to scaffold a new module.  From the repository root, execute:

```bash
cmake -P cmake/CMakdules.cmake new_module <modules_dir> <module_name>
```

For example, to add a module named `new_mod` inside the existing `modules` directory:

```bash
cmake -P cmake/CMakdules.cmake new_module modules new_mod
```

This creates `<modules>/<module_name>` with the appropriate CMakeLists and source file.  The module will be automatically discovered when you configure the project.

## License

Apache‑2.0 – see [LICENSE](LICENSE).
