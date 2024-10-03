#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ncurses.h>
#include <dirent.h>

#define NUM_MAIN_OPTIONS 3
#define MAX_SCRIPTS 20
#define MAX_SCRIPT_NAME_LENGTH 256
#define MAX_OUTPUT_LENGTH 1024
#define RESET       "\033[0m"
#define BLACK       "\033[30m"
#define RED         "\033[31m"
#define GREEN       "\033[32m"
#define YELLOW      "\033[33m"
#define BLUE        "\033[34m"
#define MAGENTA     "\033[35m"
#define CYAN        "\033[36m"
#define WHITE       "\033[37m"

void display_linux_system_menu();
void run_setup_script(const char *script_name, char *output);
void display_help();
void wait_for_enter();

const char *main_menu_options[NUM_MAIN_OPTIONS] = {
    "Arch Setup",
    "Help & Info",
    "Exit"
};

char scripts[MAX_SCRIPTS][MAX_SCRIPT_NAME_LENGTH];
int num_scripts = 0;

void init_ncurses() {
    initscr();            
    start_color();       
    cbreak();               
    noecho();               
    keypad(stdscr, TRUE);  
    curs_set(0);            
    init_pair(1, COLOR_GREEN, COLOR_BLACK);
    init_pair(2, COLOR_CYAN, COLOR_BLACK);
    init_pair(3, COLOR_WHITE, COLOR_BLACK);
}

void cleanup_ncurses() {
    endwin();
}

void load_scripts() {
    DIR *d;
    struct dirent *dir;
    d = opendir("./scripts");
    if (d) {
        while ((dir = readdir(d)) != NULL) {
            if (strstr(dir->d_name, ".sh") != NULL) {
                strncpy(scripts[num_scripts], dir->d_name, MAX_SCRIPT_NAME_LENGTH - 1);
                num_scripts++;
            }
            if (num_scripts >= MAX_SCRIPTS) break;
        }
        closedir(d);
    }
}

void draw_box(int y1, int x1, int y2, int x2) {
    mvhline(y1, x1, 0, x2 - x1);
    mvhline(y2, x1, 0, x2 - x1);
    mvvline(y1, x1, 0, y2 - y1);
    mvvline(y1, x2, 0, y2 - y1);
    mvaddch(y1, x1, ACS_ULCORNER);
    mvaddch(y1, x2, ACS_URCORNER);
    mvaddch(y2, x1, ACS_LLCORNER);
    mvaddch(y2, x2, ACS_LRCORNER);
}

