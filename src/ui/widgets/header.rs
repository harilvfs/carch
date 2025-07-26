use ratatui::Frame;
use ratatui::layout::{Alignment, Constraint, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span, Text};
use ratatui::widgets::{Block, BorderType, Borders, Paragraph};

use crate::ui::state::App;

/// draws the header at the top of the screen
/// it shows breadcrumbs, script counts, and the app title
pub fn render_header(f: &mut Frame, app: &App, area: Rect) {
    let header_block = Block::default()
        .borders(Borders::ALL)
        .border_style(Style::default().fg(Color::Rgb(137, 180, 250)))
        .border_type(BorderType::Rounded);

    // get the inner area to draw the content
    // this prevents the margin from affecting the layout
    let inner_area = header_block.inner(area);
    f.render_widget(header_block, area);

    let chunks = ratatui::layout::Layout::default()
        .direction(ratatui::layout::Direction::Horizontal)
        .constraints([Constraint::Percentage(50), Constraint::Percentage(50)])
        .split(inner_area);

    // left side is  title and total scripts seprated by |
    let total_scripts = app.all_scripts.values().map(Vec::len).sum::<usize>();
    let left_text = Text::from(Line::from(vec![
        Span::styled("Carch", Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD)),
        Span::raw(format!(" | Total Scripts: {total_scripts}")),
    ]));
    f.render_widget(Paragraph::new(left_text).alignment(Alignment::Left), chunks[0]);

    // right side is our breadcrumb
    let breadcrumb = if let Some(script_idx) = app.scripts.state.selected() {
        let script = &app.scripts.items[script_idx];
        let category_scripts = app.scripts.items.len();
        let script_pos = script_idx + 1;
        Text::from(Line::from(vec![
            Span::styled(&script.category, Style::default().fg(Color::Cyan)),
            Span::raw(" > "),
            Span::styled(
                &script.name,
                Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD),
            ),
            Span::raw(format!(" ({script_pos}/{category_scripts})")),
        ]))
    } else if let Some(category_idx) = app.categories.state.selected() {
        let category = &app.categories.items[category_idx];
        let category_scripts = app.all_scripts.get(category).map_or(0, |s| s.len());
        Text::from(Line::from(vec![
            Span::styled(category, Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD)),
            Span::raw(format!(" ({category_scripts} scripts)")),
        ]))
    } else {
        Text::from(Span::styled("Select a category", Style::default().fg(Color::DarkGray)))
    };
    f.render_widget(Paragraph::new(breadcrumb).alignment(Alignment::Right), chunks[1]);
}
