#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ncurses.h>

#define NUM_MAIN_OPTIONS 2
#define NUM_SUB_OPTIONS 16
#define MAX_OUTPUT_LENGTH 1024

void display_linux_system_menu();
void run_setup_script(int option, char *output);
void wait_for_enter();

const char *main_menu_options[NUM_MAIN_OPTIONS] = {
    "Linux System (Arch)",
    "Exit"
};

const char *sub_menu_options[NUM_SUB_OPTIONS] = {
    "Window Manager Setup",
    "Browsers Setup",
    "Packages Setup",
    "GRUB Setup",
    "SDDM Setup",
    "Font Setup",
    "Rofi Setup",
    "Alacritty Setup",
    "Kitty Setup",
    "Neovim Setup",
    "Fastfetch Setup",
    "LTS Kernel Setup",
    "Picom Setup",
    "AUR Setup",
    "Nord Backgrounds",
    "Exit"
};

void init_ncurses() {
    initscr();            
    start_color();       
    cbreak();               
    noecho();               
    keypad(stdscr, TRUE);  
    curs_set(0);            
    init_pair(1, COLOR_GREEN, COLOR_BLACK);
    init_pair(2, COLOR_CYAN, COLOR_BLACK);
}

void cleanup_ncurses() {
    endwin();
}

void display_main_menu() {
    int selected = 0;

    while (1) {
        clear();
        attron(COLOR_PAIR(1));
        mvprintw(1, 10, "========================");
        mvprintw(2, 10, "       Main Menu   ");
        mvprintw(3, 10, "========================");

        attroff(COLOR_PAIR(1));

        for (int i = 0; i < NUM_MAIN_OPTIONS; i++) {
            if (i == selected) {
                attron(COLOR_PAIR(2));
                mvprintw(5 + i, 12, "> %s", main_menu_options[i]);
                attroff(COLOR_PAIR(2));
            } else {
                mvprintw(5 + i, 12, "  %s", main_menu_options[i]);
            }
        }

        refresh();

        int input = getch();

        if (input == KEY_UP) {
            if (selected > 0) selected--;
        } else if (input == KEY_DOWN) {
            if (selected < NUM_MAIN_OPTIONS - 1) selected++;
        } else if (input == '\n') {
            if (selected == 0) {
                display_linux_system_menu();
            } else {
                break;
            }
        }
    }
}

void display_linux_system_menu() {
    int selected = 0;
    char output[MAX_OUTPUT_LENGTH] = "";

    while (1) {
        clear();
        attron(COLOR_PAIR(1));
        mvprintw(1, 10, "========================");
        mvprintw(2, 10, "   Linux System Setup ");
        mvprintw(3, 10, "========================");
        attroff(COLOR_PAIR(1));

        for (int i = 0; i < NUM_SUB_OPTIONS; i++) {
            if (i == selected) {
                attron(COLOR_PAIR(2));
                mvprintw(5 + i, 12, "> %s", sub_menu_options[i]);
                attroff(COLOR_PAIR(2));
            } else {
                mvprintw(5 + i, 12, "  %s", sub_menu_options[i]);
            }
        }

        mvprintw(22, 10, "=== === Script Output === ===");

        if (strlen(output) > 0) {
            mvprintw(23, 10, "%s", output);
        }

        refresh();

        int input = getch();

        if (input == KEY_UP) {
            if (selected > 0) selected--;
        } else if (input == KEY_DOWN) {
            if (selected < NUM_SUB_OPTIONS - 1) selected++;
        } else if (input == '\n') {
            if (selected == NUM_SUB_OPTIONS - 1) {
                break;
            } else {
                run_setup_script(selected, output);
            }
        }
    }
}

void run_setup_script(int option, char *output) {
    clear();
    snprintf(output, MAX_OUTPUT_LENGTH, "Running %s...", sub_menu_options[option]);
    mvprintw(1, 10, "=== %s ===", output);
    refresh();

    switch (option) {
        case 0:
            system("bash ./scripts/window_manager_setup.sh");
            break;
        case 1:
            system("bash ./scripts/browsers_setup.sh");
            break;
        case 2:
            system("bash ./scripts/packages_setup.sh");
            break;
        case 3:
            system("bash ./scripts/grub_setup.sh");
            break;
        case 4:
            system("bash ./scripts/sddm_setup.sh");
            break;
        case 5:
            system("bash ./scripts/font_setup.sh");
            break;
        case 6:
            system("bash ./scripts/rofi_setup.sh");
            break;
        case 7:
            system("bash ./scripts/alacritty_setup.sh");
            break;
        case 8:
            system("bash ./scripts/kitty_setup.sh");
            break;
        case 9:
            system("bash ./scripts/neovim_setup.sh");
            break;
        case 10:
            system("bash ./scripts/fastfetch_setup.sh");
            break;
        case 11:
            system("bash ./scripts/lts_kernel_setup.sh");
            break;
        case 12:
            system("bash ./scripts/picom_setup.sh");
            break;
        case 13:
            system("bash ./scripts/aur_setup.sh");
            break;
        case 14:
            system("bash ./scripts/nord_backgrounds_setup.sh");
            break;
        default:
            snprintf(output, MAX_OUTPUT_LENGTH, "No script available for this option.");
            break;
    }

    snprintf(output, MAX_OUTPUT_LENGTH, "  %s completed.", sub_menu_options[option]);
    mvprintw(3, 10, "%s", output);
    mvprintw(4, 10, "Press Enter to return to the submenu...");
    refresh();
    wait_for_enter();
}

void wait_for_enter() {
    while (getch() != '\n');
}

int main() {
    init_ncurses();
    display_main_menu();
    cleanup_ncurses();
    return 0;
}
