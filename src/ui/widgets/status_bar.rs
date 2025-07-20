use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::Paragraph;

use crate::ui::state::{App, AppMode};
use crate::version;

pub fn render_status_bar(f: &mut Frame, app: &App, area: Rect) {
    let mode_text = match app.mode {
        AppMode::Normal => "NORMAL",
        AppMode::Preview => "PREVIEW",
        AppMode::Search => "SEARCH",
        AppMode::Confirm => "CONFIRM",
        AppMode::Help => "HELP",
        AppMode::RunScript => "RUNNING",
    };

    let mode_color = match app.mode {
        AppMode::Normal => Color::Green,
        AppMode::Preview => Color::Cyan,
        AppMode::Search => Color::Yellow,
        AppMode::Confirm => Color::Red,
        AppMode::Help => Color::Blue,
        AppMode::RunScript => Color::Yellow,
    };

    let version = version::get_current_version();

    let status = Line::from(vec![
        Span::styled(
            format!(" MODE: {mode_text} "),
            Style::default().bg(mode_color).fg(Color::Black).add_modifier(Modifier::BOLD),
        ),
        Span::raw(" "),
        Span::styled(
            " ?: Help | q: Quit | h/l: Switch Panels",
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
