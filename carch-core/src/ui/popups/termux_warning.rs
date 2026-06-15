use ratatui::Frame;
use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph, Wrap};

use crate::ui::state::App;

pub fn render_termux_warning_popup(f: &mut Frame, app: &App, area: Rect) {
    f.render_widget(Clear, area);

    let popup_block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title("Note")
        .border_style(Style::default().fg(app.theme.warning));

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

    let warning_text = "Termux environment detected.";
    let warning_paragraph =
        Paragraph::new(ratatui::text::Line::from(vec![ratatui::text::Span::styled(
            warning_text,
            Style::default().fg(app.theme.warning).add_modifier(Modifier::BOLD),
        )]))
        .alignment(Alignment::Center)
        .wrap(Wrap { trim: true });

    f.render_widget(warning_paragraph, content_layout[0]);

    let detail_text = "carch scripts are not compatible with Termux.\nOnly the Terminal/Termux script can be used.";
    let detail_paragraph =
        Paragraph::new(ratatui::text::Line::from(vec![ratatui::text::Span::styled(
            detail_text,
            Style::default().fg(app.theme.foreground),
        )]))
        .alignment(Alignment::Center)
        .wrap(Wrap { trim: true });

    f.render_widget(detail_paragraph, content_layout[1]);

    let options_text = Paragraph::new(ratatui::text::Line::from(vec![
        ratatui::text::Span::styled("(O)", Style::default().fg(app.theme.success)),
        ratatui::text::Span::styled("k", Style::default().fg(app.theme.foreground)),
    ]))
    .alignment(Alignment::Center)
    .wrap(Wrap { trim: true });

    f.render_widget(options_text, content_layout[3]);
}
