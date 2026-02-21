function wwThemeMono() {
	return {
		meta: {
			id: "ww_mono_slate",
			name: "Mono Slate",
			mode: "dark",
			version: 1
		},
		main_color: #393939 
	};
}

function wwThemeDuo() {
	return {
		meta: {
			id: "ww_duo_slate_blue",
			name: "Duo Slate Blue",
			mode: "dark",
			version: 1
		},
		main_color: #2A313D,
		accent_color: #3F5493
	};
}

// Mono variants for derive testing.
function wwThemeMonoNearBlack() {
	return {
		meta: {
			id: "ww_mono_near_black",
			name: "Mono Near Black",
			mode: "dark",
			version: 1
		},
		main_color: #1F1F1F
	};
}

function wwThemeMonoMidGrey() {
	return {
		meta: {
			id: "ww_mono_mid_grey",
			name: "Mono Mid Grey",
			mode: "dark",
			version: 1
		},
		main_color: #4A4A4A
	};
}

function wwThemeMonoWarmEdge() {
	return {
		meta: {
			id: "ww_mono_warm_edge",
			name: "Mono Warm Edge",
			mode: "dark",
			version: 1
		},
		// Near-neutral warm seed to test neutral-threshold behavior.
		main_color: #3E3935
	};
}

function wwThemeMonoCoolEdge() {
	return {
		meta: {
			id: "ww_mono_cool_edge",
			name: "Mono Cool Edge",
			mode: "dark",
			version: 1
		},
		// Near-neutral cool seed to test neutral-threshold behavior.
		main_color: #35393E
	};
}

function wwThemeMonoLight() {
	return {
		meta: {
			id: "ww_mono_light",
			name: "Mono Light",
			mode: "light",
			version: 1
		},
		main_color: #D4D4D4
	};
}

// Duo variants for derive testing.
function wwThemeDuoNeutralWarmRare() {
	return {
		meta: {
			id: "ww_duo_neutral_warm_rare",
			name: "Duo Neutral + Warm Rare",
			mode: "dark",
			version: 1
		},
		main_color: #393939,
		accent_color: #4E453F
	};
}

function wwThemeDuoNeutralGreenRare() {
	return {
		meta: {
			id: "ww_duo_neutral_green_rare",
			name: "Duo Neutral + Green Rare",
			mode: "dark",
			version: 1
		},
		main_color: #393939,
		accent_color: #039D5B
	};
}

function wwThemeDuoCoolSlate() {
	return {
		meta: {
			id: "ww_duo_cool_slate",
			name: "Duo Cool Slate",
			mode: "dark",
			version: 1
		},
		main_color: #2A313D,
		accent_color: #505860
	};
}

function wwThemeDuoSoftContrast() {
	return {
		meta: {
			id: "ww_duo_soft_contrast",
			name: "Duo Soft Contrast",
			mode: "dark",
			version: 1
		},
		main_color: #2B2B2B,
		accent_color: #6A6A6A
	};
}

function wwThemeDuoLightGrey() {
	return {
		meta: {
			id: "ww_duo_light_grey",
			name: "Duo Light Grey",
			mode: "light",
			version: 1
		},
		main_color: #D4D4D4,
		accent_color: #A8A8A8
	};
}

function wwThemePallet() {
	return {
		meta: {
			id: "ww_palette_slate_balanced",
			name: "Palette Slate Balanced",
			mode: "dark",
			version: 1
		},
		// Full explicit palette theme (no sparse seed behavior).
		palette: {
			n0: #12161D,
			n5: #171D26,
			n10: #202936,
			n20: #2A3646,
			n30: #344458,
			n40: #486078,
			n70: #8FA2B8,
			n90: #CDD8E4,
			n100: #F2F6FB,
			blue: #3F5493,
			green: #71B497,
			yellow: #D7BD7A,
			orange: #C79670,
			red: #C77A78,
			purple: #9B87C8
		}
	};
}

// Retro-inspired palette pack.
function wwThemeRetroCRTAmber() {
	return {
		meta: {
			id: "ww_retro_crt_amber",
			name: "Retro CRT Amber",
			mode: "dark",
			version: 1
		},
		main_color: #1A1712,
		accent_color: #C9822B,
		accent_color_2: #E0B05A,
		accent_color_3: #6A4A2A,
		palette: {
			n0: #0C0A07,
			n5: #11100C,
			n10: #17140F,
			n20: #201B14,
			n30: #2B251B,
			n40: #3A3124,
			n70: #A48A64,
			n90: #E6D4B4,
			n100: #FFF1D6,
			blue: #8FA28A,
			green: #6E8A57,
			yellow: #C9A552,
			orange: #C9822B,
			red: #A45D3F,
			purple: #7A5A7E
		}
	};
}

function wwThemeRetroGameBoy() {
	return {
		meta: {
			id: "ww_retro_gameboy",
			name: "Retro Game Boy",
			mode: "dark",
			version: 1
		},
		main_color: #1F2A1F,
		accent_color: #7B8F3F,
		accent_color_2: #A8B96A,
		accent_color_3: #4D5E2F,
		palette: {
			n0: #0F140F,
			n5: #131A13,
			n10: #1A221A,
			n20: #253025,
			n30: #314031,
			n40: #3F5240,
			n70: #7E9166,
			n90: #BACA90,
			n100: #DDE8B6,
			blue: #7A9167,
			green: #7B8F3F,
			yellow: #A8B96A,
			orange: #8A7A42,
			red: #6E5A3A,
			purple: #5F6A4C
		}
	};
}

