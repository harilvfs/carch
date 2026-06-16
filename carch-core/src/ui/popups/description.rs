use ratatui::Frame;
use ratatui::layout::{Constraint, Direction, Layout, Rect};
use ratatui::style::Style;
use ratatui::text::Text;
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph, Wrap};

use crate::ui::state::App;

pub fn render_description_popup(f: &mut Frame, app: &mut App, area: Rect) {
    let Some(description) = app.description.content.as_deref() else {
        return;
    };

    let popup_block = Block::default()
        .title(" Description ")
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(app.theme.primary));

    f.render_widget(Clear, area);
    f.render_widget(popup_block, area);

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .margin(1)
        .constraints([Constraint::Min(1)])
        .split(area);

    let text = Text::from(description);
    let paragraph =
        Paragraph::new(text).wrap(Wrap { trim: true }).scroll((app.description.scroll, 0));

    let visible_width = chunks[0].width;
    let visible_height = chunks[0].height;
    let text_for_width = Text::from(description);
    let total_lines = text_for_width
        .lines
        .iter()
        .map(|line| {
            let width = line.width() as u16;
            if width == 0 || visible_width == 0 { 1 } else { width.div_ceil(visible_width) }
        })
        .sum::<u16>();
    app.description.max_scroll = total_lines.saturating_sub(visible_height);

    f.render_widget(paragraph, chunks[0]);
}
