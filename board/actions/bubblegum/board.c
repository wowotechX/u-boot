/*
 * (C) Copyright 2016 wowotech
 *
 * wowo<wowo@wowotech.net>
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */
#include <common.h>
#include <errno.h>
#include <asm/io.h>
#include <asm/armv8/mmu.h>
#include <serial.h>

#define GPIOA_OUTEN	(0xe01b0000)
#define GPIOA_OUTDAT	(0xe01b0008)
#define DEBUG_LED0_GPIO	(19)	/* GPIOA19 */
#define DEBUG_LED1_GPIO	(20)	/* GPIOA20 */

#define GPIOF_OUTEN	(0xe01b00f0)
#define GPIOF_OUTDAT	(0xe01b00f8)
#define DEBUG_LED2_GPIO	(1)	/* GPIOF1 */
#define DEBUG_LED3_GPIO	(2)	/* GPIOF2 */

static struct mm_region bubblegum_mem_map[] = {
	{
		.base = 0x0UL,
		.size = 0x80000000UL,
		.attrs = PTE_BLOCK_MEMTYPE(MT_NORMAL) |
			 PTE_BLOCK_INNER_SHARE
	}, {
		.base = 0x80000000UL,
		.size = 0x80000000UL,
		.attrs = PTE_BLOCK_MEMTYPE(MT_DEVICE_NGNRNE) |
			 PTE_BLOCK_NON_SHARE |
			 PTE_BLOCK_PXN | PTE_BLOCK_UXN
	}, {
		/* List terminator */
		0,
	}
};

/*
 * A simple debug function for early debug, in which,
 * we use four LEDs to display sixteen debug codes, from 0 to 15.
 * Using it, we can know, at least roughly, at where out code is run.
 */
static void bubblegum_early_debug(int debug_code)
{
	uint8_t val;

	val = debug_code & 0x1;
	writel(readl(GPIOA_OUTEN) | (1 << DEBUG_LED0_GPIO), GPIOA_OUTEN);
	writel(readl(GPIOA_OUTDAT) | (val << DEBUG_LED0_GPIO), GPIOA_OUTDAT);

	val = (debug_code >> 1) & 0x1;
	writel(readl(GPIOA_OUTEN) | (1 << DEBUG_LED1_GPIO), GPIOA_OUTEN);
	writel(readl(GPIOA_OUTDAT) | (val << DEBUG_LED1_GPIO), GPIOA_OUTDAT);

	val = (debug_code >> 2) & 0x1;
	writel(readl(GPIOF_OUTEN) | (1 << DEBUG_LED2_GPIO), GPIOF_OUTEN);
	writel(readl(GPIOF_OUTDAT) | (val << DEBUG_LED2_GPIO), GPIOF_OUTDAT);

	val = (debug_code >> 3) & 0x1;
	writel(readl(GPIOF_OUTEN) | (1 << DEBUG_LED3_GPIO), GPIOF_OUTEN);
	writel(readl(GPIOF_OUTDAT) | (val << DEBUG_LED3_GPIO), GPIOF_OUTDAT);
}

struct mm_region *mem_map = bubblegum_mem_map;

#ifdef CONFIG_SPL_BUILD
void board_init_f(ulong bootflag)
{
	bubblegum_early_debug(1);
	while (1);
}

void panic(const char *fmt, ...)
{
}
#endif

int board_early_init_f(void)
{
	bubblegum_early_debug(1);
	while (1);

	return 0;
}

int board_init(void)
{
	return 0;
}

struct serial_device *default_serial_console(void)
{
	return NULL;
}

void reset_cpu(ulong addr)
{
}

int dram_init(void)
{
	return 0;
}
