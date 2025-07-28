use ratatui::Frame;
use ratatui::layout::{Alignment, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph};

use crate::ui::state::App;

fn create_rounded_block() -> Block<'static> {
    Block::default().borders(Borders::ALL).border_type(BorderType::Rounded)
}

/// draws the help pop-up with keyboard shortcuts
pub fn render_help_popup(f: &mut Frame, app: &App, area: Rect) -> u16 {
    f.render_widget(Clear, area);

    let popup_block = create_rounded_block()
        .title("Keyboard Shortcuts")
        .border_style(Style::default().fg(app.theme.primary));

    f.render_widget(popup_block.clone(), area);

    let content_area = Rect {
        x:      popup_block.inner(area).x + 1,
        y:      popup_block.inner(area).y,
        width:  popup_block.inner(area).width.saturating_sub(2),
        height: popup_block.inner(area).height.saturating_sub(2),
    };

    let mut help_content = Vec::new();

    help_content.push(Line::from(vec![Span::styled(
        "Navigation",
        Style::default().fg(app.theme.warning).add_modifier(Modifier::BOLD),
    )]));
    help_content.push(Line::from(""));

    let nav_color = app.theme.primary;
    help_content.push(Line::from(vec![
        Span::styled(" ↑/↓ ", Style::default().bg(nav_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled("Move up/down in the script list", Style::default().fg(app.theme.foreground)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" h/l ", Style::default().bg(nav_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled(
            "Switch between categories and scripts",
            Style::default().fg(app.theme.foreground),
        ),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" Home/End ", Style::default().bg(nav_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled("Jump to top/bottom of list", Style::default().fg(app.theme.foreground)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![Span::styled(
        "Actions",
        Style::default().fg(app.theme.warning).add_modifier(Modifier::BOLD),
    )]));
    help_content.push(Line::from(""));

    let action_color = app.theme.success;
    help_content.push(Line::from(vec![
        Span::styled(" Enter ", Style::default().bg(action_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled("Run selected script", Style::default().fg(app.theme.foreground)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" Space ", Style::default().bg(action_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled(
            "Toggle script selection in multi-select mode",
            Style::default().fg(app.theme.foreground),
        ),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" p ", Style::default().bg(action_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled("Toggle preview for scripts", Style::default().fg(app.theme.foreground)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" d ", Style::default().bg(action_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled("Show script description", Style::default().fg(app.theme.foreground)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" q, Esc ", Style::default().bg(action_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled("Quit | Go back", Style::default().fg(app.theme.foreground)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![Span::styled(
        "Modes",
        Style::default().fg(app.theme.warning).add_modifier(Modifier::BOLD),
    )]));
    help_content.push(Line::from(""));

    let mode_color = app.theme.accent;
    help_content.push(Line::from(vec![
        Span::styled(" / ", Style::default().bg(mode_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled("Search mode", Style::default().fg(app.theme.foreground)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" m ", Style::default().bg(mode_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled("Toggle multi-select mode", Style::default().fg(app.theme.foreground)),
        Span::raw(" | "),
        Span::styled(" Esc ", Style::default().bg(mode_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled("Exit multi-select mode", Style::default().fg(app.theme.foreground)),
    ]));

    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" ? ", Style::default().bg(mode_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled("Show this help", Style::default().fg(app.theme.foreground)),
    ]));

    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![Span::styled(
        "Quick Actions",
        Style::default().fg(app.theme.warning).add_modifier(Modifier::BOLD),
    )]));

    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" l/-> ", Style::default().bg(action_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled(
            "Confirm selection (same as Enter)",
            Style::default().fg(app.theme.foreground),
        ),
    ]));

    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" h/<- ", Style::default().bg(action_color).fg(app.theme.background)),
        Span::raw(" "),
        Span::styled("Cancel selection (same as Esc)", Style::default().fg(app.theme.foreground)),
    ]));

    let content_height = help_content.len() as u16;
    let visible_height = content_area.height;
    let max_scroll = content_height.saturating_sub(visible_height);

    let help_paragraph =
        Paragraph::new(help_content).block(Block::default()).scroll((app.help.scroll, 0));

    f.render_widget(help_paragraph, content_area);

    let footer_area = Rect {
        x:      area.x + 1,
        y:      area.y + area.height - 2,
        width:  area.width - 2,
        height: 1,
    };

    let scroll_status = if max_scroll > 0 {
        format!("{}/{}", app.help.scroll.min(max_scroll), max_scroll)
    } else {
        "No scroll needed".to_string()
    };

    let footer = Paragraph::new(Line::from(vec![
        Span::styled("↑/↓/j/k: ", Style::default().fg(app.theme.foreground)),
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
