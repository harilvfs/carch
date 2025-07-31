use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::widgets::{Block, BorderType, Borders, List, ListItem};

use crate::ui::state::{App, FocusedPanel};

fn create_block<'a>(title: &'a str, _is_focused: bool, app: &App) -> Block<'a> {
    Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title(title)
        .border_style(Style::default().fg(app.theme.primary))
        .style(Style::default().bg(Color::Reset))
}

pub fn render_script_list(f: &mut Frame, app: &mut App, area: Rect) {
    let is_focused = app.focused_panel == FocusedPanel::Scripts;
    let title = if app.multi_select.enabled {
        format!("[{} Selected]", app.multi_select.scripts.len())
    } else {
        "Scripts (p for preview)".to_string()
    };
    let block = create_block(&title, is_focused, app);

    let items: Vec<ListItem> = app
        .scripts
        .items
        .iter()
        .map(|item| {
            let icon = " ";
            let script_name_style = Style::default().fg(app.theme.secondary);
            let script_name = ratatui::text::Span::styled(&item.name, script_name_style);

            if app.multi_select.enabled {
                let is_selected = app.is_script_selected(&item.path);
                let prefix = if is_selected { "[✓] " } else { "[ ] " };

                let prefix_style = if is_selected {
                    Style::default().fg(app.theme.secondary).add_modifier(Modifier::BOLD)
                } else {
                    Style::default().fg(app.theme.secondary)
                };

                let script_name_style = if is_selected {
                    Style::default().fg(app.theme.secondary).add_modifier(Modifier::BOLD)
                } else {
                    Style::default().fg(app.theme.secondary)
                };

                let icon_style =
                    Style::default().fg(app.theme.secondary).add_modifier(Modifier::BOLD);

                let line = ratatui::text::Line::from(vec![
                    ratatui::text::Span::styled(prefix, prefix_style),
                    ratatui::text::Span::styled(icon, icon_style),
                    ratatui::text::Span::styled(&item.name, script_name_style),
                ]);
                ListItem::new(line)
            } else {
                let icon_style =
                    Style::default().fg(app.theme.secondary).add_modifier(Modifier::BOLD);
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
            .bg(app.theme.secondary)
            .fg(app.theme.background)
            .add_modifier(Modifier::BOLD),
    );

    f.render_stateful_widget(list, area, &mut app.scripts.state);
}