void display_main_menu() {
    int selected = 0;

    while (1) {
        clear();

        int height = 10, width = 40;
        int startx = (COLS - width) / 2;
        int starty = (LINES - height) / 2;

        draw_box(starty - 2, startx - 2, starty + height, startx + width);

        attron(COLOR_PAIR(1));
        mvprintw(starty - 1, startx + 7, "========================");
        mvprintw(starty, startx + 9, "      Main Menu   ");
        mvprintw(starty + 1, startx + 7, "========================");
        attroff(COLOR_PAIR(1));

        // Menu options
        for (int i = 0; i < NUM_MAIN_OPTIONS; i++) {
            if (i == selected) {
                attron(COLOR_PAIR(2));
                mvprintw(starty + 3 + i * 2, startx + 10, "[ %s ]", main_menu_options[i]);
                attroff(COLOR_PAIR(2));
            } else {
                mvprintw(starty + 3 + i * 2, startx + 12, "%s", main_menu_options[i]);
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
            } else if (selected == 1) {
                display_help();
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

        int height = 20, width = 60;
        int startx = (COLS - width) / 2;
        int starty = (LINES - height) / 2;

        draw_box(starty - 2, startx - 2, starty + height, startx + width);

        attron(COLOR_PAIR(1));
        mvprintw(starty - 1, startx + 14, "============================");
        mvprintw(starty, startx + 16, "  Linux System Setup  ");
        mvprintw(starty + 1, startx + 14, "============================");
        attroff(COLOR_PAIR(1));

        for (int i = 0; i < num_scripts; i++) {
            if (i == selected) {
                attron(COLOR_PAIR(2));
                mvprintw(starty + 3 + i, startx + 12, "[ %s ]", scripts[i]);
                attroff(COLOR_PAIR(2));
            } else {
                mvprintw(starty + 3 + i, startx + 14, "%s", scripts[i]);
            }
        }

        if (selected == num_scripts) {
            attron(COLOR_PAIR(2));
            mvprintw(starty + 3 + num_scripts, startx + 12, "[ Exit ]");
            attroff(COLOR_PAIR(2));
        } else {
            mvprintw(starty + 3 + num_scripts, startx + 14, "Exit");
        }

        refresh();

        int input = getch();

        if (input == KEY_UP) {
            if (selected > 0) selected--;
        } else if (input == KEY_DOWN) {
            if (selected < num_scripts) selected++;
        } else if (input == '\n') {
            if (selected == num_scripts) {
                break;
            } else {
                run_setup_script(scripts[selected], output);
            }
        }
    }
}

void run_setup_script(const char *script_name, char *output) {
    clear();

    int height = 20, width = 80;
    int startx = (COLS - width) / 2;
    int starty = (LINES - height) / 2;

    mvhline(starty, startx, 0, width);
    mvhline(starty + height - 1, startx, 0, width);
    mvvline(starty, startx, 0, height);
    mvvline(starty, startx + width - 1, 0, height);
    mvaddch(starty, startx, ACS_ULCORNER);
    mvaddch(starty, startx + width - 1, ACS_URCORNER);
    mvaddch(starty + height - 1, startx, ACS_LLCORNER);
    mvaddch(starty + height - 1, startx + width - 1, ACS_LRCORNER);

    snprintf(output, MAX_OUTPUT_LENGTH, "Running %s...", script_name);
    mvprintw(starty + 1, startx + 2, "=== %s ===", script_name);
    refresh();

    FILE *fp;
    char path[MAX_OUTPUT_LENGTH ];
    char command[MAX_SCRIPT_NAME_LENGTH + 32];

    snprintf(command, sizeof(command), "bash ./scripts/%s", script_name);
    fp = popen(command, "r");
    if (fp == NULL) {
        snprintf(output, MAX_OUTPUT_LENGTH, "Failed to run script.");
        mvprintw(starty + 2, startx + 2, "%s", output);
        mvprintw(starty + 4, startx + 2, "Press Enter to return to the submenu...");
        refresh();
        wait_for_enter();
        return;
    }

    int line = 2;  
    while (fgets(path, MAX_OUTPUT_LENGTH, fp) != NULL && line < height - 2) {
        mvprintw(starty + line, startx + 2, "%s", path);  
        line++;
        refresh();
    }

    pclose(fp);

    snprintf(output, MAX_OUTPUT_LENGTH, "%s completed.", script_name);
    mvprintw(starty + line, startx + 2, "%s", output);
    mvprintw(starty + line + 1, startx + 2, "Press Enter to return to the submenu...");
    refresh();
    wait_for_enter();
}

void display_help() {
    clear();

    int height = 30, width = 60;
    int startx = (COLS - width) / 2;
    int starty = (LINES - height) / 2;

    // Help & Info title
    draw_box(starty - 2, startx - 2, starty + height, startx + width);
    attron(COLOR_PAIR(1));
    mvprintw(starty - 1, startx + 13, "============================");
    mvprintw(starty, startx + 15, "    Help & Information  ");
    mvprintw(starty + 1, startx + 13, "============================");
    attroff(COLOR_PAIR(1));

    mvprintw(starty + 3, startx + 2, "This program allows you to configure your Linux system.");
    mvprintw(starty + 5, startx + 2, "Available scripts:");

    for (int i = 0; i < num_scripts; i++) {
        mvprintw(starty + 7 + i, startx + 4, "- %s", scripts[i]);
    }

    mvprintw(starty + 9 + num_scripts, startx + 2, "Press Enter to return to the main menu...");
    refresh();
    wait_for_enter();
}

void wait_for_enter() {
    while (getch() != '\n');
}

int main() {
    init_ncurses();
    load_scripts();
    display_main_menu();
    cleanup_ncurses();
    return 0;
}
