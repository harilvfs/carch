use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, List, ListItem};

use crate::ui::state::App;
use crate::ui::widgets::paint_rounded_highlight;

fn create_block<'a>(title: &'a str, app: &App) -> Block<'a> {
    let border_color = app.theme.secondary;
    let mut block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(border_color))
        .style(Style::default().bg(Color::Reset));
    if !title.is_empty() {
        block = block.title(title);
    }
    block
}

// Marker for a multi-selected script.
const SELECTED_MARKER: &str = " \u{2713} ";
// Marker for a script that has a description.
const DESC_MARKER: &str = " (d)";

pub fn render_script_list(f: &mut Frame, app: &mut App, area: Rect) {
    let title = if app.multi_select.enabled {
        format!("[{} Selected]", app.multi_select.scripts.len())
    } else {
        String::new()
    };
    let block = create_block(&title, app);

    let items: Vec<ListItem> = app
        .scripts
        .items
        .iter()
        .map(|item| {
            let is_selected = app.multi_select.enabled && app.is_script_selected(&item.path);
            let has_desc = app.has_description(&item.category, &item.name);

            let prefix = if is_selected { SELECTED_MARKER } else { "   " };
            let suffix = if has_desc { DESC_MARKER } else { "" };

            let marker_color = if is_selected { app.theme.success } else { app.theme.secondary };
            let name_color = if is_selected {
                app.theme.success
            } else if has_desc {
                app.theme.foreground
            } else {
                app.theme.secondary
            };
            let name_modifier =
                if is_selected { Modifier::BOLD | Modifier::UNDERLINED } else { Modifier::empty() };

            let line = Line::from(vec![
                Span::styled(prefix, Style::default().fg(marker_color)),
                Span::styled(
                    &item.name,
                    Style::default().fg(name_color).add_modifier(name_modifier),
                ),
                Span::styled(
                    suffix,
                    Style::default().fg(app.theme.accent).add_modifier(Modifier::DIM),
                ),
            ]);
            ListItem::new(line)
        })
        .collect();

    let list = List::new(items).block(block).highlight_style(
        Style::default()
            .bg(app.theme.secondary)
            .fg(app.theme.background)
            .add_modifier(Modifier::BOLD),
    );

    f.render_stateful_widget(list, area, &mut app.scripts.state);
    paint_rounded_highlight(f, area, &app.scripts.state, app.theme.secondary);
}
