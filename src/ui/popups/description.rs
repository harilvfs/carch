use ratatui::Frame;
use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::text::{Line, Span, Text};
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph, Wrap};

use crate::ui::state::App;

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

pub fn render_description_popup(f: &mut Frame, app: &mut App, area: Rect) {
    if let Some(description) = &app.description.content {
        let popup_block = Block::default()
            .title(" Description ")
            .borders(Borders::ALL)
            .border_type(BorderType::Rounded)
            .border_style(Style::default().fg(app.theme.primary));

        f.render_widget(Clear, area);
        f.render_widget(popup_block.clone(), area);

        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .margin(1)
            .constraints([Constraint::Min(1), Constraint::Length(1)])
            .split(area);

        let available_width = chunks[0].width.saturating_sub(2);
        let wrapped_description = word_wrap(description, available_width);

        let text = Text::from(wrapped_description.as_str());
        let paragraph =
            Paragraph::new(text).wrap(Wrap { trim: true }).scroll((app.description.scroll, 0));

        let lines = wrapped_description.lines().count() as u16;
        let available_height = chunks[0].height;
        app.description.max_scroll = lines.saturating_sub(available_height);

        f.render_widget(paragraph, chunks[0]);

        let help_text = Paragraph::new(Line::from(vec![
            Span::styled(" Scroll: ", Style::default().fg(app.theme.secondary)),
            Span::styled(
                "↑/↓/j/k",
                Style::default().fg(app.theme.foreground).add_modifier(Modifier::BOLD),
            ),
            Span::styled("  Close: ", Style::default().fg(app.theme.secondary)),
            Span::styled(
                "Esc/q/d",
                Style::default().fg(app.theme.foreground).add_modifier(Modifier::BOLD),
            ),
        ]))
        .alignment(Alignment::Center);

        f.render_widget(help_text, chunks[1]);
    }
}
