use ratatui::Frame;
use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Color, Modifier, Style, Stylize};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, Clear, List, ListItem, Paragraph};

use crate::ui::state::App;

/// draws the search pop-up.
/// it shows a search box and a list of results.
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

    let popup_block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title("Search")
        .border_style(Style::default().fg(Color::Rgb(137, 180, 250)));

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
        .block(
            Block::default()
                .borders(Borders::ALL)
                .border_type(BorderType::Rounded)
                .title("Type to search (Tab to complete)")
                .border_style(Style::default().fg(Color::Rgb(137, 180, 250))),
        )
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
            let result = &app.search.results[result_idx];
            let display_text = format!("{}/{}", result.item.category, result.item.name);

            if app.search.input.is_empty() {
                result_items.push(ListItem::new(Line::from(vec![Span::styled(
                    display_text,
                    Style::default().fg(Color::Gray),
                )])));
            } else {
                let mut spans = Vec::new();
                let mut last_idx = 0;
                for &idx in &result.indices {
                    if idx > last_idx {
                        spans.push(Span::styled(
                            display_text[last_idx..idx].to_string(),
                            Style::default().fg(Color::Gray),
                        ));
                    }
                    spans.push(Span::styled(
                        display_text[idx..idx + 1].to_string(),
                        Style::default().fg(Color::Rgb(137, 180, 250)).add_modifier(Modifier::BOLD),
                    ));
                    last_idx = idx + 1;
                }
                if last_idx < display_text.len() {
                    spans.push(Span::styled(
                        display_text[last_idx..].to_string(),
                        Style::default().fg(Color::Gray),
                    ));
                }
                result_items.push(ListItem::new(Line::from(spans)));
            }
        }
    }

    let result_count_text = format!("Found {} scripts", app.search.results.len());

    let search_results = List::new(result_items)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .border_type(BorderType::Rounded)
                .title(result_count_text)
                .border_style(Style::default().fg(Color::Rgb(137, 180, 250))),
        )
        .highlight_style(Style::default().bg(Color::Rgb(235, 235, 210)).fg(Color::Black).bold())
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
