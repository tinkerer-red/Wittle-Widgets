function wwThemeLight() {
	var theme = wwThemeDefault();

	theme.meta = {
		id: "ww_light",
		name: "Wittle Light",
		mode: "light",
		version: 1,
		author: "",
		description: "",
		tags: ["default"],
		compat: { ww_min: "x.y.z" }
	};

	// Optional: keep derive off unless you plan to use it.
	theme.derive = {
		enabled: false,
		tint_color: #FFFFFF,
		accent_color: #2F6BFF,
		lum_factor: 1.0,
		accent_lum: 0.0,
		hue_shift: 0.0,
		sat_mul: 1.0,
		val_mul: 1.0
	};

	theme.palette = {
		n0: #0B0F17,
		n5: #121826,
		n10: #1B2538,
		n20: #2A3954,
		n30: #445A7A,
		n40: #6B7C96,
		n70: #B7C1D3,
		n90: #F3F6FB,
		n100: #FFFFFF,
		blue: #2F6BFF,
		green: #1F9D55,
		yellow: #B7791F,
		orange: #DD6B20,
		red: #E53E3E,
		purple: #805AD5
	};

	theme.colors = {
		app: {
			bg: { color: #F3F6FB, alpha: 1 },
			bg_alt: { color: #FFFFFF, alpha: 1 }
		},
		surface: {
			panel: { color: #FFFFFF, alpha: 1 },
			panel_alt: { color: #F3F6FB, alpha: 1 },
			control: { color: #FFFFFF, alpha: 1 },
			control_alt: { color: #E8EEF7, alpha: 1 },
			popup: { color: #FFFFFF, alpha: 1 },
			tooltip: { color: #FFFFFF, alpha: 0.95 }
		},
		outline: {
			subtle: { color: #D2DAE6, alpha: 1 },
			normal: { color: #B6C2D3, alpha: 1 },
			strong: { color: #8EA0B8, alpha: 1 }
		},
		text: {
			primary: { color: #0B0F17, alpha: 1 },
			secondary: { color: #2A3954, alpha: 1 },
			dim: { color: #6B7C96, alpha: 1 },
			disabled: { color: #8EA0B8, alpha: 1 },
			inverse: { color: #FFFFFF, alpha: 1 },
			link: { color: #2F6BFF, alpha: 1 }
		},
		accent: {
			primary: { color: #2F6BFF, alpha: 1 },
			on_accent: { color: #FFFFFF, alpha: 1 },
			subtle: { color: #2F6BFF, alpha: 0.20 }
		},
		state: {
			focus_ring: { color: #2F6BFF, alpha: 0.60 },
			selection_bg: { color: #2F6BFF, alpha: 0.20 },
			selection_text: { color: #0B0F17, alpha: 1 },
			success_fg: { color: #1F9D55, alpha: 1 },
			success_bg: { color: #1F9D55, alpha: 0.20 },
			warning_fg: { color: #B7791F, alpha: 1 },
			warning_bg: { color: #B7791F, alpha: 0.20 },
			danger_fg: { color: #E53E3E, alpha: 1 },
			danger_bg: { color: #E53E3E, alpha: 0.20 }
		},
		overlay: { modal_shade: { color: #000000, alpha: 0.30 } }
	};

	return theme;
}