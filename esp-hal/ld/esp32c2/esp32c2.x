ENTRY(_start)

PROVIDE(_stext = ORIGIN(ROTEXT));
PROVIDE(_max_hart_id = 0);

PROVIDE(UserSoft = DefaultHandler);
PROVIDE(SupervisorSoft = DefaultHandler);
PROVIDE(MachineSoft = DefaultHandler);
PROVIDE(UserTimer = DefaultHandler);
PROVIDE(SupervisorTimer = DefaultHandler);
PROVIDE(MachineTimer = DefaultHandler);
PROVIDE(UserExternal = DefaultHandler);
PROVIDE(SupervisorExternal = DefaultHandler);
PROVIDE(MachineExternal = DefaultHandler);

PROVIDE(ExceptionHandler = DefaultExceptionHandler);

PROVIDE(__post_init = default_post_init);

/* A PAC/HAL defined routine that should initialize custom interrupt controller if needed. */
PROVIDE(_setup_interrupts = default_setup_interrupts);

/* # Multi-processing hook function
   fn _mp_hook() -> bool;

   This function is called from all the harts and must return true only for one hart,
   which will perform memory initialization. For other harts it must return false
   and implement wake-up in platform-dependent way (e.g. after waiting for a user interrupt).
*/
PROVIDE(_mp_hook = default_mp_hook);

/* # Start trap function override
  By default uses the riscv crates default trap handler
  but by providing the `_start_trap` symbol external crates can override.
*/
PROVIDE(_start_trap = default_start_trap);

/* esp32c2 fixups */

SECTIONS {
  .trap : ALIGN(4)
  {
    KEEP(*(.trap));
    *(.trap.*);
  } > RWTEXT
}
INSERT BEFORE .rwtext;

SECTIONS {
  /**
   * This dummy section represents the .text section but in rodata.
   * Thus, it must have its alignement and (at least) its size.
   */
  .text_dummy (NOLOAD):
  {
    /* Start at the same alignement constraint than .text */
    . = ALIGN(4);
    /* Create an empty gap as big as .text section */
    . = . + SIZEOF(.text);
    /* Prepare the alignement of the section above. Few bytes (0x20) must be
     * added for the mapping header. */
    . = ALIGN(0x10000) + 0x20;
  } > RODATA
}
INSERT BEFORE .rodata;

SECTIONS {
  /* similar as text_dummy */
  .rwdata_dummy (NOLOAD) : {
    . = ALIGN(ALIGNOF(.rwtext));
    . = . + SIZEOF(.rwtext);
    . = . + SIZEOF(.rwtext.wifi);
    . = . + SIZEOF(.trap);
  } > RWDATA
}
INSERT BEFORE .data;

/* Must be called __global_pointer$ for linker relaxations to work. */
PROVIDE(__global_pointer$ = _data_start + 0x800);
/* end of esp32c2 fixups */

/* Shared sections - ordering matters */
INCLUDE "rwtext.x"
INCLUDE "text.x"
INCLUDE "rwdata.x"
INCLUDE "rodata.x"
INCLUDE "stack.x"
INCLUDE "dram2.x"
/* End of Shared sections */

INCLUDE "debug.x"

_dram_origin = ORIGIN( DRAM );
