use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Style};
use ratatui::text::Text;
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph, Wrap};

use crate::ui::state::App;

/// renders the description popup
pub fn render_description_popup(f: &mut Frame, app: &App, area: Rect) {
    if let Some(description) = &app.description.content {
        let popup_block = Block::default()
            .title(" Description ")
            .borders(Borders::ALL)
            .border_type(BorderType::Rounded)
            .border_style(Style::default().fg(Color::Rgb(137, 180, 250)));

        let text = Text::from(description.as_str());
        let paragraph = Paragraph::new(text).wrap(Wrap { trim: false }).block(popup_block.clone());

        f.render_widget(Clear, area);
        f.render_widget(paragraph, area);
    }
}
