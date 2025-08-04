use chrono::Local;
use ratatui::Frame;
use ratatui::layout::{Alignment, Constraint, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::text::{Line, Span, Text};
use ratatui::widgets::{Block, BorderType, Borders, Paragraph};

use crate::ui::state::App;

pub fn render_header(f: &mut Frame, app: &App, area: Rect) {
    let header_block = Block::default()
        .borders(Borders::ALL)
        .border_style(Style::default().fg(app.theme.primary))
        .border_type(BorderType::Rounded);

    let inner_area = header_block.inner(area);
    f.render_widget(header_block, area);

    let chunks = ratatui::layout::Layout::default()
        .direction(ratatui::layout::Direction::Horizontal)
        .constraints([
            Constraint::Percentage(33),
            Constraint::Percentage(34),
            Constraint::Percentage(33),
        ])
        .split(inner_area);

    let total_scripts = app.all_scripts.values().map(Vec::len).sum::<usize>();
    let left_text = Text::from(Line::from(vec![
        Span::styled("Carch", Style::default().fg(app.theme.accent).add_modifier(Modifier::BOLD)),
        Span::raw(format!(" | Total Scripts: {total_scripts}")),
    ]));
    f.render_widget(Paragraph::new(left_text).alignment(Alignment::Left), chunks[0]);

    let time_str = Local::now().format("%H:%M:%S").to_string();
    let time_text = Text::from(Line::from(vec![Span::styled(
        time_str,
        Style::default().fg(app.theme.secondary),
    )]));
    f.render_widget(Paragraph::new(time_text).alignment(Alignment::Center), chunks[1]);

    let breadcrumb = if let Some(script_idx) = app.scripts.state.selected() {
        let script = &app.scripts.items[script_idx];
        let category_scripts = app.scripts.items.len();
        let script_pos = script_idx + 1;
        Text::from(Line::from(vec![
            Span::styled(&script.category, Style::default().fg(app.theme.accent)),
            Span::raw(" > "),
            Span::styled(
                &script.name,
                Style::default().fg(app.theme.accent).add_modifier(Modifier::BOLD),
            ),
            Span::raw(format!(" ({script_pos}/{category_scripts})")),
        ]))
    } else if let Some(category_idx) = app.categories.state.selected() {
        let category = &app.categories.items[category_idx];
        let category_scripts = app.all_scripts.get(category).map_or(0, |s| s.len());
        Text::from(Line::from(vec![
            Span::styled(
                category,
                Style::default().fg(app.theme.accent).add_modifier(Modifier::BOLD),
            ),
            Span::raw(format!(" ({category_scripts} scripts)")),
        ]))
    } else {
        Text::from(Span::styled("Select a category", Style::default().fg(app.theme.secondary)))
    };
    f.render_widget(Paragraph::new(breadcrumb).alignment(Alignment::Right), chunks[2]);
}
