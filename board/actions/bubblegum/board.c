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

DECLARE_GLOBAL_DATA_PTR;

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

static void reboot_to_adfu(void)
{
	void (*call_adfu)(void);

	//call_adfu = (void (*)(void))0xffff5a00;
	call_adfu = (void (*)(void))0xffff0400;

	call_adfu();
	while (1);
}


/*
 * A simple debug function for early debug, in which,
 * we use four LEDs to display sixteen debug codes, from 0 to 15.
 * Using it, we can know, at least roughly, at where out code is run.
 */
void bubblegum_early_debug(int debug_code)
{
	uint8_t val;

	val = debug_code & 0x1;
	setbits_le32(GPIOA_OUTEN, 1 << DEBUG_LED0_GPIO);
	clrsetbits_le32(GPIOA_OUTDAT, 1 << DEBUG_LED0_GPIO,
			val << DEBUG_LED0_GPIO);

	val = (debug_code >> 1) & 0x1;
	setbits_le32(GPIOA_OUTEN, 1 << DEBUG_LED1_GPIO);
	clrsetbits_le32(GPIOA_OUTDAT, 1 << DEBUG_LED1_GPIO,
			val << DEBUG_LED1_GPIO);

	val = (debug_code >> 2) & 0x1;
	setbits_le32(GPIOF_OUTEN, 1 << DEBUG_LED2_GPIO);
	clrsetbits_le32(GPIOF_OUTDAT, 1 << DEBUG_LED2_GPIO,
			val << DEBUG_LED2_GPIO);

	val = (debug_code >> 3) & 0x1;
	setbits_le32(GPIOF_OUTEN, 1 << DEBUG_LED3_GPIO);
	clrsetbits_le32(GPIOF_OUTDAT, 1 << DEBUG_LED3_GPIO,
			val << DEBUG_LED3_GPIO);
}

struct mm_region *mem_map = bubblegum_mem_map;

#ifdef CONFIG_SPL_BUILD
void board_init_f(ulong bootflag)
{
	bubblegum_early_debug(1);

#ifdef HAS_DDR_SOURCE_CODE
	s900_ddr_init();
#endif

	reboot_to_adfu();
}

void panic(const char *fmt, ...)
{
}
#endif

int board_early_init_f(void)
{
	bubblegum_early_debug(1);
	//while (1);

	return 0;
}

int board_init(void)
{
	bubblegum_early_debug(2);
	return 0;
}

struct serial_device *default_serial_console(void)
{
	return NULL;
}

void reset_cpu(ulong addr)
{
}

extern void s900_ddr_init(void);
int dram_init(void)
{
	printf("dram_init\n");

	bubblegum_early_debug(11);

	/* no need do dram init in here, we have done it in SPL */

	gd->ram_size = 2 * 1024 * 1024 * 1024;	/* 2GB, TODO */

	printf("dram_init OK\n");
	return 0;
}

#if defined(CONFIG_SYS_DRAM_TEST)
int testdram (void)
{
	uint32_t *pstart = (uint32_t *) CONFIG_SYS_MEMTEST_START;
	uint32_t *pend = (uint32_t *) CONFIG_SYS_MEMTEST_END;
	uint32_t *p;

	printf("SDRAM test phase 1:\n");
	for (p = pstart; p < pend; p++)
		*p = 0xaaaaaaaa;

	for (p = pstart; p < pend; p++) {
		if (*p != 0xaaaaaaaa)
			printf ("SDRAM test fails at: %08x=%08x\n", (uint32_t) p, *p);
	}

	printf("SDRAM test phase 2:\n");
	for (p = pstart; p < pend; p++)
		*p = 0x55555555;

	for (p = pstart; p < pend; p++) {
		if (*p != 0x55555555)
			printf ("SDRAM test fails at: %08x=%08x\n", (uint32_t) p, *p);
	}

	printf("SDRAM test passed.\n");
	return 0;
}
#endif

int board_run_command(const char *cmdline)
{
	printf("## Commands are disabled. Please enable CONFIG_CMDLINE.\n");

	return 1;
}
