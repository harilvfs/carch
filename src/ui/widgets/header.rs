use ratatui::Frame;
use ratatui::layout::{Alignment, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, Paragraph};

use crate::ui::state::App;

pub fn render_header(f: &mut Frame, app: &App, area: Rect) {
    let header_block = Block::default()
        .borders(Borders::ALL)
        .border_style(Style::default().fg(Color::Rgb(137, 180, 250)))
        .border_type(BorderType::Rounded);
    f.render_widget(header_block, area);

    let inner_area = ratatui::layout::Layout::default()
        .direction(ratatui::layout::Direction::Horizontal)
        .margin(1)
        .constraints([
            ratatui::layout::Constraint::Percentage(30),
            ratatui::layout::Constraint::Percentage(40),
            ratatui::layout::Constraint::Percentage(30),
        ])
        .split(area);

    let left_text = vec![
        Line::from(vec![
            Span::styled("OS: ", Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD)),
            Span::raw(app.system_info.os.clone()),
        ]),
        Line::from(vec![
            Span::styled("Kernel: ", Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD)),
            Span::raw(app.system_info.kernel.clone()),
        ]),
    ];

    let center_text = vec![
        Line::from(vec![Span::styled(
            "CARCH",
            Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD),
        )]),
        Line::from(vec![Span::styled(
            "Automate Your Linux System Setup",
            Style::default().fg(Color::Rgb(235, 235, 210)).add_modifier(Modifier::ITALIC),
        )]),
    ];

    let right_text = vec![
        Line::from(vec![
            Span::styled("Uptime: ", Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD)),
            Span::raw(app.system_info.uptime.clone()),
        ]),
        Line::from(vec![
            Span::styled(
                "Hostname: ",
                Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD),
            ),
            Span::raw(app.system_info.hostname.clone()),
        ]),
    ];

    f.render_widget(Paragraph::new(left_text), inner_area[0]);
    f.render_widget(Paragraph::new(center_text).alignment(Alignment::Center), inner_area[1]);
    f.render_widget(Paragraph::new(right_text).alignment(Alignment::Right), inner_area[2]);
}
