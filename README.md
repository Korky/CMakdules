# CMakdules
CMake Template Repository using Module Architecture with an External Program/Application Module to serve as entry point.

## Getting Started

### Project Structure
Here's a overview of the template project structure.

```
├── cmake
│   ├── CMakdules.cmake
│   ├── ConfigVcpkg.cmake
│   └── MakeModule.cmake
├── CMakeLists.txt
├── CMakePresets.json
├── LICENSE
├── project_app
│   ├── CMakeLists.txt
│   ├── include
│   │   └── project_app.h
│   └── src
│       └── project_app.cpp
├── project_modules
│   ├── CMakeLists.txt
│   └── module_a
│       ├── CMakeLists.txt
│       ├── include
│       │   └── module_a.h
│       └── src
│           └── module_a.cpp
├── README.md
└── tests
    └── main.cpp
```
