use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Style};
use ratatui::text::Text;
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph, Wrap};

use crate::ui::state::App;

/// wraps the given text to fit within the specified width
fn word_wrap(text: &str, width: u16) -> String {
    let mut wrapped_text = String::new();
    let mut current_line = String::new();

    for word in text.split_whitespace() {
        if current_line.len() + word.len() + 1 > width as usize {
            wrapped_text.push_str(&current_line);
            wrapped_text.push('\n');
            current_line.clear();
        }
        if !current_line.is_empty() {
            current_line.push(' ');
        }
        current_line.push_str(word);
    }
    wrapped_text.push_str(&current_line);
    wrapped_text
}

/// renders the description popup
pub fn render_description_popup(f: &mut Frame, app: &mut App, area: Rect) {
    if let Some(description) = &app.description.content {
        let popup_block = Block::default()
            .title(" Description ")
            .borders(Borders::ALL)
            .border_type(BorderType::Rounded)
            .border_style(Style::default().fg(Color::Rgb(137, 180, 250)));

        let available_width = area.width.saturating_sub(2);
        let wrapped_description = word_wrap(description, available_width);

        let text = Text::from(wrapped_description.as_str());
        let paragraph = Paragraph::new(text)
            .wrap(Wrap { trim: true })
            .block(popup_block.clone())
            .scroll((app.description.scroll, 0));

        let lines = wrapped_description.lines().count() as u16;
        let available_height = area.height.saturating_sub(2);
        app.description.max_scroll = lines.saturating_sub(available_height);

        f.render_widget(Clear, area);
        f.render_widget(paragraph, area);
    }
}
