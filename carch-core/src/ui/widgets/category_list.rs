use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, List, ListItem};

use crate::ui::state::{App, FocusedPanel};
use crate::ui::widgets::paint_rounded_highlight;

pub fn render_category_list(f: &mut Frame, app: &mut App, area: Rect) {
    let is_focused = app.focused_panel == FocusedPanel::Categories;
    let border_color = if is_focused { app.theme.primary } else { Color::DarkGray };
    let border_modifier = if is_focused { Modifier::BOLD } else { Modifier::empty() };

    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(border_color).add_modifier(border_modifier));

    let items: Vec<ListItem> = app
        .categories
        .items
        .iter()
        .map(|category_name| {
            let selected_in_category = app.all_scripts.get(category_name).map_or(0, |scripts| {
                scripts.iter().filter(|item| app.is_script_selected(&item.path)).count()
            });

            let text_color = if is_focused { app.theme.primary } else { Color::DarkGray };

            if selected_in_category > 0 {
                let label = format!(" {category_name} (\u{2713} {selected_in_category})");
                let line = Line::from(Span::styled(
                    label,
                    Style::default().fg(app.theme.success).add_modifier(Modifier::BOLD),
                ));
                ListItem::new(line)
            } else {
                let label = format!(" {category_name}");
                let line = Line::from(Span::styled(label, Style::default().fg(text_color)));
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
