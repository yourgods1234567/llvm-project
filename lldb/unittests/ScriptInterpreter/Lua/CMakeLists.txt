if (LLDB_ENABLE_DYNAMIC_SCRIPTINTERPRETERS)
  set(script_interpreter_lua_lib lldbStaticScriptInterpreterLua)
else()
  set(script_interpreter_lua_lib lldbPluginScriptInterpreterLua)
endif()

add_lldb_unittest(ScriptInterpreterLuaTests
  LuaTests.cpp
  ScriptInterpreterTests.cpp

  LINK_COMPONENTS
    Support
  LINK_LIBS
    lldbHost
    ${script_interpreter_lua_lib}
    lldbPluginPlatformLinux
    LLVMTestingSupport
  )
