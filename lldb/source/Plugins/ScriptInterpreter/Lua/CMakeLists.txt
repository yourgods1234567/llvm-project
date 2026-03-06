set(lua_plugin_sources
  LuaState.cpp
  ScriptInterpreterLua.cpp
)

set(lua_plugin_static_link_libs
  lldbCore
  lldbInterpreter
  ${LUA_LIBRARIES}
)

if (LLDB_ENABLE_DYNAMIC_SCRIPTINTERPRETERS)
  set(plugin_kind SHARED)
  set(link_libs
    liblldb
    ${LUA_LIBRARIES}
  )
else()
  set(plugin_kind PLUGIN)
  set(link_libs ${lua_plugin_static_link_libs})
endif()

add_lldb_library(lldbPluginScriptInterpreterLua ${plugin_kind}
  ${lua_plugin_sources}

  LINK_LIBS
    ${link_libs}
  )

target_include_directories(lldbPluginScriptInterpreterLua
  PUBLIC ${LUA_INCLUDE_DIR})

if (LLDB_ENABLE_DYNAMIC_SCRIPTINTERPRETERS)
  add_lua_wrapper(lldbPluginScriptInterpreterLua)

  add_lldb_library(lldbStaticScriptInterpreterLua
    ${lua_plugin_sources}

    LINK_LIBS
      ${lua_plugin_static_link_libs}
    )

  target_include_directories(lldbStaticScriptInterpreterLua
    PUBLIC ${LUA_INCLUDE_DIR})
endif()
