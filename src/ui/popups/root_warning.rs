use ratatui::Frame;
use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph};

use crate::ui::state::App;

pub fn render_root_warning_popup(f: &mut Frame, app: &App, area: Rect) {
    f.render_widget(Clear, area);

    let popup_block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title("Warning")
        .border_style(Style::default().fg(app.theme.error));

    let inner_area = popup_block.inner(area);

    let content_layout = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(2),
            Constraint::Length(2),
            Constraint::Length(1),
            Constraint::Length(2),
        ])
        .split(inner_area);

    f.render_widget(popup_block, area);

    let warning_text = "You are running carch as root with sudo.";
    let warning_paragraph =
        Paragraph::new(ratatui::text::Line::from(vec![ratatui::text::Span::styled(
            warning_text,
            Style::default().fg(app.theme.warning).add_modifier(Modifier::BOLD),
        )]))
        .alignment(Alignment::Center);

    f.render_widget(warning_paragraph, content_layout[0]);

    let question_text = "This is not recommended. Do you want to continue?";
    let question_paragraph =
        Paragraph::new(ratatui::text::Line::from(vec![ratatui::text::Span::styled(
            question_text,
            Style::default().fg(app.theme.foreground),
        )]))
        .alignment(Alignment::Center);

    f.render_widget(question_paragraph, content_layout[1]);

    let options_text = Paragraph::new(ratatui::text::Line::from(vec![
        ratatui::text::Span::styled("(Y)", Style::default().fg(app.theme.success)),
        ratatui::text::Span::styled("es", Style::default().fg(app.theme.foreground)),
        ratatui::text::Span::raw(" / "),
        ratatui::text::Span::styled("(N)", Style::default().fg(app.theme.error)),
        ratatui::text::Span::styled("o", Style::default().fg(app.theme.foreground)),
    ]))
    .alignment(Alignment::Center);

    f.render_widget(options_text, content_layout[3]);
}
