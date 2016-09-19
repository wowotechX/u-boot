/*
 *  armboot - Memory Initialize Code for S5PV210/ARM-Cortex CPU-core
 *
 *  Copyright (c) 2009  Samsung Electronics
 *
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 *
 * Base codes by scsuh  (sc.suh)
 * Modified By JhoonKim (jhoon_kim@nate.com), aESOP Embedded Forum(http://www.aesop.or.kr)
 * 10.08.15 - To Supported for SEC K4T1G164QX DDR2 Memory for aESOP S5PV210
 */

#include <config.h>
#include <s5pc110.h>

	.globl mem_ctrl_asm_init
mem_ctrl_asm_init:

#ifndef CONFIG_EVT1

	ldr     r0, =ASYNC_MSYS_DMC0_BASE

	ldr     r1, =0x0
	str     r1, [r0, #0x0]

	/* This register is removed at EVT1 of C110. */
	ldr     r1, =0x0
	str     r1, [r0, #0xC]

#endif

#ifdef CONFIG_MCP_SINGLE

	/* DMC0 Drive Strength (Setting 2X) */

	ldr	r0, =ELFIN_GPIO_BASE

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_0DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_1DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_2DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_3DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_4DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_5DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_6DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP1_7DRV_SR_OFFSET]

	ldr	r1, =0x00002AAA
	str	r1, [r0, #MP1_8DRV_SR_OFFSET]


	/* DMC1 Drive Strength (Setting 2X) */

	ldr	r0, =ELFIN_GPIO_BASE

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_0DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_1DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_2DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_3DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_4DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_5DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_6DRV_SR_OFFSET]

	ldr	r1, =0x0000AAAA
	str	r1, [r0, #MP2_7DRV_SR_OFFSET]

	ldr	r1, =0x00002AAA
	str	r1, [r0, #MP2_8DRV_SR_OFFSET]

	/* DMC0 initialization at single Type*/
	ldr	r0, =APB_DMC_0_BASE

	ldr	r1, =0x00101000				@PhyControl0 DLL parameter setting, manual 0x00101000
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00000086				@PhyControl1 DLL parameter setting, LPDDR/LPDDR2 Case
	str	r1, [r0, #DMC_PHYCONTROL1]

	ldr	r1, =0x00101002				@PhyControl0 DLL on
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00101003				@PhyControl0 DLL start
	str	r1, [r0, #DMC_PHYCONTROL0]

find_lock_val:
	ldr	r1, [r0, #DMC_PHYSTATUS]		@Load Phystatus register value
	and	r2, r1, #0x7
	cmp	r2, #0x7				@Loop until DLL is locked
	bne	find_lock_val

	and	r1, #0x3fc0
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2 ,r2, #0x1000

	orr	r1, r2, #0x3				@Force Value locking
	str	r1, [r0, #DMC_PHYCONTROL0]

#if 0	/* Memory margin test 10.01.05 */
	orr	r1, r2, #0x1				@DLL off
	str	r1, [r0, #DMC_PHYCONTROL0]
#endif
	/* setting DDR2 */
	ldr	r1, =0x0FFF2010				@ConControl auto refresh off
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =DMC0_MEMCONTROL			@MemControl BL=4, 1 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #DMC_MEMCONTROL]

	ldr	r1, =DMC0_MEMCONFIG_0			@MemConfig0 256MB config, 8 banks,Mapping Method[12:15]0:linear, 1:linterleaved, 2:Mixed
	str	r1, [r0, #DMC_MEMCONFIG0]

	ldr	r1, =DMC0_MEMCONFIG_1			@MemConfig1
	str	r1, [r0, #DMC_MEMCONFIG1]

	ldr	r1, =0xFF000000				@PrechConfig
	str	r1, [r0, #DMC_PRECHCONFIG]

	ldr	r1, =DMC0_TIMINGA_REF			@TimingAref	7.8us*133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4E)
	str	r1, [r0, #DMC_TIMINGAREF]

	ldr	r1, =DMC0_TIMING_ROW			@TimingRow	for @200MHz
	str	r1, [r0, #DMC_TIMINGROW]

	ldr	r1, =DMC0_TIMING_DATA			@TimingData	CL=4
	str	r1, [r0, #DMC_TIMINGDATA]

	ldr	r1, =DMC0_TIMING_PWR			@TimingPower
	str	r1, [r0, #DMC_TIMINGPOWER]

	ldr	r1, =0x07000000				@DirectCmd	chip0 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00020000				@DirectCmd	chip0 EMRS2
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00030000				@DirectCmd	chip0 EMRS3
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00000542				@DirectCmd	chip0 MRS (MEM DLL reset) CL=4, BL=4
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00000442				@DirectCmd	chip0 MRS (MEM DLL unreset)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00010780				@DirectCmd	chip0 EMRS1 (OCD default)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (OCD exit)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x07100000				@DirectCmd	chip1 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00120000				@DirectCmd	chip1 EMRS2
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00130000				@DirectCmd	chip1 EMRS3
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00110400				@DirectCmd	chip1 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00100542				@DirectCmd	chip1 MRS (MEM DLL reset) CL=4, BL=4
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00100442				@DirectCmd	chip1 MRS (MEM DLL unreset)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00110780				@DirectCmd	chip1 EMRS1 (OCD default)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00110400				@DirectCmd	chip1 EMRS1 (OCD exit)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x0FF02030				@ConControl	auto refresh on
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =0xFFFF00FF				@PwrdnConfig
	str	r1, [r0, #DMC_PWRDNCONFIG]

	ldr	r1, =0x00202400				@MemControl	BL=4, 1 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #DMC_MEMCONTROL]

	/* DMC1 initialization */
	ldr	r0, =APB_DMC_1_BASE

	ldr	r1, =0x00101000				@Phycontrol0 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00000086				@Phycontrol1 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL1]

	ldr	r1, =0x00101002				@PhyControl0 DLL on
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00101003				@PhyControl0 DLL start
	str	r1, [r0, #DMC_PHYCONTROL0]
find_lock_val1:
	ldr	r1, [r0, #DMC_PHYSTATUS]		@Load Phystatus register value
	and	r2, r1, #0x7
	cmp	r2, #0x7				@Loop until DLL is locked
	bne	find_lock_val1

	and	r1, #0x3fc0
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2, r2, #0x1000

	orr	r1, r2, #0x3				@Force Value locking
	str	r1, [r0, #DMC_PHYCONTROL0]

#if 0	/* Memory margin test 10.01.05 */
	orr	r1, r2, #0x1				@DLL off
	str	r1, [r0, #DMC_PHYCONTROL0]
#endif

	/* settinf fot DDR2 */
	ldr	r0, =APB_DMC_1_BASE

	ldr	r1, =0x0FFF2010				@auto refresh off
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =DMC1_MEMCONTROL			@MemControl	BL=4, 2 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #DMC_MEMCONTROL]

	ldr	r1, =DMC1_MEMCONFIG_0			@MemConfig0	512MB config, 8 banks,Mapping Method[12:15]0:linear, 1:linterleaved, 2:Mixed
	str	r1, [r0, #DMC_MEMCONFIG0]

	ldr	r1, =DMC1_MEMCONFIG_1			@MemConfig1
	str	r1, [r0, #DMC_MEMCONFIG1]

	ldr	r1, =0xFF000000
	str	r1, [r0, #DMC_PRECHCONFIG]

	ldr	r1, =DMC1_TIMINGA_REF			@TimingAref	7.8us*133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4
	str	r1, [r0, #DMC_TIMINGAREF]

	ldr	r1, =DMC1_TIMING_ROW			@TimingRow	for @200MHz
	str	r1, [r0, #DMC_TIMINGROW]

	ldr	r1, =DMC1_TIMING_DATA			@TimingData	CL=3
	str	r1, [r0, #DMC_TIMINGDATA]

	ldr	r1, =DMC1_TIMING_PWR			@TimingPower
	str	r1, [r0, #DMC_TIMINGPOWER]


	ldr	r1, =0x07000000				@DirectCmd	chip0 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00020000				@DirectCmd	chip0 EMRS2
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00030000				@DirectCmd	chip0 EMRS3
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00000542				@DirectCmd	chip0 MRS (MEM DLL reset) CL=4, BL=4
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00000442				@DirectCmd	chip0 MRS (MEM DLL unreset)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00010780				@DirectCmd	chip0 EMRS1 (OCD default)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (OCD exit)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x07100000				@DirectCmd	chip1 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00120000				@DirectCmd	chip1 EMRS2
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00130000				@DirectCmd	chip1 EMRS3
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00110440				@DirectCmd	chip1 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00100542				@DirectCmd	chip1 MRS (MEM DLL reset) CL=4, BL=4
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00100442				@DirectCmd	chip1 MRS (MEM DLL unreset)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00110780				@DirectCmd	chip1 EMRS1 (OCD default)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00110400				@DirectCmd	chip1 EMRS1 (OCD exit)
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x0FF02030				@ConControl	auto refresh on
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =0xFFFF00FF				@PwrdnConfig
	str	r1, [r0, #DMC_PWRDNCONFIG]

	ldr	r1, =DMC1_MEMCONTROL			@MemControl	BL=4, 2 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #DMC_MEMCONTROL]

#else	/* CONFIG_MCP_SINGLE */

	/* DMC0 initialization */
	ldr	r0, =APB_DMC_0_BASE

	ldr	r1, =0x00101000				@Phycontrol0 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00000084				@Phycontrol1 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL1]

	ldr	r1, =0x00101002				@Phycontrol2 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00101003				@Dll on
	str	r1, [r0, #DMC_PHYCONTROL0]

find_lock_val:
	ldr	r1, [r0, #DMC_PHYSTATUS]		@Load Phystatus register value
	and 	r2, r1, #0x7
	cmp	r2, #0x7				@Loop until DLL is locked
	bne	find_lock_val

	and	r1, #0x3fc0
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2, r2, #0x1000

	orr	r1, r2, #0x3				@Force Value locking
	str	r1, [r0, #DMC_PHYCONTROL0]
#if 1 /* DRAM margin test 10.01.06 */
	orr	r1, r2, #0x1				@DLL off
	str	r1, [r0, #DMC_PHYCONTROL0]
#endif
	ldr	r1, =0x0fff1010				@auto refresh off
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =0x00212100
	str	r1, [r0, #DMC_MEMCONTROL]

	ldr	r1, =DMC0_MEMCONFIG_0
	str	r1, [r0, #DMC_MEMCONFIG0]

	ldr	r1, =DMC0_MEMCONFIG_1
	str	r1, [r0, #DMC_MEMCONFIG1]

	ldr	r1, =0xff000000
	str	r1, [r0, #DMC_PRECHCONFIG]

	ldr	r1, =DMC0_TIMINGA_REF
	str	r1, [r0, #DMC_TIMINGAREF]

	ldr	r1, =DMC0_TIMING_ROW			@TimingRow	@133MHz
	str	r1, [r0, #DMC_TIMINGROW]

	ldr	r1, =DMC0_TIMING_DATA
	str	r1, [r0, #DMC_TIMINGDATA]

	ldr	r1, =DMC0_TIMING_PWR			@Timing Power
	str	r1, [r0, #DMC_TIMINGPOWER]

	ldr	r1, =0x07000000				@chip0 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01000000				@chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00000032				@chip0 MRS
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x07100000				@chip1 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01100000				@chip1 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05100000				@chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05100000				@chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00100032				@chip1 MRS
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x0FFF20B0			@ConControl auto refresh on
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =0xFFFF00FF				@PwrdnConfig
	str	r1, [r0, #DMC_PWRDNCONFIG]

	ldr	r1, =0x00212113				@MemControl
	str	r1, [r0, #DMC_MEMCONTROL]

/* DMC1 initialization */
	ldr	r0, =APB_DMC_1_BASE

	ldr	r1, =0x00101000				@Phycontrol0 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00000084				@Phycontrol1 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL1]

	ldr	r1, =0x00101002				@Phycontrol2 DLL parameter setting
	str	r1, [r0, #DMC_PHYCONTROL0]

	ldr	r1, =0x00101003				@Dll on
	str	r1, [r0, #DMC_PHYCONTROL0]

find_lock_val1:
	ldr	r1, [r0, #DMC_PHYSTATUS]		@Load Phystatus register value
	and 	r2, r1, #0x7
	cmp	r2, #0x7				@Loop until DLL is locked
	bne	find_lock_val1

	and	r1, #0x3fc0
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2, r2, #0x1000

	orr	r1, r2, #0x3				@Force Value locking
	str	r1, [r0, #DMC_PHYCONTROL0]

#if 1	/* Memory margin test 10.01.05 */
	orr	r1, r2, #0x1				@DLL off
	str	r1, [r0, #DMC_PHYCONTROL0]
#endif
	ldr	r0, =APB_DMC_1_BASE

	ldr	r1, =0x0FFF1010				@auto refresh off
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =0x00212100
	str	r1, [r0, #DMC_MEMCONTROL]

	ldr	r1, =DMC1_MEMCONFIG_0
	str	r1, [r0, #DMC_MEMCONFIG0]

	ldr	r1, =DMC1_MEMCONFIG_1
	str	r1, [r0, #DMC_MEMCONFIG1]

	ldr	r1, =0xff000000
	str	r1, [r0, #DMC_PRECHCONFIG]

	ldr	r1, =DMC1_TIMINGA_REF
	str	r1, [r0, #DMC_TIMINGAREF]

	ldr	r1, =DMC1_TIMING_ROW			@TimingRow	@133MHz
	str	r1, [r0, #DMC_TIMINGROW]

	ldr	r1, =DMC1_TIMING_DATA
	str	r1, [r0, #DMC_TIMINGDATA]

	ldr	r1, =DMC1_TIMING_PWR			@Timing Power
	str	r1, [r0, #DMC_TIMINGPOWER]

	ldr	r1, =0x07000000				@chip0 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01000000				@chip0 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05000000				@chip0 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00000032				@chip0 MRS
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00020020				@chip0 EMRS
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x07100000				@chip1 Deselect
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x01100000				@chip1 PALL
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05100000				@chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x05100000				@chip1 REFA
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00100032				@chip1 MRS
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x00120020				@chip0 EMRS
	str	r1, [r0, #DMC_DIRECTCMD]

	ldr	r1, =0x0FFF10B0				@ConControl auto refresh on
	str	r1, [r0, #DMC_CONCONTROL]

	ldr	r1, =0xFFFF00FF				@PwrdnConfig
	str	r1, [r0, #DMC_PWRDNCONFIG]

	ldr	r1, =0x00212113				@MemControl
	str	r1, [r0, #DMC_MEMCONTROL]

#endif	/* CONFIG_MCP_AC / CONFIG_MCP_H / CONFIG_MCP_B / CONFIG_MCP_D */

	mov	pc, lr


/* Below code is for ARM926EJS and ARM1026EJS */
	.globl cleanDCache
cleanDCache:
	mrc	p15, 0, pc, c7, c10, 3	/* test/clean D-Cache */
	bne	cleanDCache
	mov	pc, lr

	.globl cleanFlushDCache
cleanFlushDCache:
	mrc	p15, 0, pc, c7, c14, 3	/* test/cleanflush D-Cache */
	bne	cleanFlushDCache
	mov	pc, lr

	.globl cleanFlushCache
cleanFlushCache:
	mrc	p15, 0, pc, c7, c14, 3	/* test/cleanflush D-Cache */
	bne	cleanFlushCache
	mcr	p15, 0, r0, c7, c5, 0	/* flush I-Cache */
	mov	pc, lr

	.ltorg


/*
 *     v7_flush_dcache_all()
 *
 *     Flush the whole D-cache.
 *
 *     Corrupted registers: r0-r5, r7, r9-r11
 *
 *     - mm    - mm_struct describing address space
 */
       .align 5
/* .global v7_flush_dcache_all *///please fix me !!!
v7_flush_dcache_all:

        ldr     r0, =0xffffffff
        mrc     p15, 1, r0, c0, c0, 1           @ Read CLIDR
        ands    r3, r0, #0x7000000
        mov     r3, r3, LSR #23                 @ Cache level value (naturally aligned)
        beq     Finished
        mov     r10, #0
Loop1:
        add     r2, r10, r10, LSR #1            @ Work out 3xcachelevel
        mov     r1, r0, LSR r2                  @ bottom 3 bits are the Ctype for this level
        and     r1, r1, #7                      @ get those 3 bits alone
        cmp     r1, #2
        blt     Skip                            @ no cache or only instruction cache at this level
        mcr     p15, 2, r10, c0, c0, 0          @ write the Cache Size selection register
        mov     r1, #0
        mcr     p15, 0, r1, c7, c5, 4           @ PrefetchFlush to sync the change to the CacheSizeID reg
        mrc     p15, 1, r1, c0, c0, 0           @ reads current Cache Size ID register
        and     r2, r1, #0x7                    @ extract the line length field
        add     r2, r2, #4                      @ add 4 for the line length offset (log2 16 bytes)
        ldr     r4, =0x3FF
        ands    r4, r4, r1, LSR #3              @ R4 is the max number on the way size (right aligned)
        clz     r5, r4                          @ R5 is the bit position of the way size increment
        ldr     r7, =0x00007FFF
        ands    r7, r7, r1, LSR #13             @ R7 is the max number of the index size (right aligned)
Loop2:
        mov     r9, r4                          @ R9 working copy of the max way size (right aligned)
Loop3:
        orr     r11, r10, r9, LSL r5            @ factor in the way number and cache number into R11
        orr     r11, r11, r7, LSL r2            @ factor in the index number
        mcr     p15, 0, r11, c7, c6, 2          @ invalidate by set/way
        subs    r9, r9, #1                      @ decrement the way number
        bge     Loop3
        subs    r7, r7, #1                      @ decrement the index
        bge     Loop2
Skip:
        add     r10, r10, #2                    @ increment the cache number
        cmp     r3, r10
        bgt     Loop1
Finished:
        mov     pc, lr

	.align  5
.global disable_l2cache
disable_l2cache:
        mrc     p15, 0, r0, c1, c0, 1
        bic     r0, r0, #(1<<1)
        mcr     p15, 0, r0, c1, c0, 1
        mov     pc, lr


       .align  5
.global enable_l2cache
enable_l2cache:
        mrc     p15, 0, r0, c1, c0, 1
        orr     r0, r0, #(1<<1)
        mcr     p15, 0, r0, c1, c0, 1
        mov     pc, lr

       .align  5
.global set_l2cache_auxctrl
set_l2cache_auxctrl:
        mov     r0, #0x0
        mcr     p15, 1, r0, c9, c0, 2
        mov     pc, lr

       .align  5
.global set_l2cache_auxctrl_cycle
set_l2cache_auxctrl_cycle:
        mrc     p15, 1, r0, c9, c0, 2
        bic     r0, r0, #(0x1<<29)
        bic     r0, r0, #(0x1<<21)
        bic     r0, r0, #(0x7<<6)
        bic     r0, r0, #(0x7<<0)
        mcr     p15, 1, r0, c9, c0, 2
        mov     pc,lr

        .align 5
CoInvalidateDCacheIndex:
        ;/* r0 = index */
        mcr     p15, 0, r0, c7, c6, 2
        mov     pc,lr
