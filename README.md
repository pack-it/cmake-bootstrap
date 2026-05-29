# CMake Bootstrap for Windows

This repository provides a bootstrap script for CMake on Windows.

The bootstrap script is based on the [original CMake bootstrap script](https://gitlab.kitware.com/cmake/cmake/-/blob/master/bootstrap) and written in PowerShell.
<br/>
The only dependency of the Windows bootstrap is Microsoft Visual C++ (MSVC).

## How to use

1. You first need the CMake source. You can download a source release or clone the git repository.
2. When you have the CMake source, apply the `cmake.patch` file. This ensures the source code is compatible with our bootstrap script.
3. Initialize the MSVC environment, either by using the Developer Command Prompt or by running `vcvarsall.bat` in your current terminal.
4. Run the `bootstrap.ps1` script. The bootstrap process will automatically start and give further instructions.

## License

The CMake Bootstrap for Windows repository is licensed under the BSD 3-Clause License. See [LICENSE](LICENSE) for the full license.

CMake itself, including the original bootstrap script, is licensed under the same license. See [https://cmake.org/licensing](https://cmake.org/licensing).
