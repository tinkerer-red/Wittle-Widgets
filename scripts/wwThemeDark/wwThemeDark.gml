function wwThemeDark() {
	var theme = wwThemeDefault();

	theme.meta = {
		id: "ww_dark",
		name: "Wittle Dark",
		mode: "dark",
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
		accent_color: #4C8DFF,
		lum_factor: 1.0,
		accent_lum: 0.0,
		hue_shift: 0.0,
		sat_mul: 1.0,
		val_mul: 1.0
	};

	theme.palette = {
		n0: #0D0F12,
		n5: #141821,
		n10: #1C2230,
		n20: #2A3345,
		n30: #3B465C,
		n40: #55627A,
		n70: #B3BDD1,
		n90: #E7ECF5,
		n100: #FFFFFF,
		blue: #4C8DFF,
		green: #2ECC71,
		yellow: #F1C40F,
		orange: #F39C12,
		red: #E74C3C,
		purple: #B07CFF
	};

	theme.colors = {
		app: {
			bg: { color: #0D0F12, alpha: 1 },
			bg_alt: { color: #141821, alpha: 1 }
		},
		surface: {
			panel: { color: #141821, alpha: 1 },
			panel_alt: { color: #1C2230, alpha: 1 },
			control: { color: #1C2230, alpha: 1 },
			control_alt: { color: #2A3345, alpha: 1 },
			popup: { color: #141821, alpha: 1 },
			tooltip: { color: #141821, alpha: 0.93 }
		},
		outline: {
			subtle: { color: #2A3345, alpha: 1 },
			normal: { color: #3B465C, alpha: 1 },
			strong: { color: #55627A, alpha: 1 }
		},
		text: {
			primary: { color: #E7ECF5, alpha: 1 },
			secondary: { color: #B3BDD1, alpha: 1 },
			dim: { color: #8A96AD, alpha: 1 },
			disabled: { color: #55627A, alpha: 1 },
			inverse: { color: #0D0F12, alpha: 1 },
			link: { color: #67C3AA, alpha: 1 }
		},
		accent: {
			primary: { color: #4C8DFF, alpha: 1 },
			on_accent: { color: #0D0F12, alpha: 1 },
			subtle: { color: #4C8DFF, alpha: 0.20 }
		},
		state: {
			selection_bg: { color: #4C8DFF, alpha: 0.40 },
			selection_text: { color: #FFFFFF, alpha: 1 },
			success_fg: { color: #2ECC71, alpha: 1 },
			success_bg: { color: #2ECC71, alpha: 0.20 },
			warning_fg: { color: #F1C40F, alpha: 1 },
			warning_bg: { color: #F1C40F, alpha: 0.20 },
			danger_fg: { color: #E74C3C, alpha: 1 },
			danger_bg: { color: #E74C3C, alpha: 0.20 }
		},
		overlay: { modal_shade: { color: #000000, alpha: 0.50 } }
	};

	// Component-level scrollbar paints (used by direct theme keys).
	theme.scrollbar = {
		color: {
			thumb: {
				idle: #55627A,
				hover: #8A96AD,
				active: #B3BDD1,
				nav: #8A96AD,
				disabled: #3B465C
			},
			tray: {
				idle: #141821
			},
			gutter: {
				idle: #141821
			},
			trough: {
				idle: #141821
			},
			button: {
				up: {
					idle: #2A3345,
					hover: #3B465C,
					active: #55627A,
					nav: #3B465C,
					disabled: #1C2230
				},
				down: {
					idle: #2A3345,
					hover: #3B465C,
					active: #55627A,
					nav: #3B465C,
					disabled: #1C2230
				},
				left: {
					idle: #2A3345,
					hover: #3B465C,
					active: #55627A,
					nav: #3B465C,
					disabled: #1C2230
				},
				right: {
					idle: #2A3345,
					hover: #3B465C,
					active: #55627A,
					nav: #3B465C,
					disabled: #1C2230
				}
			}
		},
		alpha: {
			thumb: {
				idle: 0.70,
				hover: 0.85,
				active: 1.00,
				nav: 0.90,
				disabled: 0.45
			},
			tray: {
				idle: 1.00
			},
			gutter: {
				idle: 1.00
			},
			trough: {
				idle: 1.00
			},
			button: {
				up: {
					idle: 1.00,
					hover: 1.00,
					active: 1.00,
					nav: 1.00,
					disabled: 0.45
				},
				down: {
					idle: 1.00,
					hover: 1.00,
					active: 1.00,
					nav: 1.00,
					disabled: 0.45
				},
				left: {
					idle: 1.00,
					hover: 1.00,
					active: 1.00,
					nav: 1.00,
					disabled: 0.45
				},
				right: {
					idle: 1.00,
					hover: 1.00,
					active: 1.00,
					nav: 1.00,
					disabled: 0.45
				}
			}
		}
	};

	return theme;
}
