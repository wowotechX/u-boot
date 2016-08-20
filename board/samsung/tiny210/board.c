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

/* Get the global_data point */
DECLARE_GLOBAL_DATA_PTR;

/* led gpio register address */
#define GPJ_CON 0xE0200280
#define GPJ_DAT 0xE0200284

/* the size and addr in emmc of bl1 and bl2 */
#define MOVI_BLKSIZE            (1<<9) /* 512 bytes */
#define MOVI_BL1_SDCARD_POS		512 /* 512 bytes */
#define MOVI_BL1_SIZE           (8 * 1024) /* 8KB */
#define MOVI_BL1_BLKCNT         (MOVI_BL1_SIZE / MOVI_BLKSIZE)        /* 16 sections */
#define MOVI_BL1_ENV_BLKCNT     (CONFIG_ENV_SIZE / MOVI_BLKSIZE)   /* CONFIG_ENV_SIZE defined in tiny210.h, 32 sections */

#define MOVI_BL2_SDCARD_POS		((MOVI_BL1_SDCARD_POS / MOVI_BLKSIZE) + MOVI_BL1_BLKCNT + MOVI_BL1_ENV_BLKCNT) /* place at forty-ninth section in sdcard*/
#define MOVI_BL2_SIZE			(512 * 1024)
#define MOVI_BL2_BLKCNT			(MOVI_BL2_SIZE / MOVI_BLKSIZE)        /* 1024 sections */


/* The point of the addr function "copy_sd_mmc_to_mem" */
#define CopySDMMCtoMem 0xD0037F98
#define SDMMC_BASE    0xD0037488
#define SDMMC_CH0_BASE_ADDR    0xEB000000
#define SDMMC_CH2_BASE_ADDR    0xEB200000

/* the function of copy_sd_mmc_to_mem that have been implement by s5pv210*/
typedef u32(*copy_sd_mmc_to_mem)
		(u32 channel, u32 start_block, u16 block_size, u32 *trg, u32 init);

void copy_bl2_to_ddr(void)
{
	u32 sdmmc_base_addr;
	copy_sd_mmc_to_mem copy_bl2 = (copy_sd_mmc_to_mem)(*(u32*)CopySDMMCtoMem);

	sdmmc_base_addr = *(u32 *)SDMMC_BASE;

	if(sdmmc_base_addr == SDMMC_CH0_BASE_ADDR)
		copy_bl2(0, MOVI_BL2_SDCARD_POS, MOVI_BL2_BLKCNT, (u32 *)CONFIG_SYS_TEXT_BASE, 0);
	if(sdmmc_base_addr == SDMMC_CH2_BASE_ADDR)
		copy_bl2(2, MOVI_BL2_SDCARD_POS, MOVI_BL2_BLKCNT, (u32 *)CONFIG_SYS_TEXT_BASE, 0);
}


void tiny210_early_debug(int debug_code)
{
	if(debug_code > 0xf)
		debug_code = 0;
	writel(0x1111, GPJ_CON);
	writel(~(~0&debug_code), GPJ_DAT);
}

#ifdef CONFIG_SPL_BUILD
void board_init_f(ulong bootflag)
{
	__attribute__((noreturn)) void (*uboot)(void);
	int val;
#define DDR_TEST_ADDR 0x30000000
#define DDR_TEST_CODE 0xaa
	tiny210_early_debug(0x1);
	writel(DDR_TEST_CODE, DDR_TEST_ADDR);
	val = readl(DDR_TEST_ADDR);
	if(val == DDR_TEST_CODE)
		tiny210_early_debug(0x3);
	else
	{
		tiny210_early_debug(0x2);
		while(1);
	}

	copy_bl2_to_ddr();

	uboot = (void *)CONFIG_SYS_TEXT_BASE;
	(*uboot)();
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

int dram_init(void)
{
	gd->ram_size = PHYS_SDRAM_1_SIZE;
	return 0;
}


void dram_init_banksize(void)
{
	gd->bd->bi_dram[0].start = PHYS_SDRAM_1;
	gd->bd->bi_dram[0].size = get_ram_size((long *)PHYS_SDRAM_1,
							PHYS_SDRAM_1_SIZE);
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
