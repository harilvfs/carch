use ratatui::Frame;
use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span, Text};
use ratatui::widgets::{Block, BorderType, Borders, Clear, List, ListItem, Paragraph, Wrap};
use syntect::easy::HighlightLines;
use syntect::highlighting::ThemeSet;
use syntect::parsing::SyntaxSet;
use syntect::util::LinesWithEndings;

use super::app::App;

fn div_ceil(a: u16, b: u16) -> u16 {
    if b == 0 { 0 } else { a.div_ceil(b) }
}

fn compute_total_lines(lines: &[Line], area_width: u16) -> u16 {
    lines
        .iter()
        .map(|line| {
            let width = line.width() as u16;
            if width == 0 { 1 } else { div_ceil(width, area_width) }
        })
        .sum()
}

fn create_rounded_block() -> Block<'static> {
    Block::default().borders(Borders::ALL).border_type(BorderType::Rounded)
}

pub fn render_preview_popup(f: &mut Frame, app: &mut App, area: Rect) {
    let popup_width = area.width.saturating_sub(4);
    let popup_height = area.height.saturating_sub(4);

    let popup_area = Rect {
        x:      area.x + (area.width - popup_width) / 2,
        y:      area.y + (area.height - popup_height) / 2,
        width:  popup_width,
        height: popup_height,
    };

    f.render_widget(Clear, popup_area);

    let selected_script = app.scripts.state.selected().and_then(|idx| app.scripts.items.get(idx));

    let title = if let Some(script) = selected_script {
        format!(" Preview: {}/{} ", script.category, script.name)
    } else {
        " Preview ".to_string()
    };

    let popup_block = create_rounded_block()
        .title(Span::styled(title, Style::default().fg(Color::Green).add_modifier(Modifier::BOLD)))
        .border_style(Style::default().fg(Color::Green));

    f.render_widget(popup_block.clone(), popup_area);

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .margin(1)
        .constraints([Constraint::Min(1), Constraint::Length(1)])
        .split(popup_block.inner(popup_area));

    let preview_text = if let Some(selected) = app.scripts.state.selected() {
        let script_path = &app.scripts.items[selected].path;
        if let Some(cached) = app.preview.cache.get(script_path) {
            cached.clone()
        } else {
            let ps = SyntaxSet::load_defaults_newlines();
            let ts = ThemeSet::load_defaults();
            let syntax = ps.find_syntax_by_extension("sh").unwrap();
            let theme = &ts.themes["base16-ocean.dark"];

            let mut highlighter = HighlightLines::new(syntax, theme);
            let mut lines = Vec::new();

            for line in LinesWithEndings::from(&app.preview.content) {
                let ranges: Vec<(syntect::highlighting::Style, &str)> =
                    highlighter.highlight_line(line, &ps).unwrap();
                let mut spans = Vec::new();
                for (style, text) in ranges {
                    spans.push(Span::styled(
                        text.to_string(),
                        Style::default().fg(Color::Rgb(
                            style.foreground.r,
                            style.foreground.g,
                            style.foreground.b,
                        )),
                    ));
                }
                lines.push(Line::from(spans));
            }
            let text = Text::from(lines);
            app.preview.cache.insert(script_path.clone(), text.clone());
            text
        }
    } else {
        Text::from("No script selected")
    };

    if let Some(area) = chunks.first() {
        let total_lines = compute_total_lines(&preview_text.lines, area.width);
        app.preview.max_scroll = total_lines.saturating_sub(area.height);
    } else {
        app.preview.max_scroll = 0;
    }

    let preview = Paragraph::new(preview_text)
        .block(Block::default().style(Style::default()))
        .scroll((app.preview.scroll, 0))
        .wrap(Wrap { trim: false });

    f.render_widget(preview, chunks[0]);

    let help_text = Paragraph::new(Line::from(vec![
        Span::styled(" Scroll: ", Style::default().fg(Color::DarkGray)),
        Span::styled("↑/↓/j/k", Style::default().fg(Color::Gray).add_modifier(Modifier::BOLD)),
        Span::styled("  Page: ", Style::default().fg(Color::DarkGray)),
        Span::styled("PgUp/PgDown", Style::default().fg(Color::Gray).add_modifier(Modifier::BOLD)),
        Span::styled("  Jump: ", Style::default().fg(Color::DarkGray)),
        Span::styled("Home/End", Style::default().fg(Color::Gray).add_modifier(Modifier::BOLD)),
        Span::styled("  Close: ", Style::default().fg(Color::DarkGray)),
        Span::styled("ESC/q", Style::default().fg(Color::Gray).add_modifier(Modifier::BOLD)),
    ]))
    .alignment(Alignment::Center);

    f.render_widget(help_text, chunks[1]);
}

