use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, List, ListItem};

use crate::ui::state::{App, FocusedPanel};

pub fn render_category_list(f: &mut Frame, app: &mut App, area: Rect) {
    let border_color = if app.focused_panel == FocusedPanel::Categories {
        app.theme.primary
    } else {
        app.theme.secondary
    };
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title("Categories")
        .border_style(Style::default().fg(border_color))
        .style(Style::default().bg(Color::Reset));

    let items: Vec<ListItem> = app
        .categories
        .items
        .iter()
        .map(|category_name| {
            let line = Line::from(vec![
                Span::styled("  ", Style::default().fg(app.theme.primary)),
                Span::styled(category_name.as_str(), Style::default().fg(app.theme.primary)),
            ]);
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
