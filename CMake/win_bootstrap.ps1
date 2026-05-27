# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst or https://cmake.org/licensing for details.
param(
    [Alias("prefix")]
    [string]$cmake_prefix_dir,

    [Alias("parallel")]
    [string]$cmake_parallel_make,

    [Alias("generator")]
    [string]$cmake_bootstrap_generator,

    [Alias("bindir")]
    [string]$cmake_bin_dir,

    [Alias("datadir")]
    [string]$cmake_data_dir,

    [Alias("docdir")]
    [string]$cmake_doc_dir,

    [Alias("mandir")]
    [string]$cmake_man_dir,

    [Alias("xdgdatadir")]
    [string]$cmake_xdgdata_dir,

    [Alias("init")]
    [string]$cmake_init_file,

    [Alias("system-libs")]
    [switch]$system_libs,

    [Alias("no-system-libs")]
    [switch]$no_system_libs,

    # System
    [Alias("system-bzip2")]
    [switch]$system_bzip2,

    [Alias("system-cppdap")]
    [switch]$system_cppdap,

    [Alias("system-curl")]
    [switch]$system_curl,

    [Alias("system-expat")]
    [switch]$system_expat,

    [Alias("system-jsoncpp")]
    [switch]$system_jsoncpp,

    [Alias("system-libarchive")]
    [switch]$system_libarchive,

    [Alias("system-librhash")]
    [switch]$system_librhash,

    [Alias("system-zlib")]
    [switch]$system_zlib,

    [Alias("system-liblzma")]
    [switch]$system_liblzma,

    [Alias("system-nghttp2")]
    [switch]$system_nghttp2,

    [Alias("system-zstd")]
    [switch]$system_zstd,

    [Alias("system-libuv")]
    [switch]$system_libuv,

    # No system
    [Alias("no-system-bzip2")]
    [switch]$no_system_bzip2,

    [Alias("no-system-cppdap")]
    [switch]$no_system_cppdap,

    [Alias("no-system-curl")]
    [switch]$no_system_curl,

    [Alias("no-system-expat")]
    [switch]$no_system_expat,

    [Alias("no-system-jsoncpp")]
    [switch]$no_system_jsoncpp,

    [Alias("no-system-libarchive")]
    [switch]$no_system_libarchive,

    [Alias("no-system-librhash")]
    [switch]$no_system_librhash,

    [Alias("no-system-zlib")]
    [switch]$no_system_zlib,

    [Alias("no-system-liblzma")]
    [switch]$no_system_liblzma,

    [Alias("no-system-nghttp2")]
    [switch]$no_system_nghttp2,

    [Alias("no-system-zstd")]
    [switch]$no_system_zstd,

    [Alias("no-system-libuv")]
    [switch]$no_system_libuv,

    # Other
    [Alias("bootstrap-system-libuv")]
    [switch]$bootstrap_system_libuv,

    [Alias("bootstrap-system-jsoncpp")]
    [switch]$bootstrap_system_jsoncpp,

    [Alias("bootstrap-system-librhash")]
    [switch]$bootstrap_system_librhash,

    [Alias("qt-gui")]
    [switch]$cmake_bootstrap_qt_gui,

    [Alias("no-qt-gui")]
    [switch]$no_qt_gui,

    [Alias("qt-qmake")]
    [string]$cmake_bootstrap_qt_qmake,

    [Alias("debugger")]
    [switch]$cmake_bootstrap_debugger,

    [Alias("no-debugger")]
    [switch]$no_debugger,

    [Alias("sphinx-info")]
    [switch]$cmake_sphinx_info,

    [Alias("sphinx-man")]
    [switch]$cmake_sphinx_man,

    [Alias("sphinx-html")]
    [switch]$cmake_sphinx_html,

    [Alias("sphinx-qthelp")]
    [switch]$cmake_sphinx_qthelp,

    [Alias("sphinx-latexpdf")]
    [switch]$cmake_sphinx_latexpdf,

    [Alias("sphinx-build")]
    [string]$cmake_sphinx_build,

    [Alias("sphinx-flags")]
    [string]$cmake_sphinx_flags,

    [Alias("help")]
    [switch]$cmake_help,

    [Alias("version")]
    [switch]$show_version,

    [Alias("verbose")]
    [switch]$cmake_verbose,

    [Alias("enable-ccache")]
    [switch]$cmake_ccache_enabled,

    [string]$CC,
    [string]$CXX,
    [string]$CFLAGS,
    [string]$CXXFLAGS,
    [string]$LDFLAGS
)

# Set false booleans
if ($no_qt_gui) {
    $cmake_bootstrap_qt_gui = $false
}

if ($no_debugger) {
    $cmake_bootstrap_debugger = $false
}

# Set CMake bootstrap system libs
$cmake_bootstrap_system_libs = @()
if ($system_libs) {
    $cmake_bootstrap_system_libs += "-DCMAKE_USE_SYSTEM_LIBRARIES=1"
}

if ($no_system_libs) {
    $cmake_bootstrap_system_libs += "-DCMAKE_USE_SYSTEM_LIBRARIES=0"
}

