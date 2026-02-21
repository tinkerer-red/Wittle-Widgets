function wwThemeGMDark() {
	var theme = {
		meta: {
			id: "ww_gm_dark",
			name: "GameMaker Dark",
			mode: "dark",
			version: 1,
			author: "",
			description: "GameMaker-inspired dark palette mapped to Wittle Widgets keyspace.",
			tags: ["gm", "dark", "feature_complete"],
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
			accent_color: #3F3F3F,
			lum_factor: 1.0,
			accent_lum: 0.0,
			hue_shift: 0.0,
			sat_mul: 1.0,
			val_mul: 1.0
		},

		main_color: #222222,
		accent_color: #3F3F3F,
		accent_color_2: #4E453F,
		accent_color_3: #505860,

		palette: {
			n0: #181818,
			n5: #1E1E1E,
			n10: #212121,
			n20: #222222,
			n30: #232323,
			n40: #272727,
			n70: #363636,
			n90: #505860,
			n100: #FFFFFF,
			blue: #4E453F,
			green: #039D5B,
			yellow: #4E453F,
			orange: #4E453F,
			red: #4E453F,
			purple: #3F434B
		},

		colors: {
			app: {
				bg: { color: #1E1E1E, alpha: 1 },
				bg_alt: { color: #212121, alpha: 1 }
			},
			surface: {
				panel: { color: #222222, alpha: 1 },
				panel_alt: { color: #232323, alpha: 1 },
				control: { color: #272727, alpha: 1 },
				control_alt: { color: #2D2F31, alpha: 1 },
				popup: { color: #222222, alpha: 1 },
				tooltip: { color: #282828, alpha: 1 }
			},
			outline: {
				subtle: { color: #2E2E2E, alpha: 1 },
				normal: { color: #3F3F3F, alpha: 1 },
				strong: { color: #505860, alpha: 1 }
			},
			text: {
				primary: { color: #FFFFFF, alpha: 1 },
				secondary: { color: #C8C8C8, alpha: 1 },
				dim: { color: #A0A0A0, alpha: 1 },
				disabled: { color: #808080, alpha: 1 },
				inverse: { color: #000000, alpha: 1 },
				link: { color: #039D5B, alpha: 1 }
			},
			accent: {
				primary: { color: #3F3F3F, alpha: 1 },
				on_accent: { color: #FFFFFF, alpha: 1 },
				subtle: { color: #3F3F3F, alpha: 0.35 }
			},
			state: {
				selection_bg: { color: #3F434B, alpha: 0.55 },
				selection_text: { color: #FFFFFF, alpha: 1 },
				success_fg: { color: #039D5B, alpha: 1 },
				success_bg: { color: #039D5B, alpha: 0.25 },
				warning_fg: { color: #4E453F, alpha: 1 },
				warning_bg: { color: #4E453F, alpha: 0.22 },
				danger_fg: { color: #4E453F, alpha: 1 },
				danger_bg: { color: #4E453F, alpha: 0.22 }
			},
			overlay: {
				modal_shade: { color: #000000, alpha: 0.60 }
			}
		},

		text_renderer: {
			font: {
				main: fnt_ww_default_small_msdf,
				code: fnt_ww_consolas_10
			},
			color: {
				main: #FFFFFF,
				dim: #A0A0A0,
				disabled: #808080
			},
			alpha: {
				main: 1,
				disabled: 0.55
			}
		},

		button: {
			sprite: {
				main: spr_ww_rr9_r4_all
			},
			color: {
				main: #3F3F3F,
				text: #FFFFFF
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
				main: #3F3F3F,
				text: #FFFFFF
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
				main: #3F3F3F,
				check: {
					checked: #FFFFFF,
					unchecked: #A0A0A0
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
				track: #282828,
				fill: #3F3F3F,
				thumb: #505860
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
				tray: #212121,
				gutter: #212121,
				trough: #282828,
				thumb: #505860,
				button: {
					left: #3F3F3F,
					right: #3F3F3F,
					up: #3F3F3F,
					down: #3F3F3F
				}
			},
			alpha: {
				tray: 1,
				gutter: 1,
				trough: 1,
				thumb: 0.80,
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
				main: #1E1E1E,
				border: #2E2E2E
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
				main: #222222,
				border: #3F3F3F
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
				main: #232323,
				border: #3F3F3F
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
				main: #272727,
				border: #2E2E2E
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
				main: #2D2F31,
				border: #363636
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
