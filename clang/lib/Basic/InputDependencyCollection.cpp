//===--- InputDependencyCollection.h - Searching for Resource----*- C++ -*-===//
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

#include "clang/Basic/InputDependencyCollection.h"
#include "clang/Basic/FileManager.h"
#include "llvm/Support/Path.h"
#include <filesystem>

using namespace llvm;

namespace clang {

PatternFilter::PatternFilter(std::string Pattern)
    : Input(std::move(Pattern)), SearchRoot(""), PatternRoot(""), Pattern(""),
      RootHandling(RootPatternScanType::None), Exported(false) {}

bool PatternFilter::Check(StringRef Filename) const {
  if (!PatternRoot.empty()) {
    // if the pattern root is not empty, first check if the filename is anchored
    // in the pattern's root exit early if it's not
    if (!Filename.contains(PatternRoot)) {
      return false;
    }
  }
  // otherwise, commit to doing a regex search
  if (PatternRegex.match(Filename)) {
    // it matches, we can find it
    return true;
  }
  return false;
}

PatternFilter InputDependencyCollection::ComputeFilter(std::string Pattern,
                                                       bool Exported) {
  static constexpr const char *RecursiveReplacement = ".*";
  static constexpr const std::size_t RecursiveReplacementSize = 2;
  static constexpr const char *Replacement = "[^/\\]*";
  static constexpr const std::size_t ReplacementSize = 6;
  PatternFilter Computed(std::move(Pattern));
  // Technically, this is a very conservative estimate, since this is only in
  // the most harmless of cases.
  Computed.Pattern.reserve(Computed.Input.size());
  const std::size_t InputSize = Computed.Input.size();
  std::optional<std::size_t> LastRootSeparator = std::nullopt;
  std::optional<std::size_t> LastStar = std::nullopt;
  std::optional<std::size_t> LastStarStar = std::nullopt;
  for (std::size_t I = 0; I < InputSize; ++I) {
    const char CharVal = Computed.Input[I];
    switch (CharVal) {
    case '*':
      if (I < InputSize && Computed.Input[I + 1] == '*') {
        // completely unrestricted: replace with `.*`
        ++I;
        Computed.RootHandling = static_cast<RootPatternScanType>(
            static_cast<unsigned int>(RootPatternScanType::RecursiveDirectory) |
            static_cast<unsigned int>(Computed.RootHandling));
        Computed.Pattern.append(RecursiveReplacement, RecursiveReplacementSize);
        LastStarStar = I;
      } else {
        // regular non-path-delimited changers: `[^\\/]*
        Computed.RootHandling = static_cast<RootPatternScanType>(
            static_cast<unsigned int>(
                LastStar
                    ? (*LastStar < LastRootSeparator
                           ? RootPatternScanType::DirectoryAndRecursiveDirectory
                           : RootPatternScanType::Directory)
                    : RootPatternScanType::Directory) |
            static_cast<unsigned int>(Computed.RootHandling));
        Computed.Pattern.append(Replacement, ReplacementSize);
        LastStar = I;
      }
      break;
    case ')':
    case '(':
    case '[':
    case ']':
    case '{':
    case '}':
    case '^':
    case '$':
    case '.':
    case '+':
    case '?':
    case '|':
      // cases where the character must be escaped
      Computed.Pattern.push_back('\\');
      Computed.Pattern.push_back(CharVal);
      break;
    case '/':
      if (Computed.RootHandling == RootPatternScanType::None)
        LastRootSeparator = I;
      Computed.Pattern.append("[/\\]", 4);
      break;
    case '\\':
      if (Computed.RootHandling == RootPatternScanType::None)
        LastRootSeparator = I;
      Computed.Pattern.append("[/\\]", 4);
      break;
    default:
      Computed.Pattern.push_back(CharVal);
      break;
    }
  }
  Computed.Pattern.push_back('$');
  Computed.PatternRoot.append(
      Computed.Input.cbegin(),
      Computed.Input.cbegin() +
          LastRootSeparator.value_or(static_cast<std::size_t>(0)));
  // If LastSeperator == 0 and the Input's size is Non-Zero Could be a directory
  // OR a file we're relying on... could be a bit strange to work with!
  // nevertheless, we'll treat it as a file, no reason to use `stat` and other
  // temporary checks to try and determine whether or not something is a file
  // versus a directory here.
  Computed.PatternRegex = Regex(Computed.Pattern, Regex::NoFlags);
  return Computed;
}

PatternFilter &
InputDependencyCollection::Add(std::string Pattern, bool IsAngled,
                               bool Exported, FileManager &FM,
                               const std::vector<std::string> &SearchEntries,
                               OptionalFileEntryRef LookupFrom) {
  PatternFilters.push_back(ComputeFilter(std::move(Pattern), Exported));
  PatternFilter &Filter = PatternFilters.back();
  if (Filter.PatternRoot.empty() ||
      llvm::sys::path::is_absolute(Filter.PatternRoot)) {
    // nothing else to do since it's absolute
    // or the PatternRoot is empty, so we can't do any
    // pre-culling.
    return Filter;
  }
  // Find a plausible search root among the entries, if possible, to anchor this
  // to a given entry
  auto TryDetermineSearchRoot = [&](StringRef SearchEntry) -> bool {
    if (SearchEntry.contains(Filter.PatternRoot)) {
      // the entry is contained within: approve the search entry as the search
      // root
      Filter.SearchRoot.assign(SearchEntry.begin(), SearchEntry.end());
      return true;
    }
    return false;
  };
  if (!IsAngled && LookupFrom) {
    // quote search; including the optional file entry as a root search location
    // too
    StringRef LookupDirName = LookupFrom->getDir().getName();
    if (TryDetermineSearchRoot(LookupDirName)) {
      return Filter;
    }
  }
  for (StringRef SearchEntry : SearchEntries) {
    if (TryDetermineSearchRoot(SearchEntry)) {
      return Filter;
    }
  }
  // if we're here, then we just need to make the SearchRoot identical to the
  // Pattern's root.
  Filter.SearchRoot = Filter.PatternRoot;
  return Filter;
}

bool InputDependencyCollection::Check(StringRef Filename) const {
  for (const auto &Filter : PatternFilters) {
    if (Filter.Check(Filename)) {
      return true;
    }
  }
  return false;
}

} // namespace clang
