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

#define TEST_LED_GPIO	(19)

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

struct mm_region *mem_map = bubblegum_mem_map;

#ifdef CONFIG_SPL_BUILD

void board_init_f(ulong bootflag)
{
	writel(readl(GPIOA_OUTEN) | (1 << TEST_LED_GPIO), GPIOA_OUTEN);
	writel(readl(GPIOA_OUTDAT) | (1 << TEST_LED_GPIO), GPIOA_OUTDAT);
	while (1);
}

void panic(const char *fmt, ...)
{
}
#endif

void reset_cpu(ulong addr)
{
}

int dram_init(void)
{
}

int board_init(void)
{
}

struct serial_device *default_serial_console(void)
{
	return NULL;
}
