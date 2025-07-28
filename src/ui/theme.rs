use ratatui::style::Color;

#[derive(Debug, Clone)]
pub struct Theme {
    pub name:       String,
    pub background: Color,
    pub foreground: Color,
    pub primary:    Color,
    pub secondary:  Color,
    pub accent:     Color,
    pub success:    Color,
    pub warning:    Color,
    pub error:      Color,
}

impl Theme {
    // our beloved catppuccin_mocha
    pub fn catppuccin_mocha() -> Self {
        Self {
            name:       "Catppuccin Mocha".to_string(),
            background: Color::Rgb(30, 30, 46),
            foreground: Color::Rgb(205, 214, 244),
            primary:    Color::Rgb(137, 180, 250),
            secondary:  Color::Rgb(173, 216, 190),
            accent:     Color::Rgb(243, 139, 168),
            success:    Color::Rgb(166, 227, 161),
            warning:    Color::Rgb(250, 179, 135),
            error:      Color::Rgb(243, 139, 168),
        }
    }

    // for some vampire peoples
    pub fn dracula() -> Self {
        Self {
            name:       "Dracula".to_string(),
            background: Color::Rgb(40, 42, 54),
            foreground: Color::Rgb(248, 248, 242),
            primary:    Color::Rgb(189, 147, 249),
            secondary:  Color::Rgb(139, 233, 253),
            accent:     Color::Rgb(255, 121, 198),
            success:    Color::Rgb(80, 250, 123),
            warning:    Color::Rgb(241, 250, 140),
            error:      Color::Rgb(255, 85, 85),
        }
    }

    // for some people who *really* care about eyes
    pub fn gruvbox() -> Self {
        Self {
            name:       "Gruvbox".to_string(),
            background: Color::Rgb(40, 40, 40),
            foreground: Color::Rgb(235, 219, 178),
            primary:    Color::Rgb(250, 189, 47),
            secondary:  Color::Rgb(184, 187, 38),
            accent:     Color::Rgb(211, 134, 155),
            success:    Color::Rgb(184, 187, 38),
            warning:    Color::Rgb(254, 128, 25),
            error:      Color::Rgb(204, 36, 29),
        }
    }

    // our most soothing theme
    pub fn nord() -> Self {
        Self {
            name:       "Nord".to_string(),
            background: Color::Rgb(46, 52, 64),
            foreground: Color::Rgb(236, 239, 244),
            primary:    Color::Rgb(136, 192, 208),
            secondary:  Color::Rgb(143, 188, 187),
            accent:     Color::Rgb(180, 142, 173),
            success:    Color::Rgb(163, 190, 140),
            warning:    Color::Rgb(235, 203, 139),
            error:      Color::Rgb(191, 97, 106),
        }
    }

    // just some fancy name lovers
    pub fn rose_pine() -> Self {
        Self {
            name:       "Rosé Pine".to_string(),
            background: Color::Rgb(25, 23, 36),
            foreground: Color::Rgb(224, 222, 244),
            primary:    Color::Rgb(196, 167, 231),
            secondary:  Color::Rgb(156, 207, 216),
            accent:     Color::Rgb(235, 188, 186),
            success:    Color::Rgb(49, 116, 143),
            warning:    Color::Rgb(246, 193, 119),
            error:      Color::Rgb(235, 111, 146),
        }
    }
}
