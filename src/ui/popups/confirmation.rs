use ratatui::Frame;
use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph};

use crate::ui::state::App;

pub fn render_confirmation_popup(f: &mut Frame, app: &App, area: Rect) {
    let popup_width = std::cmp::min(60, area.width - 8);
    let popup_height = 11;

    let popup_area = Rect {
        x:      area.x + (area.width - popup_width) / 2,
        y:      area.y + (area.height - popup_height) / 2,
        width:  popup_width,
        height: popup_height,
    };

    f.render_widget(Clear, popup_area);

    let popup_block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title("Confirm selection")
        .border_style(Style::default().fg(Color::Green));

    let inner_area = popup_block.inner(popup_area);

    let content_layout = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(1),
            Constraint::Length(2),
            Constraint::Length(1),
            Constraint::Length(2),
        ])
        .split(inner_area);

    f.render_widget(popup_block, popup_area);

    let question_text = "Do you want to run this script?";

    let question_paragraph =
        Paragraph::new(ratatui::text::Line::from(vec![ratatui::text::Span::styled(
            question_text,
            Style::default().fg(Color::Gray),
        )]))
        .alignment(Alignment::Center);

    f.render_widget(question_paragraph, content_layout[0]);

    if let Some(idx) = app.scripts.state.selected() {
        let script_text =
            Paragraph::new(ratatui::text::Line::from(vec![ratatui::text::Span::styled(
                format!("{}/{}", app.scripts.items[idx].category, app.scripts.items[idx].name),
                Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
            )]))
            .alignment(Alignment::Center);

        f.render_widget(script_text, content_layout[1]);
    }

    let options_text = Paragraph::new(ratatui::text::Line::from(vec![
        ratatui::text::Span::styled("(y)", Style::default().fg(Color::Green)),
        ratatui::text::Span::styled("es", Style::default().fg(Color::Gray)),
        ratatui::text::Span::raw(" / "),
        ratatui::text::Span::styled("(n)", Style::default().fg(Color::Red)),
        ratatui::text::Span::styled("o", Style::default().fg(Color::Gray)),
    ]))
    .alignment(Alignment::Center);

    f.render_widget(options_text, content_layout[3]);
}
