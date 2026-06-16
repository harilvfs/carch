use ratatui::Frame;
use ratatui::layout::{Alignment, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, List, ListItem, Paragraph};

use crate::ui::state::{App, FocusedPanel};
use crate::ui::widgets::paint_rounded_highlight;

fn create_block<'a>(title: &'a str, app: &App) -> Block<'a> {
    let is_focused = app.focused_panel == FocusedPanel::Scripts;
    let border_color = if is_focused { app.theme.primary } else { Color::Gray };
    let border_modifier = if is_focused { Modifier::BOLD } else { Modifier::empty() };

    let mut block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(border_color).add_modifier(border_modifier));
    if !title.is_empty() {
        block = block.title(Span::styled(title.to_string(), Style::default().fg(app.theme.accent)));
    }
    block
}

const TICK_SUFFIX: &str = " \u{2713}";

pub fn render_script_list(f: &mut Frame, app: &mut App, area: Rect) {
    let is_focused = app.focused_panel == FocusedPanel::Scripts;

    let title = if app.multi_select.enabled {
        let count = app.multi_select.scripts.len();
        format!(" Scripts [{count} Selected] ")
    } else {
        " Scripts ".to_string()
    };
    let block = create_block(&title, app);

    if app.scripts.items.is_empty() {
        let inner = block.inner(area);
        f.render_widget(block, area);
        let hint = if app.categories.items.is_empty() {
            "No categories found"
        } else {
            "No scripts in this category"
        };
        let empty = Paragraph::new(hint)
            .style(Style::default().fg(Color::Gray))
            .alignment(Alignment::Center);
        f.render_widget(empty, inner);
        return;
    }

    let items: Vec<ListItem> = app
        .scripts
        .items
        .iter()
        .map(|item| {
            let is_selected = app.multi_select.enabled && app.is_script_selected(&item.path);
            let has_desc = app.has_description(&item.category, &item.name);

            let name_color = if is_selected {
                app.theme.success
            } else if is_focused {
                if has_desc { app.theme.foreground } else { app.theme.primary }
            } else {
                Color::Gray
            };
            let name_modifier = if is_selected { Modifier::BOLD } else { Modifier::empty() };

            let mut spans = vec![Span::styled(
                format!(" {name}", name = item.name),
                Style::default().fg(name_color).add_modifier(name_modifier),
            )];
            if is_selected {
                spans.push(Span::styled(
                    TICK_SUFFIX,
                    Style::default().fg(app.theme.success).add_modifier(Modifier::BOLD),
                ));
            }

            ListItem::new(Line::from(spans))
        })
        .collect();

    let list = List::new(items).block(block).highlight_style(
        Style::default()
            .bg(app.theme.primary)
            .fg(app.theme.background)
            .add_modifier(Modifier::BOLD),
    );

    f.render_stateful_widget(list, area, &mut app.scripts.state);
    paint_rounded_highlight(f, area, &app.scripts.state, app.theme.primary);
}
