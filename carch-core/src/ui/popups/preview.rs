use std::sync::LazyLock;

use ratatui::Frame;
use ratatui::layout::{Constraint, Direction, Layout, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span, Text};
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph, Wrap};
use syntect::easy::HighlightLines;
use syntect::highlighting::ThemeSet;
use syntect::parsing::SyntaxSet;
use syntect::util::LinesWithEndings;

use crate::ui::state::App;

static SYNTAX_SET: LazyLock<SyntaxSet> = LazyLock::new(SyntaxSet::load_defaults_newlines);
static THEME_SET: LazyLock<ThemeSet> = LazyLock::new(ThemeSet::load_defaults);

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

pub fn render_preview_popup(f: &mut Frame, app: &mut App, area: Rect) {
    f.render_widget(Clear, area);

    let selected_script = app.scripts.state.selected().and_then(|idx| app.scripts.items.get(idx));

    let title = if let Some(script) = selected_script {
        format!(" Preview: {}/{} ", script.category, script.name)
    } else {
        " Preview ".to_string()
    };

    let popup_block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title(Span::styled(
            title,
            Style::default().fg(app.theme.primary).add_modifier(Modifier::BOLD),
        ))
        .border_style(Style::default().fg(app.theme.primary));

    let inner = popup_block.inner(area);
    f.render_widget(popup_block, area);

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .margin(1)
        .constraints([Constraint::Min(1)])
        .split(inner);

    let preview_text = if let Some(selected) = app.scripts.state.selected() {
        let script_path = &app.scripts.items[selected].path;
        if let Some(cached) = app.preview.cache.get(script_path) {
            cached.clone()
        } else {
            let text = highlight_script(&app.preview.content, &SYNTAX_SET, &THEME_SET);
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
}

fn highlight_script(content: &str, ps: &SyntaxSet, ts: &ThemeSet) -> Text<'static> {
    let syntax = ps.find_syntax_by_extension("sh").unwrap_or_else(|| ps.find_syntax_plain_text());
    let theme = ts
        .themes
        .get("base16-ocean.dark")
        .or_else(|| ts.themes.values().next())
        .expect("syntect theme set is non-empty");

    let mut highlighter = HighlightLines::new(syntax, theme);
    let mut lines = Vec::new();

    for line in LinesWithEndings::from(content) {
        let ranges = highlighter.highlight_line(line, ps).unwrap_or_default();
        let spans: Vec<_> = ranges
            .into_iter()
            .map(|(style, text)| {
                Span::styled(
                    text.to_string(),
                    Style::default().fg(Color::Rgb(
                        style.foreground.r,
                        style.foreground.g,
                        style.foreground.b,
                    )),
                )
            })
            .collect();
        lines.push(Line::from(spans));
    }

    Text::from(lines)
}
