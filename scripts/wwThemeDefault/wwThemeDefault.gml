function wwThemeDefault() {
	/// Base theme template.
	///
	/// Purpose: defines the complete set of fields a theme is expected to provide,
	/// and supplies all shared defaults (fonts/layout/behavior/component wiring + asset hooks).
	///
	/// Light/Dark (and other) themes should call this and then override:
	/// - meta
	/// - colors (required)
	/// - palette (optional but recommended)
	/// - derive (optional)
	var theme = {
		meta: {
			id: "ww_theme_base",
			name: "Wittle Theme Base",
			mode: "", // "light" | "dark" (or other)
			version: 1,
			author: "",
			description: "",
			tags: ["base"],
			compat: { ww_min: "x.y.z" }
		},

		// The actual visual tokens should be supplied by the concrete theme.
		// Colors should use GML color literals: #RRGGBB (RGB-ordered for CSS familiarity).
		// For semi-transparent tokens, use: { color: #RRGGBB, alpha: 0..1 }.
		palette: {
			n0: undefined, n5: undefined, n10: undefined, n20: undefined,
			n30: undefined, n40: undefined, n70: undefined, n90: undefined, n100: undefined,
			blue: undefined, green: undefined, yellow: undefined, orange: undefined, red: undefined, purple: undefined
		},
		colors: {
			app: {
				bg: { color: undefined, alpha: undefined },
				bg_alt: { color: undefined, alpha: undefined }
			},
			surface: {
				panel: { color: undefined, alpha: undefined },
				panel_alt: { color: undefined, alpha: undefined },
				control: { color: undefined, alpha: undefined },
				control_alt: { color: undefined, alpha: undefined },
				popup: { color: undefined, alpha: undefined },
				tooltip: { color: undefined, alpha: undefined }
			},
			outline: {
				subtle: { color: undefined, alpha: undefined },
				normal: { color: undefined, alpha: undefined },
				strong: { color: undefined, alpha: undefined }
			},
			text: {
				primary: { color: undefined, alpha: undefined },
				secondary: { color: undefined, alpha: undefined },
				dim: { color: undefined, alpha: undefined },
				disabled: { color: undefined, alpha: undefined },
				inverse: { color: undefined, alpha: undefined },
				link: { color: undefined, alpha: undefined }
			},
			accent: {
				primary: { color: undefined, alpha: undefined },
				on_accent: { color: undefined, alpha: undefined },
				subtle: { color: undefined, alpha: undefined }
			},
			state: {
				focus_ring: { color: undefined, alpha: undefined },
				selection_bg: { color: undefined, alpha: undefined },
				selection_text: { color: undefined, alpha: undefined },
				success_fg: { color: undefined, alpha: undefined },
				success_bg: { color: undefined, alpha: undefined },
				warning_fg: { color: undefined, alpha: undefined },
				warning_bg: { color: undefined, alpha: undefined },
				danger_fg: { color: undefined, alpha: undefined },
				danger_bg: { color: undefined, alpha: undefined }
			},
			overlay: { modal_shade: { color: undefined, alpha: undefined } }
		},

		// Optional: derived-color parameters (YUI-style). Concrete themes may omit.
		derive: {
			enabled: false,
			tint_color: #FFFFFF,
			accent_color: #FFFFFF,
			lum_factor: 1.0,
			accent_lum: 0.0,
			hue_shift: 0.0,
			sat_mul: 1.0,
			val_mul: 1.0
		},

		schema: {
			id: "ww_theme_schema",
			version: 1
		},

		// Global scaling knobs (fast “whole UI” retune)
		scale: {
			ui: 1.0,
			text: 1.0,
			spacing: 1.0,
			radius: 1.0,
			outline: 1.0
		},

		units: {
			// If you ever mimic skin systems: sizes expressed in "dp"/dpi-scaled px.
			dpi_scale: 1.0
		},

		// Typography + YUI-style text_styles (centralize font+color combos)
		typography: {
			fonts: {
				ui:   { regular: fnt_ww_default_small_msdf, strong: fnt_ww_default_small_msdf, italic: fnt_ww_default_small_msdf },
				mono: { regular: fnt_ww_consolas_msdf }
			},

			sizes_px: { xs: 10, sm: 12, md: 14, lg: 18, xl: 24 },
			line_height: { tight: 1.05, normal: 1.20, roomy: 1.35 },

			// These intentionally reference semantic tokens that each variant must provide.
			text_styles: {
				title:    { font_asset: "fonts.ui.strong", size: "xl", paint: "colors.text.primary" },
				subtitle: { font_asset: "fonts.ui.strong", size: "lg", paint: "colors.text.primary" },
				body:     { font_asset: "fonts.ui.regular", size: "md", paint: "colors.text.primary" },
				hint:     { font_asset: "fonts.ui.regular", size: "sm", paint: "colors.text.dim" },
				mono:     { font_asset: "fonts.mono.regular", size: "md", paint: "colors.text.primary" }
			}
		},

		// Layout tokens (what most widgets actually care about)
		layout: {
			padding: { xxs: 2, xs: 4, sm: 6, md: 8, lg: 12, xl: 16 },
			gap:     { xxs: 2, xs: 4, sm: 6, md: 8, lg: 12, xl: 16 },
			radius:  { sm: 3, md: 6, lg: 10, xl: 14 },
			border:  { hair: 1, thin: 2, thick: 3 },

			// Common minimums to keep controls consistent
			min_size: {
				control_h: 22,
				button_h:  22,
				icon:      16,
				thumb:     14
			}
		},

		// Interaction timings & behavior defaults (EMU + skin configs)
		interaction: {
			double_click_ms: 250,
			hold_ms: 500,

			key_repeat: { delay_ms: 60, rate: 2 },
			caret_blink_ms: 800,
			tooltip: { delay_ms: 450, fade_ms: 120 },

			drag: { start_deadzone_px: 3 },

			scroll: {
				wheel_increment: 20,
				button_increment: 2,
				page_increment: 20,
				mouse_move_zoom_increment: 1.0
			}
		},

		motion: {
			durations_ms: { instant: 0, fast: 80, normal: 140, slow: 220 },
			easing: { standard: "out_quad", emphasis: "out_cubic" }
		},

		// Rendering/effects tokens (variant supplies actual colors)
		effects: {
			opacity: {
				disabled: 0.45,
				dim: 0.70
			},
			highlight: {
				color: "colors.accent.primary",
				alpha_hover: 0.40,
				alpha_active: 0.55
			},
			shadow: {
				e1: { a: 0.20, x: 0, y: 1, blur: 6,  color: #000000 },
				e2: { a: 0.28, x: 0, y: 2, blur: 10, color: #000000 }
			}
		},

		// Asset hooks (EMU macros + textured skins) — shared placeholders.
		assets: {
			sprites: {
				pixel: spr_ww_pixel,

				#region Button
				button: {
					main: spr_ww_rr9_r4_all,
					overlay: undefined
				},
				#endregion

				#region ButtonText
				button_text: {
					main: spr_ww_rr9_r4_all,
					overlay: undefined
				},
				#endregion

				#region Checkbox
				checkbox: {
					main: undefined,
					overlay: undefined,
					check: s9CheckBoxChecked,
					uncheck: undefined
				},
				#endregion

				#region Radio
				radio: {
					main: undefined,
					overlay: undefined,
					check: undefined,
					uncheck: undefined
				},
				#endregion

				#region Slider
				slider: {
					main: spr_ww_slider_background,
					overlay: undefined
				},
				slider_bar: {
					main: spr_ww_slider_bar,
					overlay: undefined
				},
				slider_thumb: {
					main: spr_ww_slider_thumb,
					overlay: undefined
				},
				#endregion

				#region Combo
				combo: {
					main: undefined,
					overlay: undefined,
					dropdown_icon: undefined
				},
				#endregion

				#region Dropdown
				dropdown: {
					main: undefined,
					overlay: undefined,
					item: undefined
				},
				#endregion

				#region Scrollbar
				scrollbar_horz: {
					main: undefined,
					overlay: undefined
				},
				scrollbar_horz_thumb: {
					main: undefined,
					overlay: undefined
				},
				scrollbar_vert: {
					main: undefined,
					overlay: undefined
				},
				scrollbar_vert_thumb: {
					main: undefined,
					overlay: undefined
				},
				#endregion

				#region Close
				close: {
					main: undefined,
					overlay: undefined
				},
				#endregion
			},
			icons: {
				warn: undefined,
				error: undefined,
				info: undefined,
				chevron: undefined
			}
		},

		skin: {
			enabled: false,
			frames: {
				button: {
					texture: "",
					nine_slice: { left: 3, top: 3, right: 3, bottom: 3 },
					tint: {
						normal: { color: #FFFFFF, alpha: 1 },
						hover: { color: #FFFFFF, alpha: 1 },
						down: { color: #FFFFFF, alpha: 1 },
						disabled: { color: #FFFFFF, alpha: 0.50 }
					}
				},
				panel: {
					texture: "",
					nine_slice: { left: 3, top: 3, right: 3, bottom: 3 },
					tint: { normal: { color: #FFFFFF, alpha: 1 } }
				},
				scrollbar_thumb: {
					texture: "",
					nine_slice: { left: 3, top: 3, right: 3, bottom: 3 },
					tint: {
						normal: { color: #FFFFFF, alpha: 1 },
						hover: { color: #FFFFFF, alpha: 1 },
						down: { color: #FFFFFF, alpha: 1 }
					}
				}
			}
		},

		// Shared “state model” for controls (mirrors GMUI’s explicit state coverage)
		control_states: {
			bg: {
				normal:   "colors.surface.control",
				hover:    "colors.surface.control_alt",
				active:   "colors.surface.control_alt",
				disabled: "colors.surface.panel"
			},
			border: {
				normal:   "colors.outline.subtle",
				hover:    "colors.accent.primary",
				active:   "colors.accent.primary",
				focused:  "colors.accent.primary",
				disabled: "colors.outline.subtle"
			},
			text: {
				normal:   "colors.text.primary",
				disabled: "colors.text.disabled"
			}
		},

		// Component overrides (token wiring; variants provide the tokens)
		components: {
			panel: {
				bg: "colors.surface.panel",
				border: "colors.outline.subtle",
				padding: "layout.padding.md",
				radius: "layout.radius.md"
			},

			button: {
				min_h: "layout.min_size.button_h",
				padding_x: 10,
				padding_y: 6,
				radius: "layout.radius.md",

				bg: {
					normal:   "colors.surface.control",
					hover:    "colors.surface.control_alt",
					focused:  "colors.surface.control_alt",
					active:   "colors.surface.control_alt",
					disabled: "colors.surface.panel"
				},
				border: {
					normal:   "colors.outline.subtle",
					hover:    "colors.accent.primary",
					active:   "colors.accent.primary",
					focused:  "colors.accent.primary",
					disabled: "colors.outline.subtle"
				},
				text: {
					normal:   "colors.text.primary",
					hover:    "colors.text.primary",
					focused:  "colors.text.primary",
					active:   "colors.text.primary",
					disabled: "colors.text.disabled"
				},

				highlight: { color: "effects.highlight.color", alpha: "effects.highlight.alpha_hover" }
			},

			text_input: {
				min_h: "layout.min_size.control_h",
				padding_x: 8,
				padding_y: 6,
				radius: "layout.radius.md",

				bg: {
					normal:   "colors.surface.control",
					disabled: "colors.surface.panel"
				},
				border: {
					normal:   "colors.outline.subtle",
					focused:  "colors.accent.primary",
					invalid:  "colors.state.danger_fg"
				},

				text: {
					normal: "colors.text.primary",
					placeholder: "colors.text.dim",
					disabled: "colors.text.disabled"
				},

				caret: "colors.text.primary",
				selection_bg: "colors.state.selection_bg",
				selection_text: "colors.state.selection_text"
			},

			checkbox: {
				box_size: 16,
				radius: "layout.radius.sm",
				   bg: {
					   normal: "colors.surface.control",
					   hover:  "colors.surface.control_alt",
					   focused: "colors.surface.control_alt",
					   active: "colors.surface.control_alt",
					   disabled: "colors.surface.panel"
				   },
				border: "control_states.border",
				check: { color: "colors.accent.primary", mark: "colors.accent.on_accent" },
				text: "control_states.text"
			},

			slider: {
				track_h: 6,
				thumb: { size: 14, radius: "layout.radius.lg" },
				track_bg: "colors.outline.subtle",
				track_fill: "colors.accent.primary",
				   thumb_bg: {
					   normal: "colors.surface.control_alt",
					   hover:  "colors.surface.control_alt",
					   focused: "colors.surface.control_alt",
					   active: "colors.surface.control_alt",
					   disabled: "colors.surface.panel"
				   },
				thumb_border: "control_states.border"
			},

			scrollbar: {
				thickness: 10,
				thumb_min_len: 18,
				bg: "colors.surface.panel_alt",
				thumb: { normal: { color: #55627A, alpha: 0.50 }, hover: { color: #8A96AD, alpha: 0.67 }, active: { color: #B3BDD1, alpha: 0.80 } },
				increments: "interaction.scroll"
			},
			
			list: {
				bg: "colors.surface.panel_alt",
				item_bg: "colors.surface.control",
				selected_bg: "colors.accent.subtle",
				selected_text: "colors.text.primary"
			},

			menu: {
				spacing: 0,
				bg: "colors.surface.popup",
				border: "colors.outline.subtle",
				item_bg: "colors.surface.control",
				item_highlight_alpha: 0.5
			},

			tooltip: {
				bg: "colors.surface.tooltip",
				border: "colors.outline.subtle",
				text: "colors.text.primary",
				padding_x: 8,
				padding_y: 6,
				radius: "layout.radius.md",
				shadow: "effects.shadow.e1"
			}
		}
	};
	
	return theme;
}

