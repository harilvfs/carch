use ratatui::Frame;
use ratatui::layout::{Constraint, Direction, Layout, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, Clear, List, ListItem, Paragraph};

use crate::VALID_THEMES;
use crate::ui::state::App;

fn theme_label(name: &str) -> &str {
    match name {
        "catppuccin-mocha" => "Catppuccin Mocha",
        "dracula" => "Dracula",
        "gruvbox" => "Gruvbox",
        "nord" => "Nord",
        "rose-pine" => "Rosé Pine",
        _ => name,
    }
}

pub fn render_theme_selector_popup(f: &mut Frame, app: &App, area: Rect) {
    f.render_widget(Clear, area);

    let popup_block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title(" Select Default Theme ")
        .border_style(Style::default().fg(app.theme.primary));

    let inner_area = popup_block.inner(area);

    let layout = Layout::default()
        .direction(Direction::Vertical)
        .constraints([Constraint::Length(1), Constraint::Min(3), Constraint::Length(2)])
        .split(inner_area);

    f.render_widget(popup_block, area);

    let current_theme = app.theme.name.as_str();
    let current_label = Paragraph::new(Line::from(vec![
        Span::styled("Current: ", Style::default().fg(app.theme.secondary)),
        Span::styled(
            current_theme,
            Style::default().fg(app.theme.primary).add_modifier(Modifier::BOLD),
        ),
    ]));
    f.render_widget(current_label, layout[0]);

    let themes: Vec<ListItem> = VALID_THEMES
        .iter()
        .enumerate()
        .map(|(i, name)| {
            let label = theme_label(name);
            let prefix = if i == app.theme_selector.selected { "▸ " } else { "  " };
            let is_current = *name == app.theme.name;
            let suffix = if is_current { "  (active)" } else { "" };
            ListItem::new(Line::from(vec![
                Span::styled(prefix, Style::default().fg(app.theme.primary)),
                Span::styled(label, Style::default().fg(app.theme.foreground)),
                Span::styled(suffix, Style::default().fg(app.theme.secondary)),
            ]))
        })
        .collect();

    let list = List::new(themes).highlight_style(
        Style::default()
            .bg(app.theme.primary)
            .fg(app.theme.background)
            .add_modifier(Modifier::BOLD),
    );

    let mut list_state = ratatui::widgets::ListState::default();
    list_state.select(Some(app.theme_selector.selected));
    f.render_stateful_widget(list, layout[1], &mut list_state);

    let help = Paragraph::new(Line::from(vec![
        Span::styled(" ↑/↓ ", Style::default().fg(app.theme.secondary)),
        Span::styled("navigate", Style::default().fg(app.theme.foreground)),
        Span::raw("  "),
        Span::styled("Enter", Style::default().fg(app.theme.success)),
        Span::styled(" set default", Style::default().fg(app.theme.foreground)),
        Span::raw("  "),
        Span::styled("Esc/q", Style::default().fg(app.theme.error)),
        Span::styled(" cancel", Style::default().fg(app.theme.foreground)),
    ]));
    f.render_widget(help, layout[2]);
}
