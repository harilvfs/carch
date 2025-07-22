use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::widgets::{Block, BorderType, Borders, List, ListItem};

use crate::ui::actions::is_script_selected;
use crate::ui::state::{App, FocusedPanel};

fn create_block(title: &str, _is_focused: bool) -> Block<'_> {
    Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title(title)
        .border_style(Style::default().fg(Color::Rgb(137, 180, 250)))
        .style(Style::default().bg(Color::Reset))
}

pub fn render_script_list(f: &mut Frame, app: &mut App, area: Rect) {
    let is_focused = app.focused_panel == FocusedPanel::Scripts;
    let title = if app.multi_select.enabled {
        format!("[{} selected]", app.multi_select.scripts.len())
    } else {
        "Scripts (p for preview)".to_string()
    };
    let block = create_block(&title, is_focused);

    let items: Vec<ListItem> = app
        .scripts
        .items
        .iter()
        .map(|item| {
            let icon = " ";
            let script_name_style = Style::default().fg(Color::Rgb(173, 216, 190));
            let script_name = ratatui::text::Span::styled(&item.name, script_name_style);

            if app.multi_select.enabled {
                let is_selected = is_script_selected(app, &item.path);
                let prefix = if is_selected { "[✓] " } else { "[ ] " };

                let prefix_style = if is_selected {
                    Style::default().fg(Color::Rgb(173, 216, 190)).add_modifier(Modifier::BOLD)
                } else {
                    Style::default().fg(Color::Rgb(173, 216, 190))
                };

                let script_name_style = if is_selected {
                    Style::default().fg(Color::Rgb(173, 216, 190)).add_modifier(Modifier::BOLD)
                } else {
                    Style::default().fg(Color::Rgb(173, 216, 190))
                };

                let icon_style =
                    Style::default().fg(Color::Rgb(173, 216, 190)).add_modifier(Modifier::BOLD);

                let line = ratatui::text::Line::from(vec![
                    ratatui::text::Span::styled(prefix, prefix_style),
                    ratatui::text::Span::styled(icon, icon_style),
                    ratatui::text::Span::styled(&item.name, script_name_style),
                ]);
                ListItem::new(line)
            } else {
                let icon_style =
                    Style::default().fg(Color::Rgb(173, 216, 190)).add_modifier(Modifier::BOLD);
                let line = ratatui::text::Line::from(vec![
                    ratatui::text::Span::styled(icon, icon_style),
                    script_name,
                ]);
                ListItem::new(line)
            }
        })
        .collect();

    let list = List::new(items).block(block).highlight_style(
        Style::default()
            .bg(Color::Rgb(173, 216, 190))
            .fg(Color::Black)
            .add_modifier(Modifier::BOLD),
    );

    f.render_stateful_widget(list, area, &mut app.scripts.state);
}
