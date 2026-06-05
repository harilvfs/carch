pub mod category_list;
pub mod header;
pub mod script_list;
pub mod status_bar;

use ratatui::Frame;
use ratatui::layout::Rect;
use ratatui::style::{Color, Style};
use ratatui::widgets::ListState;

const ROUNDED_LEFT: &str = "\u{e0b6}";
const ROUNDED_RIGHT: &str = "\u{e0b4}";

pub fn paint_rounded_highlight(f: &mut Frame, area: Rect, state: &ListState, highlight_bg: Color) {
    let Some(selected) = state.selected() else {
        return;
    };

    if area.width < 4 || area.height < 3 {
        return;
    }

    let offset = state.offset();
    if selected < offset {
        return;
    }
    let row_offset = (selected - offset) as u16;
    let inner_height = area.height.saturating_sub(2);
    if row_offset >= inner_height {
        return;
    }

    let y = area.y + 1 + row_offset;
    let left_x = area.x + 1;
    let right_x = area.x + area.width - 2;

    let buf = f.buffer_mut();
    let cap_style = Style::default().fg(highlight_bg).bg(Color::Reset);

    if let Some(cell) = buf.cell_mut((left_x, y)) {
        cell.set_symbol(ROUNDED_LEFT).set_style(cap_style);
    }
    if let Some(cell) = buf.cell_mut((right_x, y)) {
        cell.set_symbol(ROUNDED_RIGHT).set_style(cap_style);
    }
}
