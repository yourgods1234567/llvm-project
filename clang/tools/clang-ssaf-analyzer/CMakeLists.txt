set(LLVM_LINK_COMPONENTS
  Option
  Support
  )

add_clang_tool(clang-ssaf-analyzer
  SSAFAnalyzer.cpp
  )

clang_target_link_libraries(clang-ssaf-analyzer
  PRIVATE
  clangBasic
  clangScalableStaticAnalysisFrameworkAnalyses
  clangScalableStaticAnalysisFrameworkCore
  clangScalableStaticAnalysisFrameworkTool
  )

if(CLANG_PLUGIN_SUPPORT)
  export_executable_symbols_for_plugins(clang-ssaf-analyzer)
endif()
