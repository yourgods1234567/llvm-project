if (APPLE AND LLVM_ENABLE_LOCAL_SUBMODULE_VISIBILITY)
  # Work around an issue with the Python headers, which have a modular include
  # inside an extern "C" block.
  remove_module_flags()
endif()

if(NOT LLDB_PYTHON_RELATIVE_PATH)
  message(FATAL_ERROR "LLDB_PYTHON_RELATIVE_PATH is not set.")
endif()
add_definitions(-DLLDB_PYTHON_RELATIVE_LIBDIR="${LLDB_PYTHON_RELATIVE_PATH}")

if(NOT LLDB_PYTHON_EXE_RELATIVE_PATH)
  message(FATAL_ERROR "LLDB_PYTHON_EXE_RELATIVE_PATH is not set.")
endif()
add_definitions(-DLLDB_PYTHON_EXE_RELATIVE_PATH="${LLDB_PYTHON_EXE_RELATIVE_PATH}")

if (LLDB_ENABLE_LIBEDIT)
  list(APPEND LLDB_LIBEDIT_LIBS LibEdit::LibEdit)
endif()

set(python_plugin_sources
  PythonDataObjects.cpp
  PythonReadline.cpp
  ScriptInterpreterPython.cpp

  Interfaces/OperatingSystemPythonInterface.cpp
  Interfaces/ScriptInterpreterPythonInterfaces.cpp
  Interfaces/ScriptedFramePythonInterface.cpp
  Interfaces/ScriptedFrameProviderPythonInterface.cpp
  Interfaces/ScriptedPlatformPythonInterface.cpp
  Interfaces/ScriptedProcessPythonInterface.cpp
  Interfaces/ScriptedPythonInterface.cpp
  Interfaces/ScriptedStopHookPythonInterface.cpp
  Interfaces/ScriptedBreakpointPythonInterface.cpp
  Interfaces/ScriptedThreadPlanPythonInterface.cpp
  Interfaces/ScriptedThreadPythonInterface.cpp
)

set(python_plugin_static_link_components Support)
set(python_plugin_static_link_libs
  lldbBreakpoint
  lldbCore
  lldbDataFormatters
  lldbHost
  lldbInterpreter
  lldbTarget
  lldbValueObject
  ${Python3_LIBRARIES}
  ${LLDB_LIBEDIT_LIBS}
)

if (LLDB_ENABLE_DYNAMIC_SCRIPTINTERPRETERS)
  set(plugin_kind SHARED)
  set(link_components "")
  set(link_libs
    liblldb
    ${Python3_LIBRARIES}
    ${LLDB_LIBEDIT_LIBS}
  )
else()
  set(plugin_kind PLUGIN)
  set(link_components ${python_plugin_static_link_components})
  set(link_libs ${python_plugin_static_link_libs})
endif()

add_lldb_library(lldbPluginScriptInterpreterPython ${plugin_kind}
  ${python_plugin_sources}

  LINK_COMPONENTS
    ${link_components}
  LINK_LIBS
    ${link_libs}
  )

target_include_directories(lldbPluginScriptInterpreterPython
  PUBLIC ${Python3_INCLUDE_DIRS})

if (LLDB_ENABLE_DYNAMIC_SCRIPTINTERPRETERS)
  add_python_wrapper(lldbPluginScriptInterpreterPython)

  # When we're building the script interpreter as a shared library, we don't
  # want to re-export all the symbols from the unit test. Instead, build a
  # static variant for unit test.
  add_lldb_library(lldbStaticScriptInterpreterPython
    ${python_plugin_sources}

    LINK_COMPONENTS
      ${python_plugin_static_link_components}
    LINK_LIBS
      ${python_plugin_static_link_libs}
    )
  target_include_directories(lldbStaticScriptInterpreterPython
    PUBLIC ${Python3_INCLUDE_DIRS})
endif()
