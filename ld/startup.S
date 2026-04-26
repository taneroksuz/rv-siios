# See LICENSE for license details.

#include "encoding.h"

  .section ".text.init"
  .global _start
_start:

  # initialize stack pointer
  la sp, _stack

  # copy text section

  la t0, __load_start_text
  la t1, __load_stop_bss

  la t2, __tim_start
  la t3, __tim_end

copy_text:
  lw t4,0(t0)
  sw t4,0(t2)
  addi t0,t0,4
  addi t2,t2,4
  blt t0,t1,copy_text

  call main
  tail exit

.section ".tohost","aw",@progbits
.align 6
.globl tohost
tohost: .dword 0
.align 6
.globl fromhost
fromhost: .dword 0
