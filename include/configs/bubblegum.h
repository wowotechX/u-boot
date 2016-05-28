/*
 * (C) Copyright 2016 wowotech
 *
 * wowo<wowo@wowotech.net>
 *
 * Configuration for Bubblegum 96boards.
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */
#ifndef __BUBBLEGUM_H
#define __BUBBLEGUM_H

/* share ram start+header */
#define CONFIG_SPL_TEXT_BASE		0xe406b200
#define CONFIG_SPL_MAX_SIZE		(1024 * 20)

#define CONFIG_SPL_STACK		0xe407f000

#define CONFIG_SPL_BSS_START_ADDR	0xe4068400
#define CONFIG_SPL_BSS_MAX_SIZE		0x00004000	/* 16 KB */

/* SDRAM Definitions */
#define CONFIG_SYS_SDRAM_BASE		0x0
#define CONFIG_NR_DRAM_BANKS		1

/* Link Definitions */
#define CONFIG_SYS_TEXT_BASE		0x11000000
#define CONFIG_SYS_INIT_SP_ADDR		(CONFIG_SYS_SDRAM_BASE + 0x7ff00)

/* Some commands use this as the default load address */
#define CONFIG_SYS_LOAD_ADDR		(CONFIG_SYS_SDRAM_BASE + 0x7ffc0)


/* Generic Interrupt Controller Definitions */
#define GICD_BASE			(0xe00f1000)
#define GICC_BASE			(0xe00f2000)

/* Do not preserve environment */
#define CONFIG_ENV_IS_NOWHERE		1
#define CONFIG_ENV_SIZE			0x1000	/* 4K Bytes */

/* Size of malloc() pool */
#define CONFIG_SYS_MALLOC_LEN		(32 * 1024 * 1024 + CONFIG_ENV_SIZE)

#define CONFIG_SYS_CBSIZE		512	/* Console I/O Buffer Size */
#define CONFIG_SYS_MAXARGS		16	/* max command args */


/* UART Definitions */
#define CONFIG_BAUDRATE			115200

/* FLASH and environment organization */
#define CONFIG_SYS_NO_FLASH

#endif