function wwThemeRetroC64() {
	return {
		meta: {
			id: "ww_retro_c64",
			name: "Retro C64",
			mode: "dark",
			version: 1
		},
		main_color: #222A5C,
		accent_color: #6C5EB5,
		accent_color_2: #8FD1D1,
		accent_color_3: #B1A6E8,
		palette: {
			n0: #0F1230,
			n5: #14193C,
			n10: #1B2250,
			n20: #252E66,
			n30: #313C7A,
			n40: #47539A,
			n70: #A4AFDA,
			n90: #D8DBF2,
			n100: #F2F3FF,
			blue: #6F88E8,
			green: #72A890,
			yellow: #D4C777,
			orange: #C98D5A,
			red: #B66A63,
			purple: #8F7AE0
		}
	};
}

function wwThemeRetroNES() {
	return {
		meta: {
			id: "ww_retro_nes",
			name: "Retro NES",
			mode: "dark",
			version: 1
		},
		main_color: #2A2A2A,
		accent_color: #C84C3B,
		accent_color_2: #7C9A5A,
		accent_color_3: #D0B060,
		palette: {
			n0: #111111,
			n5: #171717,
			n10: #202020,
			n20: #2C2C2C,
			n30: #3A3A3A,
			n40: #4A4A4A,
			n70: #A3A3A3,
			n90: #D8D8D8,
			n100: #F5F5F5,
			blue: #4E74B8,
			green: #7C9A5A,
			yellow: #D0B060,
			orange: #C57A45,
			red: #C84C3B,
			purple: #8A62A8
		}
	};
}

function wwThemeRetroMidCenturyLight() {
	return {
		meta: {
			id: "ww_retro_midcentury_light",
			name: "Retro Mid-Century Light",
			mode: "light",
			version: 1
		},
		main_color: #D7D0B1,
		accent_color: #8C8F4E,
		accent_color_2: #C06C44,
		accent_color_3: #5D6A45,
		palette: {
			n0: #2B2720,
			n5: #3A342A,
			n10: #494235,
			n20: #5C5444,
			n30: #6D644F,
			n40: #857A61,
			n70: #CFC5A1,
			n90: #E8E0C7,
			n100: #F7F2E3,
			blue: #5C7A7A,
			green: #8C8F4E,
			yellow: #C6A45A,
			orange: #C06C44,
			red: #A75642,
			purple: #7E6B8E
		}
	};
}

function wwThemeRetroTealOrange() {
	return {
		meta: {
			id: "ww_retro_teal_orange",
			name: "Retro Teal Orange",
			mode: "dark",
			version: 1
		},
		main_color: #2B3538,
		accent_color: #D08A3B,
		accent_color_2: #4F8C88,
		accent_color_3: #C5573D,
		palette: {
			n0: #141A1C,
			n5: #1A2225,
			n10: #202B2E,
			n20: #2C393D,
			n30: #39484D,
			n40: #4A5C62,
			n70: #A6B6BA,
			n90: #DBE2E4,
			n100: #F3F6F7,
			blue: #5B88A8,
			green: #4F8C88,
			yellow: #D6B26B,
			orange: #D08A3B,
			red: #C5573D,
			purple: #8C6FA1
		}
	};
}

function wwThemeTests() {
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

// Helper catalog for quickly iterating test themes in tools/demo code.
function wwThemeTestsCatalog() {
	return [
		{ id: "mono_slate", kind: "mono", name: "Mono Slate", builder: wwThemeMono },
		{ id: "mono_near_black", kind: "mono", name: "Mono Near Black", builder: wwThemeMonoNearBlack },
		{ id: "mono_mid_grey", kind: "mono", name: "Mono Mid Grey", builder: wwThemeMonoMidGrey },
		{ id: "mono_warm_edge", kind: "mono", name: "Mono Warm Edge", builder: wwThemeMonoWarmEdge },
		{ id: "mono_cool_edge", kind: "mono", name: "Mono Cool Edge", builder: wwThemeMonoCoolEdge },
		{ id: "mono_light", kind: "mono", name: "Mono Light", builder: wwThemeMonoLight },
		{ id: "duo_slate_blue", kind: "duo", name: "Duo Slate Blue", builder: wwThemeDuo },
		{ id: "duo_neutral_warm_rare", kind: "duo", name: "Duo Neutral + Warm Rare", builder: wwThemeDuoNeutralWarmRare },
		{ id: "duo_neutral_green_rare", kind: "duo", name: "Duo Neutral + Green Rare", builder: wwThemeDuoNeutralGreenRare },
		{ id: "duo_cool_slate", kind: "duo", name: "Duo Cool Slate", builder: wwThemeDuoCoolSlate },
		{ id: "duo_soft_contrast", kind: "duo", name: "Duo Soft Contrast", builder: wwThemeDuoSoftContrast },
		{ id: "duo_light_grey", kind: "duo", name: "Duo Light Grey", builder: wwThemeDuoLightGrey },
		{ id: "palette_slate_balanced", kind: "palette", name: "Palette Slate Balanced", builder: wwThemePallet },
		{ id: "retro_crt_amber", kind: "retro", name: "Retro CRT Amber", builder: wwThemeRetroCRTAmber },
		{ id: "retro_gameboy", kind: "retro", name: "Retro Game Boy", builder: wwThemeRetroGameBoy },
		{ id: "retro_c64", kind: "retro", name: "Retro C64", builder: wwThemeRetroC64 },
		{ id: "retro_nes", kind: "retro", name: "Retro NES", builder: wwThemeRetroNES },
		{ id: "retro_midcentury_light", kind: "retro", name: "Retro Mid-Century Light", builder: wwThemeRetroMidCenturyLight },
		{ id: "retro_teal_orange", kind: "retro", name: "Retro Teal Orange", builder: wwThemeRetroTealOrange },
		{ id: "component_overrides", kind: "override", name: "Component Color Overrides", builder: wwThemeTests },
	];
}
