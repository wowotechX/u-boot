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

DECLARE_GLOBAL_DATA_PTR;

#define GPIOA_OUTEN	(0xe01b0000)
#define GPIOA_OUTDAT	(0xe01b0008)
#define DEBUG_LED0_GPIO	(19)	/* GPIOA19 */
#define DEBUG_LED1_GPIO	(20)	/* GPIOA20 */

#define GPIOF_OUTEN	(0xe01b00f0)
#define GPIOF_OUTDAT	(0xe01b00f8)
#define DEBUG_LED2_GPIO	(1)	/* GPIOF1 */
#define DEBUG_LED3_GPIO	(2)	/* GPIOF2 */



#ifdef CONFIG_SPL_BUILD
void board_init_f(ulong bootflag)
{
}

void panic(const char *fmt, ...)
{
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
