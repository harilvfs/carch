use ratatui::Frame;
use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span, Text};
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph, Wrap};
use syntect::easy::HighlightLines;
use syntect::highlighting::ThemeSet;
use syntect::parsing::SyntaxSet;
use syntect::util::LinesWithEndings;

use crate::ui::state::App;

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
        .title(Span::styled(
            title,
            Style::default().fg(Color::Rgb(137, 180, 250)).add_modifier(Modifier::BOLD),
        ))
        .border_style(Style::default().fg(Color::Rgb(137, 180, 250)));

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
