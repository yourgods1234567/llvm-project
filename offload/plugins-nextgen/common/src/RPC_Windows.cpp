//===- RPC_Windows.cpp - Windows stub implementation of RPC ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file provides Windows stub implementations for the RPC interface.
// Remote Procedure Calls are not supported on Windows, so all RPC functions
// are no-ops that return success.
//
//===----------------------------------------------------------------------===//

#include "RPC.h"
#include "PluginInterface.h"

using namespace llvm;
using namespace omp;
using namespace target;

// Windows stub: RPC not supported
RPCServerTy::RPCServerTy(plugin::GenericPluginTy &Plugin) {}

Error RPCServerTy::shutDown(plugin::GenericPluginTy &Plugin) {
  return Error::success();
}

Error RPCServerTy::startThread() {
  return Error::success();
}

Expected<bool> RPCServerTy::isDeviceUsingRPC(
    plugin::GenericDeviceTy &Device,
    plugin::GenericGlobalHandlerTy &Handler,
    plugin::DeviceImageTy &Image) {
  return false;
}

Error RPCServerTy::initDevice(
    plugin::GenericDeviceTy &Device,
    plugin::GenericGlobalHandlerTy &Handler,
    plugin::DeviceImageTy &Image) {
  return Error::success();
}

Error RPCServerTy::deinitDevice(plugin::GenericDeviceTy &Device) {
  return Error::success();
}

void RPCServerTy::registerCallback(RPCServerCallbackTy Callback) {}

void RPCServerTy::ServerThread::shutDown() {}

void RPCServerTy::ServerThread::startThread() {}

void RPCServerTy::ServerThread::run() {}
