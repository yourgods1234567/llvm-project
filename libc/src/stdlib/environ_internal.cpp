//===-- Implementation of internal environment utilities ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "environ_internal.h"
#include "config/app.h"
#include "src/__support/CPP/new.h"
#include "src/__support/CPP/string_view.h"
#include "src/__support/alloc-checker.h"
#include "src/__support/macros/config.h"

namespace LIBC_NAMESPACE_DECL {
namespace internal {

// Minimum initial capacity for the environment array when first allocated.
// This avoids frequent reallocations for small environments.
constexpr size_t MIN_ENVIRON_CAPACITY = 32;

// Growth factor for environment array capacity when expanding.
// When capacity is exceeded, new_capacity = old_capacity *
// ENVIRON_GROWTH_FACTOR.
constexpr size_t ENVIRON_GROWTH_FACTOR = 2;

char **EnvironmentManager::get_array() {
  if (is_ours)
    return storage;
  return reinterpret_cast<char **>(app.env_ptr);
}

void EnvironmentManager::init() {
  if (initialized)
    return;

  // Count entries in the startup environ
  char **env_ptr = reinterpret_cast<char **>(app.env_ptr);
  if (env_ptr) {
    size_t count = 0;
    for (char **env = env_ptr; *env != nullptr; env++)
      count++;
    size = count;
  }

  initialized = true;
}

int EnvironmentManager::find_var(cpp::string_view name) {
  char **env_array = get_array();
  if (!env_array)
    return -1;

  for (size_t i = 0; i < size; i++) {
    cpp::string_view current(env_array[i]);
    if (current.starts_with(name) && current.size() > name.size() &&
        current[name.size()] == '=')
      return static_cast<int>(i);
  }

  return -1;
}

// Helper: allocate new storage and ownership arrays of the given capacity,
// copy the first `copy_count` entries from old_storage/old_ownership, and
// initialize the remaining ownership slots to default (not-owned).
// Returns false on allocation failure; on failure the old arrays are untouched.
bool EnvironmentManager::alloc_and_copy(size_t new_capacity, char **old_storage,
                                        EnvStringOwnership *old_ownership,
                                        size_t copy_count,
                                        char **&out_storage,
                                        EnvStringOwnership *&out_ownership) {
  AllocChecker ac;
  char **new_storage = new (ac) char *[new_capacity + 1];
  if (!ac)
    return false;

  EnvStringOwnership *new_ownership = new (ac) EnvStringOwnership[new_capacity + 1];
  if (!ac) {
    delete[] new_storage;
    return false;
  }

  for (size_t i = 0; i < copy_count; i++) {
    new_storage[i] = old_storage ? old_storage[i] : nullptr;
    new_ownership[i] = old_ownership ? old_ownership[i] : EnvStringOwnership();
  }
  new_storage[copy_count] = nullptr;

  out_storage = new_storage;
  out_ownership = new_ownership;
  return true;
}

bool EnvironmentManager::ensure_capacity(size_t needed) {
  // If we're still using the startup environ (pointed to by app.env_ptr),
  // we must transition to our own managed storage. This allows us to
  // track ownership of strings and safely expand the array.
  if (!is_ours) {
    char **old_env = reinterpret_cast<char **>(app.env_ptr);

    // Allocate new array with room to grow.
    size_t new_capacity = needed < MIN_ENVIRON_CAPACITY
                              ? MIN_ENVIRON_CAPACITY
                              : needed * ENVIRON_GROWTH_FACTOR;

    char **new_storage = nullptr;
    EnvStringOwnership *new_ownership = nullptr;
    if (!alloc_and_copy(new_capacity, old_env, nullptr, size, new_storage,
                        new_ownership))
      return false;

    storage = new_storage;
    ownership = new_ownership;
    capacity = new_capacity;
    is_ours = true;

    // Update the global environ pointer.
    app.env_ptr = reinterpret_cast<uintptr_t *>(storage);

    return true;
  }

  // We already own the environment array. Check if it's large enough.
  if (needed <= capacity)
    return true;

  // Grow capacity. We avoid realloc to ensure that failures don't leave the
  // manager in an inconsistent state.
  size_t new_capacity = needed * ENVIRON_GROWTH_FACTOR;

  char **new_storage = nullptr;
  EnvStringOwnership *new_ownership = nullptr;
  if (!alloc_and_copy(new_capacity, storage, ownership, size, new_storage,
                      new_ownership))
    return false;

  delete[] storage;
  delete[] ownership;

  storage = new_storage;
  ownership = new_ownership;
  capacity = new_capacity;

  // Update the global environ pointer.
  app.env_ptr = reinterpret_cast<uintptr_t *>(storage);

  return true;
}

} // namespace internal
} // namespace LIBC_NAMESPACE_DECL
