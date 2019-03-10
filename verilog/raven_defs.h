#ifndef _RAVEN_H_
#define _RAVEN_H_

/* Raven include file raven.h */

#include <stdint.h>
#include <stdbool.h>

// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

extern uint32_t flashio_worker_begin;
extern uint32_t flashio_worker_end;

// Mermory map definitions

#define reg_spictrl (*(volatile uint32_t*)0x02000000)
#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data (*(volatile uint32_t*)0x02000008)

#define reg_gpio_data (*(volatile uint32_t*)0x03000000)
#define reg_gpio_ena (*(volatile uint32_t*)0x03000004)
#define reg_gpio_pu (*(volatile uint32_t*)0x03000008)
#define reg_gpio_pd (*(volatile uint32_t*)0x0300000c)

#define reg_adc0_ena (*(volatile uint32_t*)0x03000010)
#define reg_adc0_data (*(volatile uint32_t*)0x03000014)
#define reg_adc0_done (*(volatile uint32_t*)0x03000018)
#define reg_adc0_convert (*(volatile uint32_t*)0x0300001c)
#define reg_adc0_clk_source (*(volatile uint32_t*)0x03000020)
#define reg_adc0_input_source (*(volatile uint32_t*)0x03000024)

#define reg_adc1_ena (*(volatile uint32_t*)0x03000030)
#define reg_adc1_data (*(volatile uint32_t*)0x03000034)
#define reg_adc1_done (*(volatile uint32_t*)0x03000038)
#define reg_adc1_convert (*(volatile uint32_t*)0x0300003c)
#define reg_adc1_clk_source (*(volatile uint32_t*)0x03000040)
#define reg_adc1_input_source (*(volatile uint32_t*)0x03000044)

#define reg_dac_ena (*(volatile uint32_t*)0x03000050)
#define reg_dac_data (*(volatile uint32_t*)0x03000054)

#define reg_comp_enable (*(volatile uint32_t*)0x03000060)
#define reg_comp_n_source (*(volatile uint32_t*)0x03000064)
#define reg_comp_p_source (*(volatile uint32_t*)0x03000068)
#define reg_comp_out_dest (*(volatile uint32_t*)0x0300006c)

#define reg_rcosc_enable (*(volatile uint32_t*)0x03000070)
#define reg_rcosc_out_dest (*(volatile uint32_t*)0x03000074)

#define reg_spi_config (*(volatile uint32_t*)0x03000080)
#define reg_spi_enables (*(volatile uint32_t*)0x03000084)
#define reg_spi_pll_config (*(volatile uint32_t*)0x03000088)
#define reg_spi_mfgr_id (*(volatile uint32_t*)0x0300008c)
#define reg_spi_prod_id (*(volatile uint32_t*)0x03000090)
#define reg_spi_mask_rev (*(volatile uint32_t*)0x03000094)
#define reg_spi_pll_bypass (*(volatile uint32_t*)0x03000098)

#define reg_xtal_out_dest (*(volatile uint32_t*)0x030000a0)
#define reg_pll_out_dest (*(volatile uint32_t*)0x030000a4)
#define reg_trap_out_dest (*(volatile uint32_t*)0x030000a8)

#define reg_irq7_source (*(volatile uint32_t*)0x030000b0)
#define reg_irq8_source (*(volatile uint32_t*)0x030000b4)

#define reg_analog_out_sel (*(volatile uint32_t*)0x030000c0)
#define reg_analog_out_bias_ena (*(volatile uint32_t*)0x030000c4)
#define reg_analog_out_ena (*(volatile uint32_t*)0x030000c8)

#define reg_bandgap_ena (*(volatile uint32_t*)0x030000d0)

#define reg_overtemp_ena (*(volatile uint32_t*)0x030000e0)
#define reg_overtemp_data (*(volatile uint32_t*)0x030000e4)
#define reg_overtemp_out_dest (*(volatile uint32_t*)0x030000e8)

// --------------------------------------------------------
#endif