# Do mapping from system flags and add them to the cmake_bootstrap_system_libs
$system_map = @{
    system_bzip2      = "bzip2"
    system_cppdap     = "cppdap"
    system_curl       = "curl"
    system_expat      = "expat"
    system_jsoncpp    = "jsoncpp"
    system_libarchive = "libarchive"
    system_librhash   = "librhash"
    system_zlib       = "zlib"
    system_liblzma    = "liblzma"
    system_nghttp2    = "nghttp2"
    system_zstd       = "zstd"
    system_libuv      = "libuv"
}

$no_system_map = @{
    no_system_bzip2      = "bzip2"
    no_system_cppdap     = "cppdap"
    no_system_curl       = "curl"
    no_system_expat      = "expat"
    no_system_jsoncpp    = "jsoncpp"
    no_system_libarchive = "libarchive"
    no_system_librhash   = "librhash"
    no_system_zlib       = "zlib"
    no_system_liblzma    = "liblzma"
    no_system_nghttp2    = "nghttp2"
    no_system_zstd       = "zstd"
    no_system_libuv      = "libuv"
}

foreach ($key in $system_map.Keys) {
    if (Get-Variable $key -ValueOnly -ErrorAction SilentlyContinue) {
        $cmake_bootstrap_system_libs += "-DCMAKE_USE_SYSTEM_LIBRARY_$($system_map[$key].ToUpper())=1"
    }
}

foreach ($key in $no_system_map.Keys) {
    if (Get-Variable $key -ValueOnly -ErrorAction SilentlyContinue) {
        $cmake_bootstrap_system_libs += "-DCMAKE_USE_SYSTEM_LIBRARY_$($no_system_map[$key].ToUpper())=0"
    }
}

