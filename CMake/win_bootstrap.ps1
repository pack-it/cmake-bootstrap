# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst or https://cmake.org/licensing for details.

function die {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        $Message
    )

    Write-Error ($Message -join ' ')
    exit 1
}

# Compile flag extraction function.
# cmake_extract_standard_flags()
# {
#   id="${1:-*}"
#   lang="${2}"
#   ver="${3}"
#   sed -n "s/ *set *( *CMAKE_${lang}${ver}_EXTENSION_COMPILE_OPTION *\"\{0,1\}\([^\")]*\).*/\1/p" \
#     "${cmake_source_dir}/Modules/Compiler/"${id}-${lang}.cmake \
#     2>/dev/null | tr ';' ' '
#   # Clang's CXX compiler flags are in the common module.
#   sed -n "s/ *set *( *CMAKE_\\\${lang}${ver}_EXTENSION_COMPILE_OPTION *\"\{0,1\}\([^\")]*\).*/\1/p" \
#     "${cmake_source_dir}/Modules/Compiler/Clang.cmake" \
#     2>/dev/null | tr ';' ' '
# }

# Version number extraction function.
# cmake_version_component()
# {
#   sed -n "
# /^set(CMake_VERSION_${1}/ {s/set(CMake_VERSION_${1} *\([0-9]*\)).*/\1/;p;}
# " "${cmake_source_dir}/Source/CMakeVersion.cmake"
# }

function cmake_version_component {
    param (
        $component
    )

    (
        Select-String -Path "${cmake_source_dir}\Source\CMakeVersion.cmake" -Pattern "^set\(CMake_VERSION_${component}"
    ).Line -replace ".* ([0-9]+)\).*",'$1'
}

# Install destination extraction function.
function cmake_install_dest_default {
    param (
        $dir,
        $keyword
    )

    $pattern = "^\s*set\(CMAKE_${dir}_DIR_DEFAULT\s*""([^""]*)"".*$"
    (
        Select-String -Path "${cmake_source_dir}\Source\CMakeInstallDestinations.cmake" -Pattern "^\s*set\(CMAKE_${dir}_DIR_DEFAULT.*\)\s*#\s*${keyword}\s*$"
    ).Line -replace $pattern,'$1' -replace "\$\{CMake_VERSION_MAJOR\}", "${cmake_version_major}" -replace "\$\{CMake_VERSION_MINOR\}", "${cmake_version_minor}" -replace "\$\{CMake_VERSION_PATCH\}", "${cmake_version_patch}"
}

# NOTE upper method removed, internal methods available

# Detect system and directory information.
# CHANGE: uname was used here before, this variable is not really used though
$cmake_system="Windows"
$cmake_source_dir = Split-Path -Parent $PSCommandPath
$cmake_binary_dir = (Get-Location).Path

# Load version information.
$cmake_version_major = cmake_version_component MAJOR
$cmake_version_minor = cmake_version_component MINOR
$cmake_version_patch = cmake_version_component PATCH
$cmake_version = "${cmake_version_major}.${cmake_version_minor}.${cmake_version_patch}"
$cmake_version_rc= cmake_version_component RC
if (-not [string]::IsNullOrEmpty($cmake_version_rc)) {
    $cmake_version="${cmake_version}-rc${cmake_version_rc}"
}

# CMake copyright
$cmake_copyright = (Select-String -Path "${cmake_source_dir}\LICENSE.rst" -Pattern "^Copyright .* Kitware").Line -replace "`Contributors.*`_","Contributors"

$cmake_bin_dir_keyword="OTHER"
$cmake_data_dir_keyword="OTHER"
$cmake_doc_dir_keyword="OTHER"
$cmake_man_dir_keyword="OTHER"
$cmake_xdgdata_dir_keyword="OTHER"
$cmake_bin_dir=""
$cmake_data_dir=""
$cmake_doc_dir=""
$cmake_man_dir=""
$cmake_xdgdata_dir=""
$cmake_init_file=""
$cmake_bootstrap_system_libs=""
$cmake_bootstrap_qt_gui=""
$cmake_bootstrap_qt_qmake=""
$cmake_bootstrap_debugger=""
$cmake_sphinx_info=""
$cmake_sphinx_man=""
$cmake_sphinx_html=""
$cmake_sphinx_qthelp=""
$cmake_sphinx_latexpdf=""
$cmake_sphinx_build=""
$cmake_sphinx_flags=""