pub fn render_search_popup(f: &mut Frame, app: &App, area: Rect) {
    let popup_width = std::cmp::min(70, area.width - 8);
    let popup_height = std::cmp::min(16, area.height - 6);

    let popup_area = Rect {
        x:      area.x + (area.width - popup_width) / 2,
        y:      area.y + (area.height - popup_height) / 2,
        width:  popup_width,
        height: popup_height,
    };

    f.render_widget(Clear, popup_area);

    let popup_block =
        create_rounded_block().title("Search").border_style(Style::default().fg(Color::Green));

    f.render_widget(popup_block.clone(), popup_area);

    let inner_area = popup_block.inner(popup_area);

    let popup_layout = Layout::default()
        .direction(Direction::Vertical)
        .constraints([Constraint::Length(3), Constraint::Min(3), Constraint::Length(2)])
        .split(inner_area);

    let display_text = if let Some(ref autocomplete) = app.search.autocomplete {
        let base = &app.search.input;
        let completion = &autocomplete[base.len()..];

        Line::from(vec![
            Span::styled(base.clone(), Style::default()),
            Span::styled(completion, Style::default().fg(Color::DarkGray)),
        ])
    } else {
        Line::from(app.search.input.clone())
    };

    let input = Paragraph::new(display_text)
        .block(create_rounded_block().title("Type to search (Tab to complete)"))
        .style(Style::default())
        .alignment(Alignment::Left);

    f.render_widget(input, popup_layout[0]);

    if app.search.cursor_position <= app.search.input.len() {
        f.set_cursor_position((
            popup_layout[0].x + 1 + app.search.cursor_position as u16,
            popup_layout[0].y + 1,
        ));
    }

    let mut result_items = Vec::new();

    let max_display = (popup_height - 5) as usize;
    let result_count = app.search.results.len();

    let display_count = std::cmp::min(result_count, max_display);
    let start_idx = if result_count <= max_display {
        0
    } else {
        let half_display = max_display / 2;
        if app.search.selected_idx < half_display {
            0
        } else if app.search.selected_idx >= result_count - half_display {
            result_count - max_display
        } else {
            app.search.selected_idx - half_display
        }
    };

    for i in 0..display_count {
        let result_idx = start_idx + i;
        if result_idx < app.search.results.len() {
            let item = &app.search.results[result_idx];
            let display_text = format!("{}/{}", item.category, item.name);

            result_items.push(ListItem::new(Line::from(vec![Span::styled(
                display_text,
                Style::default().fg(Color::Gray),
            )])));
        }
    }

    let result_count_text = format!("Found {} results", app.search.results.len());

    let search_results = List::new(result_items)
        .block(create_rounded_block().title(result_count_text))
        .highlight_style(
            Style::default()
                .bg(Color::Rgb(235, 235, 210))
                .fg(Color::Black)
                .add_modifier(Modifier::BOLD),
        )
        .highlight_symbol("");

    let mut search_list_state = ratatui::widgets::ListState::default();
    search_list_state.select(Some(app.search.selected_idx.saturating_sub(start_idx)));

    f.render_stateful_widget(search_results, popup_layout[1], &mut search_list_state);

    let help_block = Block::default()
        .border_type(BorderType::Plain)
        .borders(Borders::TOP)
        .border_style(Style::default().fg(Color::DarkGray));

    f.render_widget(help_block, popup_layout[2]);

    let help_inner_area = Rect {
        x:      popup_layout[2].x,
        y:      popup_layout[2].y + 1,
        width:  popup_layout[2].width,
        height: popup_layout[2].height - 1,
    };

    let help_text = Paragraph::new(Line::from(vec![
        Span::styled("↑/↓: Navigate  ", Style::default().fg(Color::Gray)),
        Span::styled("Tab: Complete  ", Style::default().fg(Color::Gray)),
        Span::styled("Enter: Select  ", Style::default().fg(Color::Gray)),
        Span::styled("Esc: Cancel", Style::default().fg(Color::Gray)),
    ]))
    .alignment(Alignment::Center);

    f.render_widget(help_text, help_inner_area);
}

