function wwThemeGMLight() {
	var theme = {
		meta: {
			id: "ww_gm_light",
			name: "GameMaker Light",
			mode: "light",
			version: 1,
			author: "",
			description: "GameMaker-inspired light palette mapped to Wittle Widgets keyspace.",
			tags: ["gm", "light", "feature_complete"],
			compat: { ww_min: "x.y.z" }
		},

		schema: {
			id: "ww_theme_schema",
			version: 1
		},

		fallback: {
			sprite: spr_ww_pixel,
			color: #FF00FF,
			alpha: 1,
			size: 0,
			icon: -1,
			font: fnt_ww_default_small_msdf
		},

		scale: {
			ui: 1.0,
			text: 1.0,
			spacing: 1.0,
			radius: 1.0,
			outline: 1.0
		},

		units: {
			dpi_scale: 1.0
		},

		derive: {
			enabled: false,
			tint_color: #FFFFFF,
			accent_color: #D0D0D0,
			lum_factor: 1.0,
			accent_lum: 0.0,
			hue_shift: 0.0,
			sat_mul: 1.0,
			val_mul: 1.0
		},

		main_color: #D4D4D4,
		accent_color: #D0D0D0,
		accent_color_2: #DCDCDC,
		accent_color_3: #BEBEBE,

		palette: {
			n0: #202020,
			n5: #4A4A4A,
			n10: #6D6D6D,
			n20: #8A8A8A,
			n30: #A8A8A8,
			n40: #B8B8B8,
			n70: #D4D4D4,
			n90: #EAEAEA,
			n100: #FFFFFF,
			blue: #8A8A8A,
			green: #3C8C54,
			yellow: #B08A2E,
			orange: #C98B55,
			red: #B85C5C,
			purple: #8E77A8
		},

		colors: {
			app: {
				bg: { color: #D4D4D4, alpha: 1 },
				bg_alt: { color: #E0E0E0, alpha: 1 }
			},
			surface: {
				panel: { color: #E2E2E2, alpha: 1 },
				panel_alt: { color: #D8D8D8, alpha: 1 },
				control: { color: #F2F2F2, alpha: 1 },
				control_alt: { color: #E6E6E6, alpha: 1 },
				popup: { color: #FFFFFF, alpha: 1 },
				tooltip: { color: #FFFFFF, alpha: 1 }
			},
			outline: {
				subtle: { color: #B8B8B8, alpha: 1 },
				normal: { color: #A8A8A8, alpha: 1 },
				strong: { color: #8A8A8A, alpha: 1 }
			},
			text: {
				primary: { color: #000000, alpha: 1 },
				secondary: { color: #2E2E2E, alpha: 1 },
				dim: { color: #808080, alpha: 1 },
				disabled: { color: #999999, alpha: 1 },
				inverse: { color: #FFFFFF, alpha: 1 },
				link: { color: #6D6D6D, alpha: 1 }
			},
			accent: {
				primary: { color: #D0D0D0, alpha: 1 },
				on_accent: { color: #000000, alpha: 1 },
				subtle: { color: #D0D0D0, alpha: 0.35 }
			},
			state: {
				selection_bg: { color: #C8C8C8, alpha: 0.55 },
				selection_text: { color: #000000, alpha: 1 },
				success_fg: { color: #3C8C54, alpha: 1 },
				success_bg: { color: #3C8C54, alpha: 0.20 },
				warning_fg: { color: #B08A2E, alpha: 1 },
				warning_bg: { color: #B08A2E, alpha: 0.20 },
				danger_fg: { color: #B85C5C, alpha: 1 },
				danger_bg: { color: #B85C5C, alpha: 0.20 }
			},
			overlay: {
				modal_shade: { color: #000000, alpha: 0.30 }
			}
		},

		text_renderer: {
			font: {
				main: fnt_ww_default_small_msdf,
				code: fnt_ww_consolas_10
			},
			color: {
				main: #000000,
				dim: #808080,
				disabled: #999999
			},
			alpha: {
				main: 1,
				disabled: 0.60
			}
		},

		button: {
			sprite: {
				main: spr_ww_rr9_r4_all
			},
			color: {
				main: #E6E6E6,
				text: #000000
			},
			alpha: {
				main: 1,
				text: 1
			}
		},

		button_text: {
			sprite: {
				main: spr_ww_rr9_r4_all
			},
			color: {
				main: #E6E6E6,
				text: #000000
			},
			alpha: {
				main: 1,
				text: 1
			}
		},

		checkbox: {
			sprite: {
				main: spr_ww_checkbox,
				check: {
					checked: spr_ww_checkbox_check,
					unchecked: spr_ww_checkbox_uncheck
				}
			},
			color: {
				main: #E6E6E6,
				check: {
					checked: #303030,
					unchecked: #8A8A8A
				}
			},
			alpha: {
				main: 1,
				check: {
					checked: 1,
					unchecked: 1
				}
			}
		},

		slider: {
			sprite: {
				track: { main: spr_ww_slider_background },
				fill: { main: spr_ww_slider_bar },
				thumb: { main: spr_ww_slider_thumb }
			},
			color: {
				track: #D0D0D0,
				fill: #C0C0C0,
				thumb: #B8B8B8
			},
			alpha: {
				track: 1,
				fill: 1,
				thumb: 1
			}
		},

		scrollbar: {
			sprite: {
				tray: { main: spr_ww_pixel },
				gutter: { main: spr_ww_pixel },
				trough: { main: spr_ww_pixel },
				thumb: { main: spr_ww_rr9_r2_all },
				button: {
					left: { main: spr_ww_rr9_r2_left },
					right: { main: spr_ww_rr9_r2_right },
					up: { main: spr_ww_rr9_r2_top },
					down: { main: spr_ww_rr9_r2_bottom }
				}
			},
			color: {
				tray: #D4D4D4,
				gutter: #D4D4D4,
				trough: #C8C8C8,
				thumb: #B0B0B0,
				button: {
					left: #C8C8C8,
					right: #C8C8C8,
					up: #C8C8C8,
					down: #C8C8C8
				}
			},
			alpha: {
				tray: 1,
				gutter: 1,
				trough: 1,
				thumb: 0.95,
				button: {
					left: 1,
					right: 1,
					up: 1,
					down: 1
				}
			}
		},

		canvas: {
			sprite: { main: spr_ww_pixel },
			color: {
				main: #D4D4D4,
				border: #B8B8B8
			},
			alpha: {
				main: 1,
				border: 1
			},
			size: {
				border: 1
			}
		},

		frame: {
			sprite: { main: spr_ww_pixel },
			color: {
				main: #E2E2E2,
				border: #8A8A8A
			},
			alpha: {
				main: 1,
				border: 1
			},
			size: {
				border: 1
			}
		},

		panel: {
			sprite: { main: spr_ww_pixel },
			color: {
				main: #D4D4D4,
				border: #B0B0B0
			},
			alpha: {
				main: 1,
				border: 1
			},
			size: {
				border: 1
			}
		},

		inset: {
			sprite: { main: spr_ww_pixel },
			color: {
				main: #E4E4E4,
				border: #B8B8B8
			},
			alpha: {
				main: 1,
				border: 1
			},
			size: {
				border: 1
			}
		},

		container: {
			sprite: { main: spr_ww_pixel },
			color: {
				main: #F2F2F2,
				border: #B8B8B8
			},
			alpha: {
				main: 1,
				border: 1
			},
			size: {
				border: 0
			}
		}
	};

	return theme;
}
