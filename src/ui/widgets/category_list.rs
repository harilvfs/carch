use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::widgets::{Block, BorderType, Borders, List, ListItem};

use crate::ui::state::{App, FocusedPanel};

fn create_block(title: &str, is_focused: bool) -> Block<'_> {
    Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title(title)
        .border_style(if is_focused {
            Style::default().fg(Color::Cyan)
        } else {
            Style::default().fg(Color::DarkGray)
        })
        .style(Style::default().bg(Color::Reset))
}

pub fn render_category_list(f: &mut Frame, app: &mut App, area: Rect) {
    let is_focused = app.focused_panel == FocusedPanel::Categories;
    let block = create_block("Categories", is_focused);
    let items: Vec<ListItem> = app
        .categories
        .items
        .iter()
        .enumerate()
        .map(|(idx, category_name)| {
            let is_selected = app.categories.state.selected() == Some(idx);
            let icon = if !is_focused && is_selected { "  " } else { " 󰉋 " };
            let colored_icon = ratatui::text::Span::styled(icon, Style::default().fg(Color::Cyan));
            let text = ratatui::text::Span::styled(
                category_name.as_str(),
                Style::default().fg(Color::Cyan),
            );
            let line = ratatui::text::Line::from(vec![colored_icon, text]);
            ListItem::new(line)
        })
        .collect();
    let list = List::new(items).block(block).highlight_style(if is_focused {
        Style::default().bg(Color::Rgb(170, 225, 225)).fg(Color::Black).add_modifier(Modifier::BOLD)
    } else {
        Style::default().bg(Color::Cyan).fg(Color::Black).add_modifier(Modifier::BOLD)
    });
    f.render_stateful_widget(list, area, &mut app.categories.state);
}
