use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::widgets::{Block, BorderType, Borders, List, ListItem};

use crate::ui::state::App;

pub fn render_category_list(f: &mut Frame, app: &mut App, area: Rect) {
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title("Categories")
        .border_style(Style::default().fg(app.theme.primary))
        .style(Style::default().bg(Color::Reset));

    let items: Vec<ListItem> = app
        .categories
        .items
        .iter()
        .map(|category_name| {
            let icon = " 󰉋 ";
            let colored_icon =
                ratatui::text::Span::styled(icon, Style::default().fg(app.theme.primary));
            let text = ratatui::text::Span::styled(
                category_name.as_str(),
                Style::default().fg(app.theme.primary),
            );
            let line = ratatui::text::Line::from(vec![colored_icon, text]);
            ListItem::new(line)
        })
        .collect();
    let list = List::new(items).block(block).highlight_style(
        Style::default()
            .bg(app.theme.primary)
            .fg(app.theme.background)
            .add_modifier(Modifier::BOLD),
    );
    f.render_stateful_widget(list, area, &mut app.categories.state);
}
