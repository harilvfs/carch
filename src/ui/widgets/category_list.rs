use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::widgets::{Block, BorderType, Borders, List, ListItem};

use crate::ui::state::{App, FocusedPanel};

/// draws the list of script categories
pub fn render_category_list(f: &mut Frame, app: &mut App, area: Rect) {
    let is_focused = app.focused_panel == FocusedPanel::Categories;
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title("Categories")
        .border_style(Style::default().fg(Color::Rgb(137, 180, 250)))
        .style(Style::default().bg(Color::Reset));

    let items: Vec<ListItem> = app
        .categories
        .items
        .iter()
        .enumerate()
        .map(|(idx, category_name)| {
            let is_selected = app.categories.state.selected() == Some(idx);
            let icon = if !is_focused && is_selected { "  " } else { " 󰉋 " };
            let colored_icon =
                ratatui::text::Span::styled(icon, Style::default().fg(Color::Rgb(137, 180, 250)));
            let text = ratatui::text::Span::styled(
                category_name.as_str(),
                Style::default().fg(Color::Rgb(137, 180, 250)),
            );
            let line = ratatui::text::Line::from(vec![colored_icon, text]);
            ListItem::new(line)
        })
        .collect();
    let list = List::new(items).block(block).highlight_style(
        Style::default()
            .bg(Color::Rgb(137, 180, 250))
            .fg(Color::Black)
            .add_modifier(Modifier::BOLD),
    );
    f.render_stateful_widget(list, area, &mut app.categories.state);
}
