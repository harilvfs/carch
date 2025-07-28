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
}
