use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::Paragraph;

use crate::ui::state::{App, AppMode};
use crate::version;

fn mode_info(app: &App) -> (&'static str, Color) {
    match app.mode {
        AppMode::Normal if app.multi_select.enabled => ("Multi", app.theme.accent),
        AppMode::Normal => ("Normal", app.theme.success),
        AppMode::Preview => ("Preview", app.theme.primary),
        AppMode::Search => ("Search", app.theme.warning),
        AppMode::Confirm => ("Confirm", app.theme.error),
        AppMode::Help => ("Help", app.theme.primary),
        AppMode::Description => ("Description", app.theme.primary),
        AppMode::RunScript => ("Running", app.theme.warning),
        AppMode::RootWarning => ("Root Warn", app.theme.error),
    }
}

pub fn render_status_bar(f: &mut Frame, app: &App, area: Rect) {
    let (mode_text, mode_color) = mode_info(app);
    let version = version::get_current_version();
    let sep = Span::styled(" │ ", Style::default().fg(Color::DarkGray));

    let mut spans = vec![
        Span::styled(mode_text, Style::default().fg(mode_color).add_modifier(Modifier::BOLD)),
        sep.clone(),
    ];

    spans.push(Span::styled(app.theme.name.as_str(), Style::default().fg(app.theme.secondary)));
    spans.push(sep.clone());
    spans.push(Span::styled("?:Help  q:Quit", Style::default().fg(app.theme.accent)));
    spans.push(Span::raw("  "));
    spans.push(Span::styled(
        version,
        Style::default().fg(app.theme.primary).add_modifier(Modifier::BOLD),
    ));

    let status = Line::from(spans);
    let status_widget = Paragraph::new(status);

    f.render_widget(status_widget, area);
}
