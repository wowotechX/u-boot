/*
 * (C) Copyright 2016 wowotech
 * 
 * Project for Tiny210.
 * 
 * ooonebook <ooonebook@163.com>
 * 
 * SPDX-License-Identifier:    GPL-2.0+
 */ 

#include <common.h>
#include <errno.h>
#include <asm/io.h>
#include <asm/gpio.h>

#define GPJ_CON 0xE0200280
#define GPJ_DAT 0xE0200284

void tiny210_early_debug(int debug_code)
{
	if(debug_code > 0xf)
		debug_code = 0;
	writel(0x1111, GPJ_CON);
	writel(~(~0&debug_code), 0xE0200284);
}


#ifdef CONFIG_SPL_BUILD
void board_init_f(ulong bootflag)
{
	tiny210_early_debug(1);
}
#endif

int board_early_init_f(void)
{

	return 0;
}

int board_init(void)
{
	return 0;
}

void lowlevel_init(void)
{

}

int dram_init(void)
{
	return 0;
}

struct serial_device *default_serial_console(void)
{
	return NULL;
}

int board_run_command(const char *cmdline)
{
	printf("## Commands are disabled. Please enable CONFIG_CMDLINE.\n");
	return 1;
}

int board_nand_init(struct nand_chip *chip)
{
	return 0;
}
