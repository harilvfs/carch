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
        .constraints([
            Constraint::Percentage(33), // left
            Constraint::Percentage(34), // center
            Constraint::Percentage(33), // right
        ])
        .split(inner_area);

    // left side: breadcrumb
    let breadcrumb = if let Some(script_idx) = app.scripts.state.selected() {
        let script = &app.scripts.items[script_idx];
        Text::from(Line::from(vec![
            Span::styled("Script: ", Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD)),
            Span::raw(format!("{}/{}", script.category, script.name)),
        ]))
    } else if let Some(category_idx) = app.categories.state.selected() {
        let category = &app.categories.items[category_idx];
        Text::from(Line::from(vec![
            Span::styled(
                "Category: ",
                Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD),
            ),
            Span::raw(category.clone()),
        ]))
    } else {
        Text::from("")
    };

    // center: title
    let center_text = Text::from(Line::from(Span::styled(
        "Carch",
        Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD),
    )));

    // right side: script counts
    let total_scripts = app.all_scripts.values().map(Vec::len).sum::<usize>();
    let category_scripts = if let Some(category_idx) = app.categories.state.selected() {
        let category = &app.categories.items[category_idx];
        app.all_scripts.get(category).map_or(0, |scripts| scripts.len())
    } else {
        total_scripts
    };

    let right_text = Text::from(Line::from(vec![
        Span::styled("Scripts: ", Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD)),
        Span::raw(format!("{category_scripts} / {total_scripts}")),
    ]));

    f.render_widget(Paragraph::new(breadcrumb).alignment(Alignment::Left), chunks[0]);
    f.render_widget(Paragraph::new(center_text).alignment(Alignment::Center), chunks[1]);
    f.render_widget(Paragraph::new(right_text).alignment(Alignment::Right), chunks[2]);
}
