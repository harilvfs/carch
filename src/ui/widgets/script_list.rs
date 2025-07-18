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
        .border_style(Style::default().fg(Color::Green))
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
            let script_name_style = Style::default().fg(Color::LightGreen);
            let script_name = ratatui::text::Span::styled(&item.name, script_name_style);

            if app.multi_select.enabled {
                let is_selected = is_script_selected(app, &item.path);
                let prefix = if is_selected { "[✓] " } else { "[ ] " };
                let style = if is_selected {
                    Style::default().fg(Color::Green).add_modifier(Modifier::BOLD)
                } else {
                    Style::default().fg(Color::LightGreen)
                };

                let icon_style =
                    Style::default().fg(Color::LightGreen).add_modifier(Modifier::BOLD);

                let line = ratatui::text::Line::from(vec![
                    ratatui::text::Span::styled(prefix, style),
                    ratatui::text::Span::styled(icon, icon_style),
                    ratatui::text::Span::styled(&item.name, style),
                ]);
                ListItem::new(line)
            } else {
                let icon_style =
                    Style::default().fg(Color::LightGreen).add_modifier(Modifier::BOLD);
                let line = ratatui::text::Line::from(vec![
                    ratatui::text::Span::styled(icon, icon_style),
                    script_name,
                ]);
                ListItem::new(line)
            }
        })
        .collect();

    let list = List::new(items).block(block).highlight_style(if is_focused {
        Style::default().bg(Color::Rgb(170, 225, 170)).fg(Color::Black).add_modifier(Modifier::BOLD)
    } else {
        Style::default().bg(Color::DarkGray).fg(Color::White)
    });

    f.render_stateful_widget(list, area, &mut app.scripts.state);
}
