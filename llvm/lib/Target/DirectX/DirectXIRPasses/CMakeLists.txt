add_llvm_component_library(LLVMDirectXIRPasses
  DebugInfo.cpp
  PointerTypeAnalysis.cpp

  LINK_COMPONENTS
  Core
  Support

  ADD_TO_COMPONENT
  DirectX
  )