pub fn render_confirmation_popup(f: &mut Frame, app: &App, area: Rect) {
    let popup_width = std::cmp::min(60, area.width - 8);
    let popup_height = if app.multi_select.enabled && !app.multi_select.scripts.is_empty() {
        std::cmp::min(20, area.height - 6)
    } else {
        11
    };

    let popup_area = Rect {
        x:      area.x + (area.width - popup_width) / 2,
        y:      area.y + (area.height - popup_height) / 2,
        width:  popup_width,
        height: popup_height,
    };

    f.render_widget(Clear, popup_area);

    let popup_block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title("Confirm selection")
        .border_style(Style::default().fg(Color::Green));

    let inner_area = popup_block.inner(popup_area);

    let content_layout = if app.multi_select.enabled && !app.multi_select.scripts.is_empty() {
        Layout::default()
            .direction(Direction::Vertical)
            .constraints([
                Constraint::Length(1),
                Constraint::Length(1),
                Constraint::Min(3),
                Constraint::Length(1),
                Constraint::Length(2),
            ])
            .split(inner_area)
    } else {
        Layout::default()
            .direction(Direction::Vertical)
            .constraints([
                Constraint::Length(1),
                Constraint::Length(2),
                Constraint::Length(1),
                Constraint::Length(2),
            ])
            .split(inner_area)
    };

    f.render_widget(popup_block, popup_area);

    let question_text = if app.multi_select.enabled && !app.multi_select.scripts.is_empty() {
        "Do you want to run these scripts?"
    } else {
        "Do you want to run this script?"
    };

    let question_paragraph = Paragraph::new(Line::from(vec![Span::styled(
        question_text,
        Style::default().fg(Color::Gray),
    )]))
    .alignment(Alignment::Center);

    f.render_widget(question_paragraph, content_layout[0]);

    if app.multi_select.enabled && !app.multi_select.scripts.is_empty() {
        let count_text = Paragraph::new(Line::from(vec![Span::styled(
            format!("{} scripts selected:", app.multi_select.scripts.len()),
            Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
        )]))
        .alignment(Alignment::Center);

        f.render_widget(count_text, content_layout[1]);

        let mut script_items = Vec::new();
        let max_display = (popup_height - 10) as usize;
        let display_count = std::cmp::min(app.multi_select.scripts.len(), max_display);

        for i in 0..display_count {
            let script_path = &app.multi_select.scripts[i];
            if let Some(script_name) = script_path.file_stem().and_then(|n| n.to_str())
                && let Some(category) =
                    script_path.parent().and_then(|p| p.file_name()).and_then(|n| n.to_str())
            {
                let display_text = format!("{category}/{script_name}");
                script_items.push(ListItem::new(Line::from(vec![
                    Span::styled(" • ".to_string(), Style::default().fg(Color::Green)),
                    Span::styled(display_text, Style::default().fg(Color::White)),
                ])));
            }
        }

        if app.multi_select.scripts.len() > max_display {
            let more_count = app.multi_select.scripts.len() - max_display;
            script_items.push(ListItem::new(Line::from(vec![Span::styled(
                format!("   ... and {more_count} more"),
                Style::default().fg(Color::DarkGray),
            )])));
        }

        let scripts_list = List::new(script_items);
        f.render_widget(scripts_list, content_layout[2]);

        let options_text = Paragraph::new(Line::from(vec![
            Span::styled("(y)", Style::default().fg(Color::Green)),
            Span::styled("es", Style::default().fg(Color::Gray)),
            Span::raw(" / "),
            Span::styled("(n)", Style::default().fg(Color::Red)),
            Span::styled("o", Style::default().fg(Color::Gray)),
        ]))
        .alignment(Alignment::Center);

        f.render_widget(options_text, content_layout[4]);
    } else {
        if let Some(idx) = app.scripts.state.selected() {
            let script_text = Paragraph::new(Line::from(vec![Span::styled(
                format!("{}/{}", app.scripts.items[idx].category, app.scripts.items[idx].name),
                Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
            )]))
            .alignment(Alignment::Center);

            f.render_widget(script_text, content_layout[1]);
        }

        let options_text = Paragraph::new(Line::from(vec![
            Span::styled("(y)", Style::default().fg(Color::Green)),
            Span::styled("es", Style::default().fg(Color::Gray)),
            Span::raw(" / "),
            Span::styled("(n)", Style::default().fg(Color::Red)),
            Span::styled("o", Style::default().fg(Color::Gray)),
        ]))
        .alignment(Alignment::Center);

        f.render_widget(options_text, content_layout[3]);
    }
}

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
        .title("Keyboard Shortcuts")
        .border_style(Style::default().fg(Color::Green));

    f.render_widget(popup_block.clone(), popup_area);

    let content_area = Rect {
        x:      popup_block.inner(popup_area).x + 1,
        y:      popup_block.inner(popup_area).y,
        width:  popup_block.inner(popup_area).width.saturating_sub(2),
        height: popup_block.inner(popup_area).height.saturating_sub(2),
    };

    let mut help_content = Vec::new();

    help_content.push(Line::from(vec![Span::styled(
        "Navigation",
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
    )]));
    help_content.push(Line::from(""));

    let nav_color = Color::Rgb(137, 180, 250);
    help_content.push(Line::from(vec![
        Span::styled(" ↑/↓ ", Style::default().bg(nav_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("Navigate up/down in the script list", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" h/l ", Style::default().bg(nav_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("Switch between categories and scripts", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" Home/End ", Style::default().bg(nav_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("Jump to top/bottom of list", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![Span::styled(
        "Actions",
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
    )]));
    help_content.push(Line::from(""));

    let action_color = Color::Rgb(166, 227, 161);
    help_content.push(Line::from(vec![
        Span::styled(" Enter ", Style::default().bg(action_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("Run selected script", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" Space ", Style::default().bg(action_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled(
            "Toggle script selection in multi-select mode",
            Style::default().fg(Color::Gray),
        ),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" p ", Style::default().bg(action_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("Toggle preview for scripts", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" q, Esc ", Style::default().bg(action_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("Quit | Go back", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![Span::styled(
        "Modes",
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
    )]));
    help_content.push(Line::from(""));

    let mode_color = Color::Rgb(203, 166, 247);
    help_content.push(Line::from(vec![
        Span::styled(" / ", Style::default().bg(mode_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("Search mode", Style::default().fg(Color::Gray)),
    ]));
    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" m ", Style::default().bg(mode_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("Toggle multi-select mode", Style::default().fg(Color::Gray)),
        Span::raw(" | "),
        Span::styled(" Esc ", Style::default().bg(mode_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("Exit multi-select mode", Style::default().fg(Color::Gray)),
    ]));

    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" ? ", Style::default().bg(mode_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("Show this help", Style::default().fg(Color::Gray)),
    ]));

    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![Span::styled(
        "Quick Actions",
        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
    )]));

    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" l ", Style::default().bg(action_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("Confirm selection (same as Enter)", Style::default().fg(Color::Gray)),
    ]));

    help_content.push(Line::from(""));

    help_content.push(Line::from(vec![
        Span::styled(" h ", Style::default().bg(action_color).fg(Color::Black)),
        Span::raw(" "),
        Span::styled("Cancel selection (same as Esc)", Style::default().fg(Color::Gray)),
    ]));

    let content_height = help_content.len() as u16;
    let visible_height = content_area.height;
    let max_scroll = content_height.saturating_sub(visible_height);

    let help_paragraph = Paragraph::new(help_content)
        .block(Block::default())
        .scroll((app.help.scroll.min(max_scroll), 0));

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
        "No scroll needed".to_string()
    };

    let footer = Paragraph::new(Line::from(vec![
        Span::styled("↑/↓/j/k: ", Style::default().fg(Color::Gray)),
        Span::styled("Scroll  ", Style::default().fg(Color::Blue)),
        Span::styled("ESC/q: ", Style::default().fg(Color::Gray)),
        Span::styled("Close", Style::default().fg(Color::Green)),
        Span::raw("  "),
        Span::styled(scroll_status, Style::default().fg(Color::DarkGray)),
    ]))
    .alignment(Alignment::Center);

    f.render_widget(footer, footer_area);

    max_scroll
}
