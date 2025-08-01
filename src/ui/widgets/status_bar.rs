use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::Paragraph;

use crate::ui::state::{App, AppMode};
use crate::version;

pub fn render_status_bar(f: &mut Frame, app: &App, area: Rect) {
    let mode_text = match app.mode {
        AppMode::Normal => {
            if app.multi_select.enabled {
                "Multi-select (Space to select) | (Esc to exit)"
            } else {
                "Normal"
            }
        }
        AppMode::Preview => "Preview",
        AppMode::Search => "Search",
        AppMode::Confirm => "Confirm",
        AppMode::Help => "Help",
        AppMode::Description => "Description",
        AppMode::RunScript => "Running",
        AppMode::RootWarning => "Root Warning",
    };

    let mode_color = match app.mode {
        AppMode::Normal => {
            if app.multi_select.enabled {
                app.theme.accent
            } else {
                app.theme.success
            }
        }
        AppMode::Preview => app.theme.primary,
        AppMode::Search => app.theme.warning,
        AppMode::Confirm => app.theme.error,
        AppMode::Help => app.theme.primary,
        AppMode::Description => app.theme.primary,
        AppMode::RunScript => app.theme.warning,
        AppMode::RootWarning => app.theme.error,
    };

    let selected_count = if app.multi_select.enabled {
        format!(" {} selected ", app.multi_select.scripts.len())
    } else {
        String::new()
    };

    let has_selected = !selected_count.is_empty();
    let version = version::get_current_version();

    let status = Line::from(vec![
        Span::styled(
            format!(" Mode: {mode_text} "),
            Style::default().bg(mode_color).fg(app.theme.background).add_modifier(Modifier::BOLD),
        ),
        Span::raw(" "),
        if has_selected {
            Span::styled(
                selected_count,
                Style::default()
                    .bg(app.theme.warning)
                    .fg(app.theme.background)
                    .add_modifier(Modifier::BOLD),
            )
        } else {
            Span::raw("")
        },
        if has_selected { Span::raw(" ") } else { Span::raw("") },
        Span::styled(
            format!(" Theme: {} ", app.theme.name),
            Style::default().bg(app.theme.secondary).fg(app.theme.background),
        ),
        Span::raw(" "),
        Span::styled(
            " ?: Help | q: Quit | h/l: Switch panels",
            Style::default().bg(app.theme.accent).fg(app.theme.background),
        ),
        Span::raw(" "),
        Span::styled(
            format!(" {version} "),
            Style::default()
                .bg(app.theme.primary)
                .fg(app.theme.background)
                .add_modifier(Modifier::BOLD),
        ),
    ]);

    let status_widget = Paragraph::new(status).style(Style::default().bg(Color::Reset));

    f.render_widget(status_widget, area);
}
