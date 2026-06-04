use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, List, ListItem};

use crate::ui::state::App;
use crate::ui::widgets::paint_rounded_highlight;

pub fn render_category_list(f: &mut Frame, app: &mut App, area: Rect) {
    let border_color = app.theme.primary;
    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(border_color))
        .style(Style::default().bg(Color::Reset));

    let items: Vec<ListItem> = app
        .categories
        .items
        .iter()
        .map(|category_name| {
            let selected_in_category = app
                .all_scripts
                .get(category_name)
                .map(|scripts| {
                    scripts.iter().filter(|item| app.is_script_selected(&item.path)).count()
                })
                .unwrap_or(0);

            if selected_in_category > 0 {
                let label = format!("{} (\u{2713} {})", category_name, selected_in_category);
                let line = Line::from(vec![
                    Span::styled("  ", Style::default().fg(app.theme.success)),
                    Span::styled(
                        label,
                        Style::default().fg(app.theme.success).add_modifier(Modifier::BOLD),
                    ),
                ]);
                ListItem::new(line)
            } else {
                let line = Line::from(vec![
                    Span::styled("  ", Style::default().fg(app.theme.primary)),
                    Span::styled(category_name.as_str(), Style::default().fg(app.theme.primary)),
                ]);
                ListItem::new(line)
            }
        })
        .collect();
    let list = List::new(items).block(block).highlight_style(
        Style::default()
            .bg(app.theme.primary)
            .fg(app.theme.background)
            .add_modifier(Modifier::BOLD),
    );
    f.render_stateful_widget(list, area, &mut app.categories.state);
    paint_rounded_highlight(f, area, &app.categories.state, app.theme.primary);
}