# Choose the default install prefix.
if (-not [string]::IsNullOrEmpty($PROGRAMFILES)) {
    $cmake_default_prefix = "${PROGRAMFILES}\CMake"
}
elseif (-not [string]::IsNullOrEmpty($ProgramFiles)) {
    $cmake_default_prefix = "${ProgramFiles}\CMake"`

}
elseif (-not [string]::IsNullOrEmpty($SYSTEMDRIVE)) {
    $cmake_default_prefix = "${SYSTEMDRIVE}\Program Files\CMake"
}
elseif (-not [string]::IsNullOrEmpty($SystemDrive)) {
    $cmake_default_prefix = "${SystemDrive}\Program Files\CMake"
}
else {
    $cmake_default_prefix = "C:\Program Files\CMake"
}

# Set the cmake_prefix_dir to the default, if not yet set
if ("" -eq $cmake_prefix_dir) {
    $cmake_prefix_dir = "${cmake_default_prefix}"
}

# Choose the generator to use for bootstrapping.
# Bootstrapping from an MSYS prompt.
# CHANGE_COMPILER
if ("" -eq $cmake_bootstrap_generator) {
    $cmake_bootstrap_generator = "MSYS Makefiles"
}

function cmake_version_component {
    param (
        $component
    )

    (
        Select-String -Path "${cmake_source_dir}\Source\CMakeVersion.cmake" -Pattern "^set\(CMake_VERSION_${component}"
    ).Line -replace ".* ([0-9]+)\).*", '$1'
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
    ).Line -replace $pattern, '$1' -replace "\$\{CMake_VERSION_MAJOR\}", "${cmake_version_major}" -replace "\$\{CMake_VERSION_MINOR\}", "${cmake_version_minor}" -replace "\$\{CMake_VERSION_PATCH\}", "${cmake_version_patch}"
}

# REMOVED upper method, internal methods available

# Detect system and directory information.
# CHANGE: uname was used here before, this variable is not really used though
$cmake_system = "Windows"
$cmake_source_dir = Split-Path -Parent $PSCommandPath
$cmake_binary_dir = (Get-Location).Path

# Load version information.
$cmake_version_major = cmake_version_component MAJOR
$cmake_version_minor = cmake_version_component MINOR
$cmake_version_patch = cmake_version_component PATCH
$cmake_version = "${cmake_version_major}.${cmake_version_minor}.${cmake_version_patch}"
$cmake_version_rc = cmake_version_component RC
if (-not [string]::IsNullOrEmpty($cmake_version_rc)) {
    $cmake_version = "${cmake_version}-rc${cmake_version_rc}"
}

# CMake copyright
$cmake_copyright = (Select-String -Path "${cmake_source_dir}\LICENSE.rst" -Pattern "^Copyright .* Kitware").Line -replace "`Contributors.*`_", "Contributors"

# REMOVED: Some of the variables here are removed, because not needed for flag parsing
$cmake_bin_dir_keyword = "OTHER"
$cmake_data_dir_keyword = "OTHER"
$cmake_doc_dir_keyword = "OTHER"
$cmake_man_dir_keyword = "OTHER"
$cmake_xdgdata_dir_keyword = "OTHER"

# OBSOLETE: Determine whether this is a MinGW environment.

# Set tools and extensions for this platform.
# CHECK .tmp for command line/windows
$_tmp = ".tmp"
$_cmk = ".cmk"
# REMOVED _diff, because internal methods available

# Construct bootstrap directory name.
$cmake_bootstrap_dir = "${cmake_binary_dir}\Bootstrap${_cmk}"

# REMOVED: Helper function to fix windows paths.

# Lookup default install destinations.
$cmake_bin_dir_default = cmake_install_dest_default BIN ${cmake_bin_dir_keyword}
$cmake_data_dir_default = cmake_install_dest_default DATA ${cmake_data_dir_keyword}
$cmake_doc_dir_default = cmake_install_dest_default DOC ${cmake_doc_dir_keyword}
$cmake_man_dir_default = cmake_install_dest_default MAN ${cmake_man_dir_keyword}
$cmake_xdgdata_dir_default = cmake_install_dest_default XDGDATA ${cmake_xdgdata_dir_keyword}

function die {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        $Message
    )

    Write-Error ($Message -join ' ')
    exit 1
}

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
  --bindir=DIR            install binaries in PREFIX\DIR
                          [${cmake_bin_dir_default}]
  --datadir=DIR           install data files in PREFIX\DIR
                          [${cmake_data_dir_default}]
  --docdir=DIR            install documentation files in PREFIX\DIR
                          [${cmake_doc_dir_default}]
  --mandir=DIR            install man pages files in PREFIX\DIR\manN
                          [${cmake_man_dir_default}]
  --xdgdatadir=DIR        install XDG specific files in PREFIX\DIR
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
        $pwd = Get-Location
        Write-Output "Log of errors: ${pwd}\cmake_bootstrap.log"
        Write-Output "---------------------------------------------"
    }

    exit $res
}

# Do boolean actions
if ($cmake_help) {
    cmake_usage
}

if ($show_version) {
    cmake_version_display
    exit 2
}

if ($cmake_bootstrap_generator -notin @("MSYS Makefiles", "Ninja")) {
    cmake_error 10 "Invalid generator: ${cmake_bootstrap_generator}"
}

# ------------------------------- CMake compilers, processors, files and flags -------------------------------
$CMAKE_KNOWN_C_COMPILERS = @("cc", "gcc", "clang", "xlc", "icx", "tcc")
$CMAKE_KNOWN_CXX_COMPILERS = @("aCC", "xlC", "CC", "g++", "clang++", "c++", "icpx")
$CMAKE_KNOWN_MAKE_PROCESSORS = @("gmake", "make", "smake")
$CMAKE_KNOWN_NINJA_PROCESSORS = @("ninja-build", "ninja", "samu")

$CMAKE_PROBLEMATIC_FILES = @(
    "CMakeCache.txt",
    "CMakeSystem.cmake",
    "CMakeCCompiler.cmake",
    "CMakeCXXCompiler.cmake",
    "*\CMakeSystem.cmake",
    "\CMakeCCompiler.cmake",
    "*\CMakeCXXCompiler.cmake",
    "Source\cmConfigure.h",
    "Source\CTest\Curl\config.h",
    "Utilities\cmThirdParty.h",
    "Utilities\cmcurl\lib\curl_config.h",
    "Utilities\cmlibarchive\config.h",
    "Utilities\cmliblzma\config.h",
    "Utilities\cmnghttp2\config.h"
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
    "librhash\algorithms.c",
    "librhash\byte_order.c",
    "librhash\hex.c",
    "librhash\md5.c",
    "librhash\rhash.c",
    "librhash\sha1.c",
    "librhash\sha256.c",
    "librhash\sha3.c",
    "librhash\sha512.c",
    "librhash\util.c"
)

$JSONCPP_CXX_SOURCES = @(
    "src\lib_json\json_reader.cpp",
    "src\lib_json\json_value.cpp",
    "src\lib_json\json_writer.cpp"
)

$LIBUV_C_SOURCES = @(
    "src\fs-poll.c",
    "src\idna.c",
    "src\inet.c",
    "src\threadpool.c",
    "src\strscpy.c",
    "src\strtok.c",
    "src\timer.c",
    "src\uv-common.c",
    "src\win\async.c",
    "src\win\core.c",
    "src\win\detect-wakeup.c",
    "src\win\dl.c",
    "src\win\error.c",
    "src\win\fs-event.c",
    "src\win\fs.c",
    "src\win\getaddrinfo.c",
    "src\win\getnameinfo.c",
    "src\win\handle.c",
    "src\win\loop-watcher.c",
    "src\win\pipe.c",
    "src\win\poll.c",
    "src\win\process-stdio.c",
    "src\win\process.c",
    "src\win\signal.c",
    "src\win\stream.c",
    "src\win\tcp.c",
    "src\win\thread.c",
    "src\win\tty.c",
    "src\win\udp.c",
    "src\win\util.c",
    "src\win\winapi.c",
    "src\win\winsock.c"
)

# Update OUTFILE with TMPFILE if the files are different.
# TMPFILE is removed in this function. 
function cmake_generate_file_tmp {
    param (
        $OUTFILE,
        $TMPFILE
    )

    if ((Test-Path $outFile) -and (-not (Compare-Object (Get-Content $tmpFile) (Get-Content $outFile)))) {
        Remove-Item -Force $tmpFile 
    }
    else {
        Move-Item -Force $tmpFile $outFile
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

# Compile flag extraction function.
function cmake_extract_standard_flags {
    param (
        $id,
        $lang,
        $ver
    )

    if (-not $id) {
        $id = "*"
    }

    $pattern = "CMAKE_${lang}${ver}_EXTENSION_COMPILE_OPTION\s+`"?([^`")]+)"

    $result = ""
    $result += (Get-Content "$cmake_source_dir\Modules\Compiler\$id-$lang.cmake" -ErrorAction SilentlyContinue) |
    Select-String $pattern |
    ForEach-Object { $_.Matches[0].Groups[1].Value } |
    ForEach-Object { $_ -replace ';', ' ' }

    # Clang's CXX compiler flags are in the common module.
    $pattern = "CMAKE_\$\{lang\}${ver}_EXTENSION_COMPILE_OPTION\s+`"?([^`")]+)"

    $result += (Get-Content "$cmake_source_dir\Modules\Compiler\Clang.cmake" -ErrorAction SilentlyContinue) |
    Select-String $pattern |
    ForEach-Object { $_.Matches[0].Groups[1].Value } |
    ForEach-Object { $_ -replace ';', ' ' }

    $result
}

# Replace KWSYS_NAMESPACE with cmsys
# cmake_replace_string ()
# {
#   INFILE="$1"
#   OUTFILE="$2"
#   SEARCHFOR="$3"
#   REPLACEWITH="$4"
#   if test -f "${INFILE}"; then
#     sed "s/\@${SEARCHFOR}\@/${REPLACEWITH}/g" "${INFILE}" > "${OUTFILE}${_tmp}"
#     if test -f "${OUTFILE}${_tmp}"; then
#       if "${_diff}" "${OUTFILE}" "${OUTFILE}${_tmp}" > /dev/null 2> /dev/null ; then
#         #echo "Files are the same"
#         rm -f "${OUTFILE}${_tmp}"
#       else
#         mv -f "${OUTFILE}${_tmp}" "${OUTFILE}"
#       fi
#     fi
#   else
#     cmake_error 1 "Cannot find file ${INFILE}"
#   fi
# }

# cmake_kwsys_config_replace_string ()
# {
#   INFILE="$1"
#   OUTFILE="$2"
#   shift 2
#   APPEND="$*"
#   if test -f "${INFILE}"; then
#     echo "${APPEND}" > "${OUTFILE}${_tmp}"
#     sed "/./ {s/\@KWSYS_NAMESPACE\@/cmsys/g;
#               s/@KWSYS_BUILD_SHARED@/${KWSYS_BUILD_SHARED}/g;
#               s/@KWSYS_LFS_AVAILABLE@/${KWSYS_LFS_AVAILABLE}/g;
#               s/@KWSYS_LFS_REQUESTED@/${KWSYS_LFS_REQUESTED}/g;
#               s/@KWSYS_NAME_IS_KWSYS@/${KWSYS_NAME_IS_KWSYS}/g;
#               s/@KWSYS_CXX_HAS_EXT_STDIO_FILEBUF_H@/${KWSYS_CXX_HAS_EXT_STDIO_FILEBUF_H}/g;
#              }" "${INFILE}" >> "${OUTFILE}${_tmp}"
#     if test -f "${OUTFILE}${_tmp}"; then
#       if "${_diff}" "${OUTFILE}" "${OUTFILE}${_tmp}" > /dev/null 2> /dev/null ; then
#         #echo "Files are the same"
#         rm -f "${OUTFILE}${_tmp}"
#       else
#         mv -f "${OUTFILE}${_tmp}" "${OUTFILE}"
#       fi
#     fi
#   else
#     cmake_error 2 "Cannot find file ${INFILE}"
#   fi
# }

# # Write string into a file
# cmake_report ()
# {
#   FILE=$1
#   shift
#   echo "$*" >> ${FILE}
# }

# # Escape spaces in strings for artifacts
# cmake_escape_artifact ()
# {
#   if test "${cmake_bootstrap_generator}" = "Ninja"; then
#     echo $1 | sed "s/ /$ /g"
#   else
#     echo $1 | sed "s/ /\\\\ /g"
#   fi
# }

# # Escape spaces in strings for shell
# cmake_escape_shell ()
# {
#   echo $1 | sed "s/ /\\\\ /g"
# }

# # Encode object file names.
# cmake_obj ()
# {
#   echo $1 | sed 's/\//-/g' | sed 's/$/\.o/'
# }

# REMOVED: Strip prefix from argument

# # Write message to the log
# cmake_log ()
# {
#   echo "$*" >> cmake_bootstrap.log
# }

# Return temp file with random name
# CHANGE: The name is not based on the current PID
function cmake_tmp_file {
    $guid = [guid]::NewGuid().ToString()
    "cmake_bootstrap_$guid"
}

# Run a compiler test. First argument is compiler, second one are compiler
# flags, third one is test source file to be compiled
function cmake_try_run {
    param (
        $COMPILER,
        $FLAGS,
        $TESTFILE
    )

    if (-not(Test-Path "${TESTFILE}")) {
        Write-Output "Test file ${TESTFILE} missing. Please verify your CMake source tree."
        exit 4
    }

    # Account for empty flags
    if (-not [string]::IsNullOrWhiteSpace($FLAGS)) {
        $compiler_flags += ($FLAGS -split '\s+')
    }
    else {
        $compiler_flags = @()
    }

    $TMPFILE = cmake_tmp_file
    Write-Output "Try: ${COMPILER}"
    Write-Output "Line: ${COMPILER} ${compiler_flags} ${TESTFILE} -o ${TMPFILE}"
    Write-Output "----------  file   -----------------------"
    Get-Content "${TESTFILE}"
    Write-Output "------------------------------------------"
    & $COMPILER $compiler_flags $TESTFILE -o $TMPFILE
    if (-not($?)) {
        Write-Output "Test failed to compile"
        return 1
    }

    if ((-not(Test-Path "${TMPFILE}")) -and (-not(Test-Path "${TMPFILE}.exe"))) {
        Write-Output "Test failed to produce executable"
        return 2
    }

    & .\${TMPFILE}
    $RES = $?
    Remove-Item -Force "${TMPFILE}" -ErrorAction SilentlyContinue
    if (-not(${RES})) {
        Write-Output "Test produced non-zero return code"
        return 3
    }

    Write-Output "Test succeeded"
    return 0
}

# Run a make test. First argument is the make interpreter.
function cmake_try_make () {
    param (
        $MAKE_PROC,
        $MAKE_FLAGS
    )

    # Account for empty flags
    if (-not [string]::IsNullOrWhiteSpace($MAKE_FLAGS)) {
        $make_flags += ($MAKE_FLAGS -split '\s+')
    }
    else {
        $make_flags = @()
    }

    Write-Output "Try: ${MAKE_PROC}"
    & ${MAKE_PROC} ${make_flags}
    if (-not($?)) {
        Write-Output "${MAKE_PROC} does not work"
        return 1
    }
    
    if ((-not(Test-Path "test")) -and (-not(Test-Path "test.exe"))) {
        Write-Output "${COMPILER} does not produce output"
        return 2
    }

    & ./test
    RES=$?
    Remove-Item -Force "test" -ErrorAction SilentlyContinue
    if (-not(${RES})) {
        Write-Output "${MAKE_PROC} produces strange executable"
        return 3
    }

    Write-Output "${MAKE_PROC} works"
    return 0
}

# If verbose, display some information about bootstrap
if (${cmake_verbose}) {
    Write-Output "---------------------------------------------"
    Write-Output "Source directory: ${cmake_source_dir}"
    Write-Output "Binary directory: ${cmake_binary_dir}"
    Write-Output "Prefix directory: ${cmake_prefix_dir}"
    Write-Output "System:           ${cmake_system}"
    Write-Output "Generator:        ${cmake_bootstrap_generator}"
    if ("" -ne $cmake_parallel_make) {
        Write-Output "Doing parallel make: ${cmake_parallel_make}"
    }
    Write-Output ""
}

Write-Output "---------------------------------------------"
# Get CMake version
cmake_version_display

# Check for in-source build
$cmake_in_source_build = $false
if ((Test-Path "${cmake_binary_dir}\Source\cmake.cxx") -and (Test-Path "${cmake_binary_dir}\Source\cmake.h")) {
    if ($cmake_verbose) {
        Write-Output "Warning: This is an in-source build"
    }

    $cmake_in_source_build = $true
}

# If this is not an in-source build, then Bootstrap stuff should not exist.
if (-not($cmake_in_source_build)) {
    # Did somebody bootstrap in the source tree?
    if (Test-Path "${cmake_source_dir}\Bootstrap${_cmk}") {
        cmake_error 10 "Found directory '${cmake_source_dir}\Bootstrap${_cmk}'.
Looks like somebody did bootstrap CMake in the source tree, but now you are
trying to do bootstrap in the binary tree. Please remove Bootstrap${_cmk}
directory from the source tree."
    }

    # Is there a cache in the source tree?
    foreach ($problematic_file in $CMAKE_PROBLEMATIC_FILES) {
        if (Test-Path "${cmake_source_dir}\${problematic_file}") {
            cmake_error 10 "Found '${cmake_source_dir}\${problematic_file}'.
Looks like somebody tried to build CMake in the source tree, but now you are
trying to do bootstrap in the binary tree. Please remove '${problematic_file}'
from the source tree."
        }
    }
}

# Make bootstrap directory if it didn't exist already
if (-not(Test-Path $cmake_bootstrap_dir)) {
    New-Item -ItemType Directory -Path "${cmake_bootstrap_dir}"
}

# Make sure that directory creation worked
if (-not(Test-Path $cmake_bootstrap_dir)) {
    cmake_error 3 "Cannot create directory ${cmake_bootstrap_dir} to bootstrap CMake."
}

# Go into the bootstrap directory for the bootstrap
Set-Location "${cmake_bootstrap_dir}"

# Create cmsys in bootstrap directory if it didn't exist already
if (-not(Test-Path "cmsys")) {
    New-Item -ItemType Directory -Path "cmsys"
}

# Make sure that directory creation worked
if (-not(Test-Path "cmsys")) {
    cmake_error 4 "Cannot create directory ${cmake_bootstrap_dir}\cmsys"
}

# Delete all the bootstrap files
Remove-Item -Force "${cmake_bootstrap_dir}\cmake_bootstrap.log" -ErrorAction SilentlyContinue
Remove-Item -Force "${cmake_bootstrap_dir}\cmConfigure.h${_tmp}" -ErrorAction SilentlyContinue
Remove-Item -Force "${cmake_bootstrap_dir}\cmVersionConfig.h${_tmp}" -ErrorAction SilentlyContinue

# If building in-source, remove any cmConfigure.h that may
# have been created by a previous run of the bootstrap cmake.
if ($cmake_in_source_build) {
    Remove-Item -Force "${cmake_source_dir}\Source\cmConfigure.h" -ErrorAction SilentlyContinue
}

# If exist compiler flags, set them
$cmake_c_flags = ${CFLAGS}
$cmake_cxx_flags = ${CXXFLAGS}
$cmake_ld_flags = ${LDFLAGS}

# Add generator-specific files
if ("${cmake_bootstrap_generator}" -eq "Ninja") {
    $CMAKE_CXX_SOURCES += @(
        "cmFortranParserImpl",
        "cmGlobalNinjaGenerator",
        "cmLocalNinjaGenerator",
        "cmNinjaLinkLineComputer",
        "cmNinjaLinkLineDeviceComputer",
        "cmNinjaNormalTargetGenerator",
        "cmNinjaTargetGenerator",
        "cmNinjaUtilityTargetGenerator"
    )

    $LexerParser_CXX_SOURCES += @(
        "cmFortranLexer",
        "cmFortranParser"
    )
}
else {
    $CMAKE_CXX_SOURCES += @(
        "cmDepends",
        "cmDependsC",
        "cmDependsCompiler",
        "cmGlobalUnixMakefileGenerator3",
        "cmLocalUnixMakefileGenerator3",
        "cmMakefileExecutableTargetGenerator",
        "cmMakefileLibraryTargetGenerator",
        "cmMakefileTargetGenerator",
        "cmMakefileUtilityTargetGenerator",
        "cmProcessTools"
    )
}

#-----------------------------------------------------------------------------
# Set known toolchains on MinGW.
$cmake_toolchains = @("GNU")

# Toolchain compiler name table.
$cmake_toolchain_Clang_CC = "clang"
$cmake_toolchain_Clang_CXX = "clang++"
$cmake_toolchain_GNU_CC = "gcc"
$cmake_toolchain_GNU_CXX = "g++"
$cmake_toolchain_PGI_CC = "pgcc"
$cmake_toolchain_PGI_CXX = "pgCC"
$cmake_toolchain_PathScale_CC = "pathcc"
$cmake_toolchain_PathScale_CXX = "pathCC"
$cmake_toolchain_XL_CC = "xlc"
$cmake_toolchain_XL_CXX = "xlC"

function cmake_toolchain_try {
    param (
        $tc
    )

    $TMPFILE = cmake_tmp_file
    $tc_CC = Get-Variable -Name "cmake_toolchain_${tc}_CC" -ValueOnly
    'int main() { return 0; }' | Set-Content "${TMPFILE}.c" -Encoding utf8
    cmake_try_run "$tc_CC" "" "${TMPFILE}.c" | Out-File cmake_bootstrap.log
    $tc_result_CC = "$?"
    Remove-Item -Force "${TMPFILE}.c" -ErrorAction SilentlyContinue
    if (-not(${tc_result_CC})) {
        return 1
    }

    $tc_CXX = Get-Variable -Name "cmake_toolchain_${tc}_CXX" -ValueOnly
    'int main() { return 0; }' | Set-Content "${TMPFILE}.cpp" -Encoding utf8
    cmake_try_run "$tc_CC" "" "${TMPFILE}.cpp" | Out-File cmake_bootstrap.log
    $tc_result_CXX = "$?"
    Remove-Item -Force "${TMPFILE}.cpp" -ErrorAction SilentlyContinue
    if (-not(${tc_result_CXX})) {
        return 1
    }

    # REMOVED: $cmake_toolchain = "$tc" because doesn't work well in powershell
}

function cmake_toolchain_detect {
    $cmake_toolchain = ""
    foreach ($tc in ${cmake_toolchains}) {
        "Checking for ${tc} toolchain" | Add-Content cmake_bootstrap.log
        cmake_toolchain_try "${tc}"
        Write-Host "Found ${tc} toolchain"
        $cmake_toolchain = $tc
        break
    }

    $cmake_toolchain
}

if (("${CC}" -eq "") -and ("${CXX}" -eq "")) {
    $cmake_toolchain = cmake_toolchain_detect
}

#-----------------------------------------------------------------------------
# Test C compiler
$cmake_c_compiler = ""

# If CC is set, use that for compiler, otherwise use list of known compilers
if ("${cmake_toolchain}" -ne "") {
    $varname = "cmake_toolchain_${cmake_toolchain}_CC"
    $cmake_c_compilers = (Get-Variable $varname).Value
}
else {
    $cmake_c_compilers = "${CMAKE_KNOWN_C_COMPILERS}"
}

function cmake_c_compiler_try_set {
    param (
        $test_compiler,
        $test_thread_flags
    )

    # Check if C compiler works
    $TMPFILE = cmake_tmp_file
    @"
#ifdef __cplusplus
# error "The CMAKE_C_COMPILER is set to a C++ compiler"
#endif

#include <stdio.h>

int main(int argc, char* argv[])
{
  printf("%d%c", (argv != 0), (char)0x0a);
  return argc - 1;
}
"@ | Set-Content "${TMPFILE}.c" -Encoding utf8
    foreach ($std in @(11, 99, 90)) {
        $std_flags = cmake_extract_standard_flags "${cmake_toolchain}" "C" "${std}"
        $std_flags = $std_flags -split '\s+'
        $std_flags = , "" + $std_flags
        foreach ($std_flag in $std_flags) {
            "Checking whether '${test_compiler} ${cmake_c_flags} ${cmake_ld_flags} ${std_flag}' works." | Add-Content cmake_bootstrap.log
            cmake_try_run $test_compiler "$cmake_c_flags $cmake_ld_flags $std_flag" "${TMPFILE}.c" 2>&1 | Tee-Object -FilePath cmake_bootstrap.log -Append
            if ($LASTEXITCODE -eq 0) {
                $script:cmake_c_compiler = "${test_compiler}"
                $script:cmake_c_flags = "${cmake_c_flags} ${std_flag}"
                Remove-Item -Force "${TMPFILE}.c" -ErrorAction SilentlyContinue
                return 0
            }
        }
    }

    Remove-Item -Force "${TMPFILE}.c" -ErrorAction SilentlyContinue
    return 1
}

if ("${CC}" -ne "") {
    cmake_c_compiler_try_set "${CC}"
}
else {
    foreach ($compiler in ${cmake_c_compilers}) {
        if (cmake_c_compiler_try_set "${compiler}") {
            break
        }
    }
}

if ($cmake_c_compiler -eq "") {
    cmake_error 6 "Cannot find appropriate C compiler on this system.
Please specify one using environment variable CC.
See cmake_bootstrap.log for compilers attempted.
"
}

Write-Output "C compiler on this system is: ${cmake_c_compiler} ${cmake_c_flags}"

#-----------------------------------------------------------------------------
# Test CXX compiler
$cmake_cxx_compiler = "" 

# On Mac OSX, CC is the same as cc, so make sure not to try CC as c++ compiler.

# If CC is set, use that for compiler, otherwise use list of known compilers
if ("${cmake_toolchain}" -ne "") {
    $varname = "cmake_toolchain_${cmake_toolchain}_CXX"
    $cmake_cxx_compilers = (Get-Variable $varname).Value
}
else {
    $cmake_cxx_compilers = "${CMAKE_KNOWN_CXX_COMPILERS}"
}

# Check if C++ compiler works
function cmake_cxx_compiler_try_set {
    param (
        $test_compiler
    )

    $TMPFILE = cmake_tmp_file
    @"
#include <iostream>
#include <memory>
#include <unordered_map>

#if __cplusplus < 201103L
#error "Compiler is not in a mode aware of C++11."
#endif

#if defined(__SUNPRO_CC) && __SUNPRO_CC < 0x5140
#error "SunPro <= 5.13 mode not supported due to bug in move semantics."
#endif

#if __cplusplus > 201103L
#include <iterator>
int check_cxx14()
{
  int a[] = { 0, 1, 2 };
  auto ai = std::cbegin(a);

  int b[] = { 2, 1, 0 };
  auto bi = std::cend(b);

  return *ai + *(bi - 1);
}
#else
int check_cxx14()
{
  return 0;
}
#endif

#if (__cplusplus >= 201703L || defined(__INTEL_COMPILER) && defined(__cpp_deduction_guides))
#include <optional>
template <typename T,
          typename std::invoke_result<decltype(&T::get), T>::type = nullptr>
typename T::pointer get_ptr(T& item)
{
  return item.get();
}

int check_cxx17()
{
  // Intel compiler do not handle correctly 'decltype' inside 'invoke_result'
  std::unique_ptr<int> u(new int(0));
  get_ptr(u);
  std::optional<int> oi = 0;
  return oi.value();
}
#else
int check_cxx17()
{
  return 0;
}
#endif

class Class
{
public:
  int Get() const { return this->Member; }
private:
  int Member = 1;
};
int main()
{
  auto const c = std::unique_ptr<Class>(new Class);
  std::cout << c->Get() << check_cxx14() << check_cxx17() << std::endl;
  return 0;
}
"@ | Set-Content "${TMPFILE}.cxx" -Encoding utf8
    foreach ($std in @(17, 14, 11)) {
        $std_flags = cmake_extract_standard_flags "${cmake_toolchain}" "CXX" "${std}"
        $std_flags = $std_flags -split '\s+'
        $std_flags = , "" + $std_flags
        foreach ($std_flag in $std_flags) {
            "Checking whether '${test_compiler} ${cmake_cxx_flags} ${cmake_ld_flags} ${std_flag}' works." | Add-Content cmake_bootstrap.log
            cmake_try_run $test_compiler "$cmake_cxx_flags $cmake_ld_flags $std_flag" "${TMPFILE}.cxx" 2>&1 | Tee-Object -FilePath cmake_bootstrap.log -Append
            if ($LASTEXITCODE -eq 0) {
                $script:cmake_cxx_compiler = "${test_compiler}"
                $script:cmake_cxx_flags = "${cmake_cxx_flags} ${std_flag}"
                Remove-Item -Force "${TMPFILE}.cxx" -ErrorAction SilentlyContinue
                return 0
            }
        }
    }

    Remove-Item -Force "${TMPFILE}.cxx" -ErrorAction SilentlyContinue
    return 1
}

if ("${CXX}" -ne "") {
    cmake_cxx_compiler_try_set "${CXX}"
}
else {
    foreach ($compiler in ${cmake_cxx_compilers}) {
        if (cmake_cxx_compiler_try_set "${compiler}") {
            break
        }
    }
}

if ($cmake_cxx_compiler -eq "") {
    cmake_error 7 "Cannot find a C++ compiler that supports both C++11 and the specified C++ flags.
Please specify one using environment variable CXX.
The C++ flags are '$cmake_cxx_flags'.
They can be changed using the environment variable CXXFLAGS.
See cmake_bootstrap.log for compilers attempted."
}

Write-Output "C++ compiler on this system is: ${cmake_cxx_compiler} ${cmake_cxx_flags}"

#-----------------------------------------------------------------------------
# Test CXX features

$cmake_cxx_features = @("make_unique", "filesystem")

foreach ($feature in ${cmake_cxx_features}) {
    $varname = "cmake_have_cxx_${feature}"
    Set-Variable -Name $varname -Value 0

    "Checking whether '${cmake_cxx_compiler} ${cmake_cxx_flags} ${cmake_ld_flags}' supports '${feature}'." | Add-Content cmake_bootstrap.log
    $output = & cmake_try_run "${cmake_cxx_compiler}" "${cmake_cxx_flags} ${cmake_ld_flags}" "${cmake_source_dir}\Source\Checks\cm_cxx_${feature}.cxx" 2>&1
    $exit = $LASTEXITCODE
    $output | Tee-Object -FilePath cmake_bootstrap.log -Append | Out-Null
    if ($exit -eq 0) {
        Set-Variable -Name $varname -Value 1
    }
}

$cmake_have_cxx_features = ""
foreach ($feature in ${cmake_cxx_features}) {
    $varname = "cmake_have_cxx_${feature}"
    $feature_value = (Get-Variable $varname).Value
    if ("${feature_value}" -eq "1") {
        $new_feature = "-DCMake_HAVE_CXX_$($feature.ToUpper())=${feature_value}"
        $cmake_have_cxx_features += $new_feature
    }
}

cmake_generate_file "${cmake_bootstrap_dir}\cmSTL.hxx" ""

#-----------------------------------------------------------------------------
# Test Make

$cmake_make_processor = $null
$cmake_make_flags = @()

# If MAKE is set, use that for make processor, otherwise use list of known make
if ($null -ne ${MAKE}) {
    $cmake_make_processors = "$MAKE" -split '\s+'
}
elseif ("${cmake_bootstrap_generator}" -eq "Ninja") {
    $cmake_make_processors = "${CMAKE_KNOWN_NINJA_PROCESSORS}" -split '\s+'
}
else {
    $cmake_make_processors = "${CMAKE_KNOWN_MAKE_PROCESSORS}" -split '\s+'
}

$tab = "`t" # TODO: Maybe don't use this variable

# Make sure the file doesn't exist (remove it if it does)
$TMPFILE = "$(cmake_tmp_file)_dir"
Remove-Item -Force "${cmake_bootstrap_dir}\${TMPFILE}" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "${cmake_bootstrap_dir}\${TMPFILE}"
Set-Location "${cmake_bootstrap_dir}\${TMPFILE}"

# CHECK: Dubble quotes ('")
if ("${cmake_bootstrap_generator}" -eq "Ninja") {
    Write-Output @"
rule cc
  command = ${cmake_c_compiler} ${cmake_ld_flags} ${cmake_c_flags} -o $out $in
build test: cc test.c
"@ | Set-Content "build.ninja" -Encoding utf8
}
else {
    Write-Output @"
test: test.c
${tab}${cmake_c_compiler} ${cmake_ld_flags} ${cmake_c_flags} -o test test.c
"@ | Set-Content "Makefile" -Encoding utf8
}

Write-Output @"
#include <stdio.h>
int main(){ printf("1%c", (char)0x0a); return 0; }
"@ | Set-Content "test.c" -Encoding utf8
$cmake_original_make_flags = "${cmake_make_flags}"
if ("${cmake_parallel_make}" -ne "") {
    $cmake_make_flags += "-j ${cmake_parallel_make}"
}

foreach ($a in ${cmake_make_processors}) {
    $output = & cmake_try_make "${a}" "${cmake_make_flags}" 2>&1
    $exit = $LASTEXITCODE
    $output | Tee-Object -FilePath ..\cmake_bootstrap.log -Append | Out-Null
    if ($null -eq ${cmake_make_processor} -and $exit -eq 0) {
        $cmake_make_processor = "${a}"
    }
}

$cmake_full_make_flags = ${cmake_make_flags}
if ("${cmake_original_make_flags}" -ne "${cmake_make_flags}") {
    if ($null -eq ${cmake_make_processor}) {
        $cmake_make_flags = "${cmake_original_make_flags}"
        foreach ($a in ${cmake_make_processors}) {
            $output = & cmake_try_make "${a}" "${cmake_make_flags}" 2>&1
            $exit = $LASTEXITCODE
            $output | Tee-Object -FilePath ..\cmake_bootstrap.log -Append | Out-Null
            if ($null -eq ${cmake_make_processor} -and $exit -eq 0) {
                $cmake_make_processor = "${a}"
            }
        }
    }
}
Set-Location "${cmake_bootstrap_dir}"

if ("${cmake_bootstrap_generator}" -eq "Ninja") {
    $mf_str = "Ninja"
}
else {
    $mf_str = "Makefile"
}

if ($null -eq ${cmake_make_processor}) {
    cmake_error 8 "Cannot find appropriate ${mf_str} processor on this system.
Please specify one using environment variable MAKE."
}

Remove-Item -Force -Recurse "${cmake_bootstrap_dir}\${TMPFILE}" -ErrorAction SilentlyContinue
Write-Output "${mf_str} processor on this system is: ${cmake_make_processor}"
if ("${cmake_full_make_flags}" -ne "${cmake_make_flags}") {
    Write-Output "---------------------------------------------"
    Write-Output "${mf_str} processor ${cmake_make_processor} does not support parallel build"
    Write-Output "---------------------------------------------"
}
