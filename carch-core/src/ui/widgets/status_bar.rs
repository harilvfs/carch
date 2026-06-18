use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::Paragraph;

use crate::ui::state::{App, AppMode, FocusedPanel};
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
        AppMode::TermuxWarning => ("Note", app.theme.warning),
    }
}

fn contextual_hints(app: &App) -> &'static str {
    match app.mode {
        AppMode::Normal
            if app.multi_select.enabled && app.focused_panel == FocusedPanel::Scripts =>
        {
            "j/k:Move  h/l:Panel  Space:Select  Enter:Run  d:Desc  p:Preview  Esc:Exit Multi  /:Search  ?:Help"
        }
        AppMode::Normal if app.multi_select.enabled => {
            "j/k:Move  h/l:Panel  Esc:Exit Multi  /:Search  ?:Help"
        }
        AppMode::Normal if app.focused_panel == FocusedPanel::Scripts => {
            "j/k:Move  h/l:Panel  Enter:Run  d:Desc  /:Search  p:Preview  m:Multi  t:Theme  ?:Help  q:Quit"
        }
        AppMode::Normal => "j/k:Move  h/l:Panel  m:Multi  t:Theme  /:Search  ?:Help  q:Quit",
        AppMode::Search => "Type:Search  Tab:Complete  Enter:Select  Esc:Close",
        AppMode::Preview => "j/k:Scroll  PgUp/PgDn:Page  Esc:Close",
        AppMode::Help => "j/k:Scroll  PgUp/PgDn:Page  Esc:Close",
        AppMode::Confirm => "y:Confirm  n/Esc:Cancel",
        AppMode::Description => "j/k:Scroll  Esc:Close",
        AppMode::RunScript => "Ctrl+C:Kill  PgUp/PgDn:Scroll",
        AppMode::RootWarning => "y:Continue  n:Quit",
        AppMode::TermuxWarning => "o:Acknowledge",
    }
}

pub fn render_status_bar(f: &mut Frame, app: &App, area: Rect) {
    let (mode_text, mode_color) = mode_info(app);
    let version = version::get_current_version();
    let hints = contextual_hints(app);
    let sep = Span::styled(" │ ", Style::default().fg(Color::DarkGray));

    let left = Line::from(vec![
        Span::styled(mode_text, Style::default().fg(mode_color).add_modifier(Modifier::BOLD)),
        sep.clone(),
        Span::styled(hints, Style::default().fg(app.theme.secondary)),
    ]);

    let right = Line::from(vec![
        Span::styled(app.theme.name.as_str(), Style::default().fg(app.theme.accent)),
        sep.clone(),
        Span::styled(version, Style::default().fg(app.theme.primary).add_modifier(Modifier::BOLD)),
    ]);

    f.render_widget(Paragraph::new(left), area);
    f.render_widget(Paragraph::new(right).alignment(ratatui::layout::Alignment::Right), area);
}
