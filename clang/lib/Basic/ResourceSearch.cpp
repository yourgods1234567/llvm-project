//===--- ResourceSearch.h - Searching for Resources -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// User-provided filters include/exclude profile instrumentation in certain
// functions or files.
//
//===----------------------------------------------------------------------===//

#include "clang/Basic/ResourceSearch.h"
#include "clang/Basic/FileManager.h"

namespace clang {

template <typename Strings>
OptionalFileEntryRef LookupFileWithImpl(StringRef Filename, bool isAngled,
                                        bool OpenFile, FileManager &FM,
                                        const Strings &SearchEntries,
                                        OptionalFileEntryRef LookupFromFile) {
  if (llvm::sys::path::is_absolute(Filename)) {
    // lookup path or immediately fail
    llvm::Expected<FileEntryRef> ShouldBeEntry = FM.getFileRef(
        Filename, OpenFile, /*CacheFailure=*/true, /*IsText=*/false);
    return llvm::expectedToOptional(std::move(ShouldBeEntry));
  }

  auto SeparateComponents = [](SmallVectorImpl<char> &LookupPath,
                               StringRef StartingFrom, StringRef FileName,
                               bool RemoveInitialFileComponentFromLookupPath) {
    llvm::sys::path::native(StartingFrom, LookupPath);
    if (RemoveInitialFileComponentFromLookupPath)
      llvm::sys::path::remove_filename(LookupPath);
    if (!LookupPath.empty() &&
        !llvm::sys::path::is_separator(LookupPath.back())) {
      LookupPath.push_back(llvm::sys::path::get_separator().front());
    }
    LookupPath.append(FileName.begin(), FileName.end());
  };

  // Otherwise, it's search time!
  SmallString<512> LookupPath;
  // Non-angled lookup
  if (!isAngled) {
    // Use file-based lookup.
    if (LookupFromFile) {
      SmallString<1024> TmpDir;
      TmpDir = LookupFromFile->getDir().getName();
      llvm::sys::path::append(TmpDir, Filename);
      if (!TmpDir.empty()) {
        llvm::Expected<FileEntryRef> ShouldBeEntry = FM.getFileRef(
            TmpDir, OpenFile, /*CacheFailure=*/true, /*IsText=*/false);
        if (ShouldBeEntry)
          return llvm::expectedToOptional(std::move(ShouldBeEntry));
        llvm::consumeError(ShouldBeEntry.takeError());
      }
    }

    // Otherwise, do working directory lookup.
    LookupPath.clear();
    auto MaybeWorkingDirEntry = FM.getDirectoryRef(".");
    if (MaybeWorkingDirEntry) {
      DirectoryEntryRef WorkingDirEntry = *MaybeWorkingDirEntry;
      StringRef WorkingDir = WorkingDirEntry.getName();
      if (!WorkingDir.empty()) {
        SeparateComponents(LookupPath, WorkingDir, Filename, false);
        llvm::Expected<FileEntryRef> ShouldBeEntry = FM.getFileRef(
            LookupPath, OpenFile, /*CacheFailure=*/true, /*IsText=*/false);
        if (ShouldBeEntry)
          return llvm::expectedToOptional(std::move(ShouldBeEntry));
        llvm::consumeError(ShouldBeEntry.takeError());
      }
    }
  }

  for (const auto &Entry : SearchEntries) {
    LookupPath.clear();
    SeparateComponents(LookupPath, Entry, Filename, false);
    llvm::Expected<FileEntryRef> ShouldBeEntry = FM.getFileRef(
        LookupPath, OpenFile, /*CacheFailure=*/true, /*IsText=*/false);
    if (ShouldBeEntry)
      return llvm::expectedToOptional(std::move(ShouldBeEntry));
    llvm::consumeError(ShouldBeEntry.takeError());
  }
  return std::nullopt;
}

OptionalFileEntryRef
LookupFileWithStdVec(StringRef Filename, bool isAngled, bool OpenFile,
                     FileManager &FM,
                     const std::vector<std::string> &SearchEntries,
                     OptionalFileEntryRef LookupFromFile) {
  return LookupFileWithImpl(Filename, isAngled, OpenFile, FM, SearchEntries,
                            LookupFromFile);
}

OptionalFileEntryRef LookupFileWith(StringRef Filename, bool isAngled,
                                    bool OpenFile, FileManager &FM,
                                    ArrayRef<StringRef> SearchEntries,
                                    OptionalFileEntryRef LookupFromFile) {
  return LookupFileWithImpl(Filename, isAngled, OpenFile, FM, SearchEntries,
                            LookupFromFile);
}
} // namespace clang
