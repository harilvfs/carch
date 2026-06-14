use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::Paragraph;

use crate::ui::state::{App, AppMode};
use crate::version;

fn mode_info(app: &App) -> (&'static str, Color) {
    match app.mode {
        AppMode::Normal if app.multi_select.enabled => ("[Multi-select]", app.theme.accent),
        AppMode::Normal => ("[Normal]", app.theme.success),
        AppMode::Preview => ("[Preview]", app.theme.primary),
        AppMode::Search => ("[Search]", app.theme.warning),
        AppMode::Confirm => ("[Confirm]", app.theme.error),
        AppMode::Help => ("[Help]", app.theme.primary),
        AppMode::Description => ("[Description]", app.theme.primary),
        AppMode::RunScript => ("[Running]", app.theme.warning),
        AppMode::RootWarning => ("[Root Warning]", app.theme.error),
    }
}

pub fn render_status_bar(f: &mut Frame, app: &App, area: Rect) {
    let (mode_text, mode_color) = mode_info(app);

    let selected_count = if app.multi_select.enabled {
        format!(" {} selected ", app.multi_select.scripts.len())
    } else {
        String::new()
    };
    let has_selected = !selected_count.is_empty();
    let version = version::get_current_version();

    let mut spans = vec![
        Span::styled(
            format!(" Mode: {mode_text} "),
            Style::default().fg(mode_color).add_modifier(Modifier::BOLD),
        ),
        Span::raw(" "),
    ];
    if has_selected {
        spans.push(Span::styled(
            selected_count,
            Style::default().fg(app.theme.warning).add_modifier(Modifier::BOLD),
        ));
        spans.push(Span::raw(" "));
    }
    spans.extend([
        Span::styled(
            format!(" Theme: {} ", app.theme.name),
            Style::default().fg(app.theme.secondary),
        ),
        Span::raw(" "),
        Span::styled(
            " ?: Help | q: Quit | h/l: Switch panels",
            Style::default().fg(app.theme.accent),
        ),
        Span::raw(" "),
        Span::styled(
            format!(" {version} "),
            Style::default().fg(app.theme.primary).add_modifier(Modifier::BOLD),
        ),
    ]);

    let status = Line::from(spans);
    let status_widget = Paragraph::new(status).style(Style::default().bg(Color::Reset));

    f.render_widget(status_widget, area);
}
