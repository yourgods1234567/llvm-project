#include <gpuintrin.h>
#include <stdint.h>

extern "C" __gpu_kernel void single_counter(int32_t init_loop, int32_t addend,
                                            uint32_t *out) {

  volatile int32_t counter = init_loop;

  while (counter--) {
    if (__gpu_thread_id(0) == 0) {
      *out += addend;
    }
  }
}
