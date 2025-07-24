use ratatui::Frame;
use ratatui::layout::{Alignment, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph};

use crate::ui::state::App;

fn create_rounded_block() -> Block<'static> {
    Block::default().borders(Borders::ALL).border_type(BorderType::Rounded)
}

/// draws the help pop-up with keyboard shortcuts.
pub fn render_help_popup(f: &mut Frame, app: &App, area: Rect) -> u16 {
    let popup_width = std::cmp::min(80, area.width.saturating_sub(4));
    let popup_height = std::cmp::min(20, area.height.saturating_sub(4));

    let popup_area = Rect {
        x:      area.x + (area.width - popup_width) / 2,
        y:      area.y + (area.height - popup_height) / 2,
        width:  popup_width,
        height: popup_height,
    };

    f.render_widget(Clear, popup_area);

    let popup_block = create_rounded_block()
        .title("keyboard shortcuts")
        .border_style(Style::default().fg(Color::Rgb(137, 180, 250)));

    f.render_widget(popup_block.clone(), popup_area);

    let content_area = Rect {
        x:      popup_block.inner(popup_area).x + 1,
        y:      popup_block.inner(popup_area).y,
        width:  popup_block.inner(popup_area).width.saturating_sub(2),
        height: popup_block.inner(popup_area).height.saturating_sub(2),
    };

    let mut help_content = Vec::new();

    help_content.push(Line::from(vec![Span::styled(
        "navigation",
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
    )]));
    help_content.push(Line::from(""));

    let nav_color = Color::Rgb(137, 180, 250);
    help_content.push(Line::from(vec![
        Span::styled(" ↑/↓ ", Style::default().bg(nav_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("move up/down in the script list", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" h/l ", Style::default().bg(nav_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("switch between categories and scripts", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" Home/End ", Style::default().bg(nav_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("jump to top/bottom of list", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![Span::styled(
        "actions",
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
    )]));
    help_content.push(Line::from(""));

    let action_color = Color::Rgb(166, 227, 161);
    help_content.push(Line::from(vec![
        Span::styled(" Enter ", Style::default().bg(action_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("run selected script", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" Space ", Style::default().bg(action_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled(
            "toggle script selection in multi-select mode",
            Style::default().fg(Color::Gray),
        ),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" p ", Style::default().bg(action_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("toggle preview for scripts", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" q, Esc ", Style::default().bg(action_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("quit | go back", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![Span::styled(
        "modes",
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
    )]));
    help_content.push(Line::from(""));

    let mode_color = Color::Rgb(203, 166, 247);
    help_content.push(Line::from(vec![
        Span::styled(" / ", Style::default().bg(mode_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("search mode", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" m ", Style::default().bg(mode_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("toggle multi-select mode", Style::default().fg(Color::Gray)),
        Span::raw(" | "),
        Span::styled(" Esc ", Style::default().bg(mode_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("exit multi-select mode", Style::default().fg(Color::Gray)),
    ]));

    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" ? ", Style::default().bg(mode_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("show this help", Style::default().fg(Color::Gray)),
    ]));

    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![Span::styled(
        "quick actions",
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
    )]));

    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" l ", Style::default().bg(action_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("confirm selection (same as enter)", Style::default().fg(Color::Gray)),
    ]));

    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" h ", Style::default().bg(action_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("cancel selection (same as esc)", Style::default().fg(Color::Gray)),
    ]));

    let content_height = help_content.len() as u16;
    let visible_height = content_area.height;
    let max_scroll = content_height.saturating_sub(visible_height);

    let help_paragraph =
        Paragraph::new(help_content).block(Block::default()).scroll((app.help.scroll, 0));

    f.render_widget(help_paragraph, content_area);

    let footer_area = Rect {
        x:      popup_area.x + 1,
        y:      popup_area.y + popup_area.height - 2,
        width:  popup_area.width - 2,
        height: 1,
    };

    let scroll_status = if max_scroll > 0 {
        format!("{}/{}", app.help.scroll.min(max_scroll), max_scroll)
    } else {
        "no scroll needed".to_string()
    };

    let footer = Paragraph::new(Line::from(vec![
        Span::styled("↑/↓/j/k: ", Style::default().fg(Color::Gray)),
        Span::styled("scroll  ", Style::default().fg(Color::Blue)),
        Span::styled("ESC/q: ", Style::default().fg(Color::Gray)),
        Span::styled("close", Style::default().fg(Color::Rgb(137, 180, 250))),
        Span::raw("  "),
        Span::styled(scroll_status, Style::default().fg(Color::DarkGray)),
    ]))
    .alignment(Alignment::Center);

    f.render_widget(footer, footer_area);

    max_scroll
}
