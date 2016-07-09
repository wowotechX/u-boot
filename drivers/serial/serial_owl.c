/*
 * (C) Copyright 2016 wowotech
 *
 * Refers to "https://github.com/96boards-bubblegum/u-boot/blob/
 *	bubblegum96-2015.07/drivers/serial/serial_owl.c"
 *
 * wowo<wowo@wowotech.net>
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */

#include <common.h>
#include <dm.h>
#include <errno.h>
#include <fdtdec.h>
#include <serial.h>

struct owl_serial_priv {
	fdt_addr_t		base;	/* register address */
};

DECLARE_GLOBAL_DATA_PTR;

/* TODO, we need pinmux, device tree, clock framework, etc. */
//#define USING_UART2

#define HOSC_FREQ		(24000000)

#define CMU_DEVCLKEN1		(0xE01600A4)
#define CMU_DEVRST1		(0xE01600AC)
#define CMU_UART2CLK		(0xE0160064)
#define CMU_UART5CLK		(0xE01600B8)

#define MFP_CTL1		(0xE01B0044)

#define UART2_BASE		(0xE0124000)
#define UART5_BASE		(0xE012a000)

/* UART	Register offset	*/
#define	UART_CTL		(0x0)
#define	UART_RXDAT		(0x4)
#define	UART_TXDAT		(0x8)
#define	UART_STAT		(0xc)

/* UART_CTL */
#define	UART_CTL_EN		(0x1 <<	15)	/* UART enable */
#define	UART_CTL_AFC		(0x1 <<	12)	/* Auto flow control */
#define	UART_CTL_PARITY		(0x7 <<	4)	/* Parity */
#define	UART_CTL_STOP		(0x1 <<	2)	/* stop bit */
#define	UART_CTL_DATA_WIDTH	(0x3 <<	0)	/* Data width */

#define UART_PARITY_NONE	(0)
#define UART_PARITY_ODD		(4)
#define UART_PARITY_LOGIC1	(5)
#define UART_PARITY_EVEN	(6)
#define UART_PARITY_LOGIC0	(7)

#define UART_DATA_WIDTH_5	(0)
#define UART_DATA_WIDTH_6	(1)
#define UART_DATA_WIDTH_7	(2)
#define UART_DATA_WIDTH_8	(3)

/* UART_STAT */
#define	UART_STAT_TFES		(0x1 <<	10)	/* TX FIFO Empty Status	*/
#define	UART_STAT_RFFS		(0x1 <<	9)	/* RX FIFO full	Status */
#define	UART_STAT_TFFU		(0x1 <<	6)	/* TX FIFO full	Status */
#define	UART_STAT_RFEM		(0x1 <<	5)	/* RX FIFO Empty Status	*/

int owl_serial_setbrg(struct udevice *dev, int baudrate)
{
	int divider;
	struct owl_serial_priv *priv = dev_get_priv(dev);

	divider = (115200 * 8);
	divider = (HOSC_FREQ + divider / 2) / divider;
	if (divider > 0)
		divider--;

#ifdef USING_UART2
	clrsetbits_le32(CMU_UART2CLK, 0x1f, divider);
#else
	clrsetbits_le32(CMU_UART5CLK, 0x1f, divider);
#endif

	/*
	 * 8N1
	 */
	clrsetbits_le32(priv->base + UART_CTL, UART_CTL_DATA_WIDTH,
			UART_DATA_WIDTH_8);
	clrsetbits_le32(priv->base + UART_CTL, UART_CTL_PARITY,
			UART_PARITY_NONE);
	clrbits_le32(priv->base + UART_CTL, UART_CTL_STOP);

	return 0;
}

static int owl_serial_getc(struct udevice *dev)
{
	struct owl_serial_priv *priv = dev_get_priv(dev);

	if (readl(priv->base + UART_STAT) & UART_STAT_RFEM)
		return -EAGAIN;

	return (int)(readl(priv->base + UART_RXDAT));
}

static int owl_serial_putc(struct udevice *dev,	const char ch)
{
	struct owl_serial_priv *priv = dev_get_priv(dev);

	if (readl(priv->base + UART_STAT) & UART_STAT_TFFU)
		return -EAGAIN;

	writel(ch, priv->base + UART_TXDAT);

	return 0;
}

static int owl_serial_pending(struct udevice *dev, bool	input)
{
	struct owl_serial_priv *priv = dev_get_priv(dev);
	unsigned int stat = readl(priv->base + UART_STAT);

	if (input)
		return !(stat &	UART_STAT_RFEM);
	else
		return !(stat &	UART_STAT_TFES);
}

extern void bubblegum_early_debug(int debug_code);
static int owl_serial_probe(struct udevice *dev)
{
	struct owl_serial_priv *priv = dev_get_priv(dev);

	priv->base = fdtdec_get_addr(gd->fdt_blob, dev->of_offset, "reg");
	if (priv->base == FDT_ADDR_T_NONE)
		return -1;

	debug("%s: base is 0x%llx\n", __func__, priv->base);


	/* device clock enable */
#ifdef USING_UART2
	setbits_le32(CMU_DEVCLKEN1, 1 << 8);	/* uart2 */
#else
	setbits_le32(CMU_DEVCLKEN1, 1 << 21);	/* uart5 */
#endif

	/* reset de-assert */
#ifdef USING_UART2
	setbits_le32(CMU_DEVRST1, 1 << 7);
#else
	setbits_le32(CMU_DEVRST1, 1 << 17);
#endif

	/* set default baudrate and enable UART */
	owl_serial_setbrg(dev, 115200);
	
	/* enable uart */
	setbits_le32(priv->base + UART_CTL, UART_CTL_EN);

	bubblegum_early_debug(8);
	return 0;
}

static const struct dm_serial_ops owl_serial_ops = {
	.putc =	owl_serial_putc,
	.pending = owl_serial_pending,
	.getc =	owl_serial_getc,
	.setbrg	= owl_serial_setbrg,
};

static const struct udevice_id owl_serial_ids[] = {
	{ .compatible = "actions,s900-serial", },
	{ }
};

U_BOOT_DRIVER(serial_owl) = {
	.name	= "serial_owl",
	.id	= UCLASS_SERIAL,
	.of_match = owl_serial_ids,
	.probe = owl_serial_probe,
	.ops	= &owl_serial_ops,
	.flags = DM_FLAG_PRE_RELOC,
	.priv_auto_alloc_size = sizeof(struct owl_serial_priv),
};
