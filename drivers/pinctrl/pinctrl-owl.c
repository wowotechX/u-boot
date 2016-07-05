/*
 * Copyright (c) 2015 wowotech
 *
 * wowo<wowo@wowotech.net>
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */

#define DEBUGX

#include <common.h>
#include <asm/io.h>
#include <dm/device.h>
#include <dm/pinctrl.h>

DECLARE_GLOBAL_DATA_PTR;

struct owl_pinctrl_priv {
	fdt_addr_t		base;	/* register address */
};

static int owl_pinctrl_set_state_simple(struct udevice *dev,
					struct udevice *periph)
{
	int entry, count, i;
	uint32_t cell[20];
	struct owl_pinctrl_priv *priv = dev_get_priv(dev);

	entry = fdtdec_lookup_phandle(gd->fdt_blob, periph->of_offset,
				      "pinctrl-0");
	if (entry < 0)
		return -1;

	count = fdtdec_get_int_array_count(gd->fdt_blob, entry, "actions,pins",
					   cell, ARRAY_SIZE(cell));
	if (count < 4)
		return -1;

	for (i = 0; i < count / 4; i += 4)
		clrsetbits_le32(priv->base + cell[i],
				cell[i + 2] << cell[i + 1],
				cell[i + 3] << cell[i + 1]);

	return 0;
}

static const struct pinctrl_ops owl_pinctrl_ops = {
	.set_state_simple = owl_pinctrl_set_state_simple,
};

static int owl_pinctrl_probe(struct udevice *dev)
{
	struct owl_pinctrl_priv *priv = dev_get_priv(dev);

	priv->base = fdtdec_get_addr(gd->fdt_blob, dev->of_offset, "reg");
	if (priv->base == FDT_ADDR_T_NONE)
		return -1;

	debug("%s: base is 0x%llx\n", __func__, priv->base);

	return 0;
}


static const struct udevice_id owl_pinctrl_match[] = {
	{ .compatible = "actions,s900-pinctrl" },
	{ /* sentinel */ }
};

U_BOOT_DRIVER(owl_pinctrl) = {
	.name		= "owl_pinctrl",
	.id		= UCLASS_PINCTRL,
	.of_match	= owl_pinctrl_match,
	.probe		= owl_pinctrl_probe,
	.ops		= &owl_pinctrl_ops,
	.flags		= DM_FLAG_PRE_RELOC,
	.priv_auto_alloc_size = sizeof(struct owl_pinctrl_priv),
};