# OBSOLETE: Determine whether this is a MinGW environment.

# Choose the generator to use for bootstrapping.
# Bootstrapping from an MSYS prompt.
# CHANGE_COMPILER
$cmake_bootstrap_generator="MSYS Makefiles"

# Set tools and extensions for this platform.
# CHECK .tmp for command line/windows
$_tmp=".tmp"
$_cmk=".cmk"
# NOTE _diff removed, because internal methods available

# Construct bootstrap directory name.
$cmake_bootstrap_dir="${cmake_binary_dir}\Bootstrap${_cmk}"

# Helper function to fix windows paths.
# cmake_fix_slashes() {
#     cmd //c echo "$(echo "$1" | sed 's/\\/\//g')" | sed 's/^"//;s/" *$//'
# }

# Choose the default install prefix.
if (-not [string]::IsNullOrEmpty($PROGRAMFILES)) {
    $cmake_default_prefix = "${PROGRAMFILES}\CMake"
} elseif (-not [string]::IsNullOrEmpty($ProgramFiles)) {
    $cmake_default_prefix = "${ProgramFiles}\CMake"`
} elseif (-not [string]::IsNullOrEmpty($SYSTEMDRIVE)) {
    $cmake_default_prefix = "${SYSTEMDRIVE}\Program Files\CMake"
} elseif (-not [string]::IsNullOrEmpty($SystemDrive)) {
    $cmake_default_prefix = "${SystemDrive}\Program Files\CMake"
} else {
    $cmake_default_prefix="C:\Program Files\CMake"
}

# Lookup default install destinations.
$cmake_bin_dir_default = cmake_install_dest_default BIN ${cmake_bin_dir_keyword}
$cmake_data_dir_default = cmake_install_dest_default DATA ${cmake_data_dir_keyword}
$cmake_doc_dir_default = cmake_install_dest_default DOC ${cmake_doc_dir_keyword}
$cmake_man_dir_default = cmake_install_dest_default MAN ${cmake_man_dir_keyword}
$cmake_xdgdata_dir_default = cmake_install_dest_default XDGDATA ${cmake_xdgdata_dir_keyword}

$CMAKE_KNOWN_C_COMPILERS = @("cc", "gcc", "clang", "xlc", "icx", "tcc")
$CMAKE_KNOWN_CXX_COMPILERS = @("aCC", "xlC", "CC", "g++", "clang++", "c++", "icpx")
$CMAKE_KNOWN_MAKE_PROCESSORS = @("gmake", "make", "smake")
$CMAKE_KNOWN_NINJA_PROCESSORS = @("ninja-build", "ninja", "samu")

$CMAKE_PROBLEMATIC_FILES = @(
    "CMakeCache.txt",
    "CMakeSystem.cmake",
    "CMakeCCompiler.cmake",
    "CMakeCXXCompiler.cmake",
    "*/CMakeSystem.cmake",
    "*/CMakeCCompiler.cmake",
    "*/CMakeCXXCompiler.cmake",
    "Source/cmConfigure.h",
    "Source/CTest/Curl/config.h",
    "Utilities/cmThirdParty.h",
    "Utilities/cmcurl/lib/curl_config.h",
    "Utilities/cmlibarchive/config.h",
    "Utilities/cmliblzma/config.h",
    "Utilities/cmnghttp2/config.h"
)

$CMAKE_UNUSED_SOURCES = @(
  "cmGlobalXCodeGenerator",
  "cmLocalXCodeGenerator",
  "cmXCodeObject",
  "cmXCode21Object",
  "cmSourceGroup"
)

$CMAKE_CXX_SOURCES = @(
  "cmAddCompileDefinitionsCommand",
  "cmAddCustomCommandCommand",
  "cmAddCustomTargetCommand",
  "cmAddDefinitionsCommand",
  "cmAddDependenciesCommand",
  "cmAddExecutableCommand",
  "cmAddLibraryCommand",
  "cmAddSubDirectoryCommand",
  "cmAddTestCommand",
  "cmArgumentParser",
  "cmBinUtilsLinker",
  "cmBinUtilsLinuxELFGetRuntimeDependenciesTool",
  "cmBinUtilsLinuxELFLinker",
  "cmBinUtilsLinuxELFObjdumpGetRuntimeDependenciesTool",
  "cmBinUtilsMacOSMachOGetRuntimeDependenciesTool",
  "cmBinUtilsMacOSMachOLinker",
  "cmBinUtilsMacOSMachOOToolGetRuntimeDependenciesTool",
  "cmBinUtilsWindowsPEGetRuntimeDependenciesTool",
  "cmBinUtilsWindowsPEDumpbinGetRuntimeDependenciesTool",
  "cmBinUtilsWindowsPELinker",
  "cmBinUtilsWindowsPEObjdumpGetRuntimeDependenciesTool",
  "cmBlockCommand",
  "cmBreakCommand",
  "cmBuildCommand",
  "cmBuildDatabase",
  "cmCMakeLanguageCommand",
  "cmCMakeMinimumRequired",
  "cmList",
  "cmCMakeDiagnosticCommand",
  "cmCMakePath",
  "cmCMakePathCommand",
  "cmCMakePolicyCommand",
  "cmCMakeString",
  "cmCPackPropertiesGenerator",
  "cmCacheManager",
  "cmCommands",
  "cmCommonTargetGenerator",
  "cmComputeComponentGraph",
  "cmComputeLinkDepends",
  "cmComputeLinkInformation",
  "cmComputeTargetDepends",
  "cmConditionEvaluator",
  "cmConfigureFileCommand",
  "cmContinueCommand",
  "cmCoreTryCompile",
  "cmCreateTestSourceList",
  "cmCryptoHash",
  "cmCustomCommand",
  "cmCustomCommandGenerator",
  "cmCustomCommandLines",
  "cmCxxModuleMapper",
  "cmCxxModuleUsageEffects",
  "cmDefinePropertyCommand",
  "cmDefinitions",
  "cmDiagnostics",
  "cmDiscoverTestsCommand",
  "cmDocumentationFormatter",
  "cmELF",
  "cmEnableLanguageCommand",
  "cmEnableTestingCommand",
  "cmEnvironment",
  "cmEvaluatedTargetProperty",
  "cmExecProgramCommand",
  "cmExecuteProcessCommand",
  "cmExpandedCommandArgument",
  "cmExperimental",
  "cmExportBuildCMakeConfigGenerator",
  "cmExportBuildFileGenerator",
  "cmExportCMakeConfigGenerator",
  "cmExportFileGenerator",
  "cmExportInstallCMakeConfigGenerator",
  "cmExportInstallFileGenerator",
  "cmExportSet",
  "cmExportTryCompileFileGenerator",
  "cmExprParserHelper",
  "cmExternalMakefileProjectGenerator",
  "cmFileCommand",
  "cmFileCommand_ReadMacho",
  "cmFileCopier",
  "cmFileInstaller",
  "cmFileSet",
  "cmFileSetMetadata",
  "cmFileTime",
  "cmFileTimeCache",
  "cmFileTimes",
  "cmFindBase",
  "cmFindCommon",
  "cmFindFileCommand",
  "cmFindLibraryCommand",
  "cmFindPackageCommand",
  "cmFindPackageStack",
  "cmFindPathCommand",
  "cmFindProgramCommand",
  "cmForEachCommand",
  "cmFunctionBlocker",
  "cmFunctionCommand",
  "cmFSPermissions",
  "cmGeneratedFileStream",
  "cmGenExContext",
  "cmGenExEvaluation",
  "cmGeneratorExpression",
  "cmGeneratorExpressionDAGChecker",
  "cmGeneratorExpressionEvaluationFile",
  "cmGeneratorExpressionEvaluator",
  "cmGeneratorExpressionLexer",
  "cmGeneratorExpressionNode",
  "cmGeneratorExpressionParser",
  "cmGeneratorFileSet",
  "cmGeneratorFileSets",
  "cmGeneratorTarget",
  "cmGeneratorTarget_CompatibleInterface",
  "cmGeneratorTarget_HeaderSetVerification",
  "cmGeneratorTarget_IncludeDirectories",
  "cmGeneratorTarget_Link",
  "cmGeneratorTarget_LinkDirectories",
  "cmGeneratorTarget_Options",
  "cmGeneratorTarget_Sources",
  "cmGeneratorTarget_TransitiveProperty",
  "cmGetCMakePropertyCommand",
  "cmGetDirectoryPropertyCommand",
  "cmGetFilenameComponentCommand",
  "cmGetPipes",
  "cmGetPropertyCommand",
  "cmGetSourceFilePropertyCommand",
  "cmGetTargetPropertyCommand",
  "cmGetTestPropertyCommand",
  "cmGlobalCommonGenerator",
  "cmGlobalGenerator",
  "cmGlobVerificationManager",
  "cmHexFileConverter",
  "cmIfCommand",
  "cmImportedCxxModuleInfo",
  "cmIncludeCommand",
  "cmIncludeGuardCommand",
  "cmIncludeDirectoryCommand",
  "cmIncludeRegularExpressionCommand",
  "cmInstallCMakeConfigExportGenerator",
  "cmInstallCommand",
  "cmInstallCommandArguments",
  "cmInstallCxxModuleBmiGenerator",
  "cmInstallDirectoryGenerator",
  "cmInstallExportGenerator",
  "cmInstallFileSetGenerator",
  "cmInstallFilesCommand",
  "cmInstallFilesGenerator",
  "cmInstallGenerator",
  "cmInstallGetRuntimeDependenciesGenerator",
  "cmInstallImportedRuntimeArtifactsGenerator",
  "cmInstallDirs",
  "cmInstallRuntimeDependencySet",
  "cmInstallRuntimeDependencySetGenerator",
  "cmInstallScriptGenerator",
  "cmInstallSubdirectoryGenerator",
  "cmInstallTargetGenerator",
  "cmInstallTargetsCommand",
  "cmInstalledFile",
  "cmJSONHelpers",
  "cmJSONState",
  "cmLDConfigLDConfigTool",
  "cmLDConfigTool",
  "cmLinkDirectoriesCommand",
  "cmLinkItem",
  "cmLinkItemGraphVisitor",
  "cmLinkLineComputer",
  "cmLinkLineDeviceComputer",
  "cmListCommand",
  "cmListFileCache",
  "cmLocalCommonGenerator",
  "cmLocalGenerator",
  "cmMSVC60LinkLineComputer",
  "cmMacroCommand",
  "cmMakeDirectoryCommand",
  "cmMakefile",
  "cmMarkAsAdvancedCommand",
  "cmMathCommand",
  "cmMessageCommand",
  "cmMessenger",
  "cmNewLineStyle",
  "cmOSXBundleGenerator",
  "cmOptionCommand",
  "cmOrderDirectories",
  "cmObjectLocation",
  "cmOutputConverter",
  "cmParseArgumentsCommand",
  "cmPathLabel",
  "cmPathResolver",
  "cmPolicies",
  "cmProcessOutput",
  "cmProjectCommand",
  "cmValue",
  "cmPropertyDefinition",
  "cmPropertyMap",
  "cmGccDepfileLexerHelper",
  "cmGccDepfileReader",
  "cmReturnCommand",
  "cmPackageInfoReader",
  "cmPlaceholderExpander",
  "cmPlistParser",
  "cmRulePlaceholderExpander",
  "cmRuntimeDependencyArchive",
  "cmScriptGenerator",
  "cmSearchPath",
  "cmSeparateArgumentsCommand",
  "cmSetCommand",
  "cmSetDirectoryPropertiesCommand",
  "cmSetPropertyCommand",
  "cmSetSourceFilesPropertiesCommand",
  "cmSetTargetPropertiesCommand",
  "cmSetTestsPropertiesCommand",
  "cmSiteNameCommand",
  "cmSourceFile",
  "cmSourceFileLocation",
  "cmStandardLevelResolver",
  "cmState",
  "cmStateDirectory",
  "cmStateSnapshot",
  "cmStdIoConsole",
  "cmStdIoInit",
  "cmStdIoStream",
  "cmStdIoTerminal",
  "cmString",
  "cmStringAlgorithms",
  "cmStringReplaceHelper",
  "cmStringCommand",
  "cmSubcommandTable",
  "cmSubdirCommand",
  "cmSystemTools",
  "cmTarget",
  "cmTargetCompileDefinitionsCommand",
  "cmTargetCompileFeaturesCommand",
  "cmTargetCompileOptionsCommand",
  "cmTargetIncludeDirectoriesCommand",
  "cmTargetLinkLibrariesCommand",
  "cmTargetLinkOptionsCommand",
  "cmTargetPrecompileHeadersCommand",
  "cmTargetPropCommandBase",
  "cmTargetPropertyComputer",
  "cmTargetPropertyEntry",
  "cmTargetSourcesCommand",
  "cmTargetTraceDependencies",
  "cmTest",
  "cmTestGenerator",
  "cmTimestamp",
  "cmTransformDepfile",
  "cmTryCompileCommand",
  "cmTryRunCommand",
  "cmUnsetCommand",
  "cmUVHandlePtr",
  "cmUVProcessChain",
  "cmVersion",
  "cmWhileCommand",
  "cmWindowsRegistry",
  "cmWorkingDirectory",
  "cmXcFramework",
  "cmake",
  "cmakemain",
  "cmcmd",
  "cm_fileno",
  "cmGlobalMSYSMakefileGenerator",
  "cmGlobalMinGWMakefileGenerator",
  "cmVSSetupHelper"
)

$CMAKE_C_SOURCES = @(
  "cm_utf8"
)

$CMAKE_STD_CXX_HEADERS = @(
  "filesystem",
  "memory",
  "optional",
  "shared_mutex",
  "string_view",
  "utility"
)

$CMAKE_STD_CXX_SOURCES = @(
  "fs_path",
  "string_view"
)

$LexerParser_CXX_SOURCES = @(
  "cmExprLexer",
  "cmExprParser",
  "cmGccDepfileLexer"
)

$LexerParser_C_SOURCES = @(
  "cmListFileLexer"
)

$KWSYS_C_SOURCES = @(
    "EncodingC",
    "ProcessWin32",
    "String",
    "System"
)

$KWSYS_CXX_SOURCES = @(
  "Directory",
  "EncodingCXX",
  "FStream",
  "Glob",
  "RegularExpression",
  "Status",
  "SystemTools"
)

$KWSYS_FILES = @(
  "Directory.hxx",
  "Encoding.h",
  "Encoding.hxx",
  "FStream.hxx",
  "Glob.hxx",
  "Process.h",
  "RegularExpression.hxx",
  "Status.hxx",
  "String.h",
  "System.h",
  "SystemTools.hxx"
)

$LIBRHASH_C_SOURCES = @(
  "librhash/algorithms.c",
  "librhash/byte_order.c",
  "librhash/hex.c",
  "librhash/md5.c",
  "librhash/rhash.c",
  "librhash/sha1.c",
  "librhash/sha256.c",
  "librhash/sha3.c",
  "librhash/sha512.c",
  "librhash/util.c"
)

$JSONCPP_CXX_SOURCES = @(
  "src/lib_json/json_reader.cpp",
  "src/lib_json/json_value.cpp",
  "src/lib_json/json_writer.cpp"
)

$LIBUV_C_SOURCES = @(
    "src/fs-poll.c",
    "src/idna.c",
    "src/inet.c",
    "src/threadpool.c",
    "src/strscpy.c",
    "src/strtok.c",
    "src/timer.c",
    "src/uv-common.c",
    "src/win/async.c",
    "src/win/core.c",
    "src/win/detect-wakeup.c",
    "src/win/dl.c",
    "src/win/error.c",
    "src/win/fs-event.c",
    "src/win/fs.c",
    "src/win/getaddrinfo.c",
    "src/win/getnameinfo.c",
    "src/win/handle.c",
    "src/win/loop-watcher.c",
    "src/win/pipe.c",
    "src/win/poll.c",
    "src/win/process-stdio.c",
    "src/win/process.c",
    "src/win/signal.c",
    "src/win/stream.c",
    "src/win/tcp.c",
    "src/win/thread.c",
    "src/win/tty.c",
    "src/win/udp.c",
    "src/win/util.c",
    "src/win/winapi.c",
    "src/win/winsock.c"
)

# Display CMake bootstrap usage
function cmake_usage {
    $script_name = $MyInvocation.MyCommand.Name
    Write-Output "
Usage: $script_name [<options>...] [-- <cmake-options>...]
Options: [defaults in brackets after descriptions]
Configuration:
  --help                  print this message
  --version               only print version information
  --verbose               display more information
  --parallel=n            bootstrap cmake in parallel, where n is
                          number of nodes [1]
  --generator=<generator> generator to use (MSYS Makefiles, Unix Makefiles,
                          or Ninja)
  --enable-ccache         Enable ccache when building cmake
  --init=FILE             load FILE as script to populate cache
  --system-libs           use all system-installed third-party libraries
                          (for use only by package maintainers)
  --no-system-libs        use all cmake-provided third-party libraries
                          (default)
  --system-cppdap         use system-installed cppdap library
  --no-system-cppdap      use cmake-provided cppdap library (default)
  --system-curl           use system-installed curl library (default on macOS)
  --no-system-curl        use cmake-provided curl library (default elsewhere)
  --system-expat          use system-installed expat library
  --no-system-expat       use cmake-provided expat library (default)
  --system-jsoncpp        use system-installed jsoncpp library
  --no-system-jsoncpp     use cmake-provided jsoncpp library (default)
  --system-zlib           use system-installed zlib library
  --no-system-zlib        use cmake-provided zlib library (default)
  --system-bzip2          use system-installed bzip2 library
  --no-system-bzip2       use cmake-provided bzip2 library (default)
  --system-liblzma        use system-installed liblzma library
  --no-system-liblzma     use cmake-provided liblzma library (default)
  --system-nghttp2        use system-installed nghttp2 library
  --no-system-nghttp2     use cmake-provided nghttp2 library (default)
  --system-zstd           use system-installed zstd library
  --no-system-zstd        use cmake-provided zstd library (default)
  --system-libarchive     use system-installed libarchive library
  --no-system-libarchive  use cmake-provided libarchive library (default)
  --system-librhash       use system-installed librhash library
  --no-system-librhash    use cmake-provided librhash library (default)
  --system-libuv          use system-installed libuv library
  --no-system-libuv       use cmake-provided libuv library (default)

  --bootstrap-system-libuv use system-installed libuv library for bootstrap
  --bootstrap-system-jsoncpp use system-installed jsoncpp library for bootstrap
  --bootstrap-system-librhash use system-installed librhash library for bootstrap

  --qt-gui                build the Qt-based GUI (requires Qt >= 4.2)
  --no-qt-gui             do not build the Qt-based GUI (default)
  --qt-qmake=<qmake>      use <qmake> as the qmake executable to find Qt

  --debugger              enable debugger support (default if supported)
  --no-debugger           disable debugger support

  --sphinx-info           build Info manual with Sphinx
  --sphinx-man            build man pages with Sphinx
  --sphinx-html           build html help with Sphinx
  --sphinx-qthelp         build qch help with Sphinx
  --sphinx-latexpdf       build PDF with Sphinx using LaTeX
  --sphinx-build=<sb>     use <sb> as the sphinx-build executable
  --sphinx-flags=<flags>  pass <flags> to sphinx-build executable

Directory and file names:
  --prefix=PREFIX         install files in tree rooted at PREFIX
                          [${cmake_default_prefix}]
  --bindir=DIR            install binaries in PREFIX/DIR
                          [${cmake_bin_dir_default}]
  --datadir=DIR           install data files in PREFIX/DIR
                          [${cmake_data_dir_default}]
  --docdir=DIR            install documentation files in PREFIX/DIR
                          [${cmake_doc_dir_default}]
  --mandir=DIR            install man pages files in PREFIX/DIR/manN
                          [${cmake_man_dir_default}]
  --xdgdatadir=DIR        install XDG specific files in PREFIX/DIR
                          [${cmake_xdgdata_dir_default}]
"
    exit 10
}

# Display CMake bootstrap usage
function cmake_version_display {
    Write-Output "CMake ${cmake_version}, ${cmake_copyright}"
}

# Display CMake bootstrap error, display the log file and exit
function cmake_error {
    param (
        [Parameter(Position = 0)]
        $res,

        [Parameter(ValueFromRemainingArguments = $true)]
        $Messages
    )

    Write-Output "---------------------------------------------"
    Write-Output "Error when bootstrapping CMake:"
    Write-Output "$Messages"
    Write-Output "---------------------------------------------"
    if (Test-Path "cmake_bootstrap.log") {
        Write-Output "Log of errors: `pwd`/cmake_bootstrap.log"
        Write-Output "---------------------------------------------"
    }

    exit $res
}

# Update OUTFILE with TMPFILE if the files are different.
# TMPFILE is removed in this function. 
function cmake_generate_file_tmp {
    param (
        $OUTFILE,
        $TMPFILE
    )

    if ((Test-Path $outFile) -and (-not (Compare-Object (Get-Content $tmpFile) (Get-Content $outFile)))) {
        Remove-Item $tmpFile -Force
    } else {
        Move-Item $tmpFile $outFile -Force
    }
}

# CHECK should the extension be .tmp on native windows?
function cmake_generate_file {
    param (
        $OUTFILE,
        $CONTENT
    )

    Write-Output "$CONTENT" > "$OUTFILE.tmp"
    cmake_generate_file_tmp "$OUTFILE" "$OUTFILE.tmp"
}

