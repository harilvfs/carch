use ratatui::Frame;
use ratatui::layout::{Alignment, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph};

use crate::ui::state::App;
use crate::ui::theme::Theme;

#[derive(Clone, Copy)]
enum Kind {
    Header,
    Key,
    NavKey,
    Body,
}

const HELP_LINES: &[(&[&str], &[Kind])] = &[
    (&["Navigation"], &[Kind::Header]),
    (&[], &[]),
    (
        &[" \u{2191}/\u{2193} ", " ", "Move up/down in the script list"],
        &[Kind::NavKey, Kind::Body, Kind::Body],
    ),
    (&[], &[]),
    (
        &[" h/l ", " ", "Switch between categories and scripts"],
        &[Kind::NavKey, Kind::Body, Kind::Body],
    ),
    (&[], &[]),
    (&[" Home/End ", " ", "Jump to top/bottom of list"], &[Kind::NavKey, Kind::Body, Kind::Body]),
    (&[], &[]),
    (&["Actions"], &[Kind::Header]),
    (&[], &[]),
    (&[" Enter ", " ", "Run selected script"], &[Kind::Key, Kind::Body, Kind::Body]),
    (&[], &[]),
    (
        &[" Space ", " ", "Toggle script selection in multi-select mode"],
        &[Kind::Key, Kind::Body, Kind::Body],
    ),
    (&[], &[]),
    (&[" p ", " ", "Toggle preview for scripts"], &[Kind::Key, Kind::Body, Kind::Body]),
    (&[], &[]),
    (&[" d ", " ", "Show script description"], &[Kind::Key, Kind::Body, Kind::Body]),
    (&[], &[]),
    (&[" q, Esc ", " ", "Quit | Go back"], &[Kind::Key, Kind::Body, Kind::Body]),
    (&[], &[]),
    (&[" Ctrl+C/q ", " ", "Quit TUI (normal mode)"], &[Kind::Key, Kind::Body, Kind::Body]),
    (&[], &[]),
    (&["Modes"], &[Kind::Header]),
    (&[], &[]),
    (&[" / ", " ", "Search mode"], &[Kind::Key, Kind::Body, Kind::Body]),
    (&[], &[]),
    (
        &[" m ", " ", "Toggle multi-select mode", " | ", " Esc ", " ", "Exit multi-select mode"],
        &[Kind::Key, Kind::Body, Kind::Body, Kind::Body, Kind::Key, Kind::Body, Kind::Body],
    ),
    (&[], &[]),
    (&[" t ", " ", "Cycle themes"], &[Kind::Key, Kind::Body, Kind::Body]),
    (&[], &[]),
    (&[" ? ", " ", "Show this help"], &[Kind::Key, Kind::Body, Kind::Body]),
    (&[], &[]),
    (&["Quick Actions"], &[Kind::Header]),
    (&[], &[]),
    (&[" l/-> ", " ", "Confirm selection (same as Enter)"], &[Kind::Key, Kind::Body, Kind::Body]),
    (&[], &[]),
    (&[" h/<- ", " ", "Cancel selection (same as Esc)"], &[Kind::Key, Kind::Body, Kind::Body]),
    (&[], &[]),
    (&["Legend"], &[Kind::Header]),
    (&[], &[]),
    (
        &[" \u{2713} ", " ", "Script is selected (multi-select)"],
        &[Kind::NavKey, Kind::Body, Kind::Body],
    ),
];

fn style_for(kind: Kind, theme: &Theme) -> Style {
    match kind {
        Kind::Header => Style::default().fg(theme.warning).add_modifier(Modifier::BOLD),
        Kind::NavKey => Style::default().bg(theme.primary).fg(theme.background),
        Kind::Key => Style::default().bg(theme.success).fg(theme.background),
        Kind::Body => Style::default(),
    }
}

fn build_help_content(theme: &Theme) -> Vec<Line<'static>> {
    HELP_LINES
        .iter()
        .map(|(texts, kinds)| {
            if texts.is_empty() {
                Line::from("")
            } else {
                let spans: Vec<_> = texts
                    .iter()
                    .zip(kinds.iter())
                    .map(|(t, k)| Span::styled((*t).to_string(), style_for(*k, theme)))
                    .collect();
                Line::from(spans)
            }
        })
        .collect()
}

fn create_rounded_block() -> Block<'static> {
    Block::default().borders(Borders::ALL).border_type(BorderType::Rounded)
}

pub fn render_help_popup(f: &mut Frame, app: &App, area: Rect) -> u16 {
    f.render_widget(Clear, area);

    let popup_block = create_rounded_block()
        .title("Keyboard Shortcuts")
        .border_style(Style::default().fg(app.theme.primary));

    let inner = popup_block.inner(area);
    f.render_widget(popup_block, area);
    let content_area = Rect {
        x:      inner.x + 1,
        y:      inner.y,
        width:  inner.width.saturating_sub(2),
        height: inner.height.saturating_sub(2),
    };

    let help_content = build_help_content(&app.theme);
    let content_height = help_content.len() as u16;
    let max_scroll = content_height.saturating_sub(content_area.height);

    let help_paragraph =
        Paragraph::new(help_content).block(Block::default()).scroll((app.help.scroll, 0));

    f.render_widget(help_paragraph, content_area);

    let footer_area = Rect {
        x:      area.x + 1,
        y:      area.y + area.height.saturating_sub(2),
        width:  area.width.saturating_sub(2),
        height: 1,
    };

    let scroll_status = if max_scroll > 0 {
        format!("{}/{}", app.help.scroll.min(max_scroll), max_scroll)
    } else {
        "No scroll needed".to_string()
    };

    let footer = Paragraph::new(Line::from(vec![
        Span::styled("\u{2191}/\u{2193}/j/k: ", Style::default().fg(app.theme.foreground)),
        Span::styled("Scroll  ", Style::default().fg(app.theme.primary)),
        Span::styled("Esc/q: ", Style::default().fg(app.theme.foreground)),
        Span::styled("Close", Style::default().fg(app.theme.primary)),
        Span::raw("  "),
        Span::styled(scroll_status, Style::default().fg(app.theme.secondary)),
    ]))
    .alignment(Alignment::Center);

    f.render_widget(footer, footer_area);

    max_scroll
}
