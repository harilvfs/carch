use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::Paragraph;

use crate::ui::state::{App, AppMode};
use crate::version;

/// draws the status bar at the bottom of the screen.
/// it shows the current mode, help text, and app version.
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
        AppMode::RunScript => "Running",
    };

    let mode_color = match app.mode {
        AppMode::Normal => {
            if app.multi_select.enabled {
                Color::Magenta
            } else {
                Color::Green
            }
        }
        AppMode::Preview => Color::Cyan,
        AppMode::Search => Color::Yellow,
        AppMode::Confirm => Color::Red,
        AppMode::Help => Color::Blue,
        AppMode::RunScript => Color::Yellow,
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
            Style::default().bg(mode_color).fg(Color::Black).add_modifier(Modifier::BOLD),
        ),
        Span::raw(" "),
        if has_selected {
            Span::styled(
                selected_count,
                Style::default().bg(Color::Yellow).fg(Color::Black).add_modifier(Modifier::BOLD),
            )
        } else {
            Span::raw("")
        },
        if has_selected { Span::raw(" ") } else { Span::raw("") },
        Span::styled(
            " ?: Help | q: Quit | h/l: Switch panels",
            Style::default().bg(Color::Rgb(203, 166, 247)).fg(Color::Black),
        ),
        Span::raw(" "),
        Span::styled(
            format!(" {version} "),
            Style::default().bg(Color::Cyan).fg(Color::Black).add_modifier(Modifier::BOLD),
        ),
    ]);

    let status_widget = Paragraph::new(status).style(Style::default().bg(Color::Reset));

    f.render_widget(status_widget, area);
}
