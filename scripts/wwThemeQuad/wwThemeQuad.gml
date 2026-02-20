function wwThemeQuad() {
	return {
		meta: {
			id: "ww_components_color_overrides",
			name: "Component Color Overrides",
			mode: "dark",
			version: 1
		},
		main_color: #1F2430,
		accent_color: #7AA2F7,

		// Intentionally sparse token overrides to prove component-level visual targeting.
		colors: {
			surface: {
				panel_alt: { color: #283245, alpha: 1 },
				control: { color: #2F3A4D, alpha: 1 },
				control_alt: { color: #38465E, alpha: 1 }
			},
			outline: {
				normal: { color: #B7926F, alpha: 1 },
				strong: { color: #C7A17E, alpha: 1 }
			},
			accent: {
				primary: { color: #A987F0, alpha: 1 },
				on_accent: { color: #0F1115, alpha: 1 }
			},
			text: {
				link: { color: #6EC6FF, alpha: 1 }
			}
		},

		text_renderer: {
			color: {
				main: #E7EDF7,
				dim: #B7C2D2,
				disabled: #7B8698
			}
		}
	};
}
