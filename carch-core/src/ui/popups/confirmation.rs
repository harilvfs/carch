use ratatui::Frame;
use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::widgets::{Block, BorderType, Borders, Clear, List, ListItem, Paragraph};

use crate::ui::state::App;

pub fn render_confirmation_popup(f: &mut Frame, app: &App, area: Rect) {
    f.render_widget(Clear, area);

    let popup_block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .title("Confirm")
        .border_style(Style::default().fg(app.theme.primary));

    let inner_area = popup_block.inner(area);

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

    f.render_widget(popup_block, area);

    let question_text = if app.multi_select.enabled && !app.multi_select.scripts.is_empty() {
        "Do you want to run these scripts?"
    } else {
        "Do you want to run this script?"
    };

    let question_paragraph =
        Paragraph::new(ratatui::text::Line::from(vec![ratatui::text::Span::styled(
            question_text,
            Style::default().fg(app.theme.foreground),
        )]))
        .alignment(Alignment::Center);

    f.render_widget(question_paragraph, content_layout[0]);

    if app.multi_select.enabled && !app.multi_select.scripts.is_empty() {
        let count_text =
            Paragraph::new(ratatui::text::Line::from(vec![ratatui::text::Span::styled(
                format!("{} Scripts Selected:", app.multi_select.scripts.len()),
                Style::default().fg(app.theme.warning).add_modifier(Modifier::BOLD),
            )]))
            .alignment(Alignment::Center);

        f.render_widget(count_text, content_layout[1]);

        let mut script_items = Vec::new();
        let max_display = (area.height - 10) as usize;
        let display_count = std::cmp::min(app.multi_select.scripts.len(), max_display);

        for i in 0..display_count {
            let script_path = &app.multi_select.scripts[i];
            if let Some(script_name) = script_path.file_stem().and_then(|n| n.to_str())
                && let Some(category) =
                    script_path.parent().and_then(|p| p.file_name()).and_then(|n| n.to_str())
            {
                let display_text = format!("{category}/{script_name}");
                script_items.push(ListItem::new(ratatui::text::Line::from(vec![
                    ratatui::text::Span::styled(" • ", Style::default().fg(app.theme.success)),
                    ratatui::text::Span::styled(
                        display_text,
                        Style::default().fg(app.theme.foreground),
                    ),
                ])));
            }
        }

        if app.multi_select.scripts.len() > max_display {
            let more_count = app.multi_select.scripts.len() - max_display;
            script_items.push(ListItem::new(ratatui::text::Line::from(vec![
                ratatui::text::Span::styled(
                    format!("   ... and {more_count} more"),
                    Style::default().fg(app.theme.secondary),
                ),
            ])));
        }

        let scripts_list = List::new(script_items);
        f.render_widget(scripts_list, content_layout[2]);

        let options_text = Paragraph::new(ratatui::text::Line::from(vec![
            ratatui::text::Span::styled("(Y)", Style::default().fg(app.theme.success)),
            ratatui::text::Span::styled("es", Style::default().fg(app.theme.foreground)),
            ratatui::text::Span::raw(" / "),
            ratatui::text::Span::styled("(N)", Style::default().fg(app.theme.error)),
            ratatui::text::Span::styled("o", Style::default().fg(app.theme.foreground)),
        ]))
        .alignment(Alignment::Center);

        f.render_widget(options_text, content_layout[4]);
    } else {
        if let Some(idx) = app.scripts.state.selected() {
            let script_text =
                Paragraph::new(ratatui::text::Line::from(vec![ratatui::text::Span::styled(
                    format!("{}/{}", app.scripts.items[idx].category, app.scripts.items[idx].name),
                    Style::default().fg(app.theme.warning).add_modifier(Modifier::BOLD),
                )]))
                .alignment(Alignment::Center);

            f.render_widget(script_text, content_layout[1]);
        }

        let options_text = Paragraph::new(ratatui::text::Line::from(vec![
            ratatui::text::Span::styled("(Y)", Style::default().fg(app.theme.success)),
            ratatui::text::Span::styled("es", Style::default().fg(app.theme.foreground)),
            ratatui::text::Span::raw(" / "),
            ratatui::text::Span::styled("(N)", Style::default().fg(app.theme.error)),
            ratatui::text::Span::styled("o", Style::default().fg(app.theme.foreground)),
        ]))
        .alignment(Alignment::Center);

        f.render_widget(options_text, content_layout[3]);
    }
}
