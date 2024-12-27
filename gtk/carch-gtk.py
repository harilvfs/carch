#!/usr/bin/env python3
import gi
import os
import subprocess
import threading
import logging

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GLib, Pango

log_dir = os.path.expanduser("~/.config/carch")
os.makedirs(log_dir, exist_ok=True)
log_file = os.path.join(log_dir, "carch-gtk.log")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(log_file, mode="a"),
        logging.StreamHandler()
    ]
)

class CarchApp(Gtk.Window):
    def __init__(self):
        super().__init__(title="Carch - Arch Linux Automation")
        logging.info("Application started.")

        self.set_border_width(10)
        self.set_default_size(700, 500)

        self.script_dir = "/usr/bin/scripts"
        self.scripts = self.load_scripts()
        self.filtered_scripts = self.scripts.copy()

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.add(vbox)

        header_bar = Gtk.HeaderBar(title="Carch")
        header_bar.set_subtitle(f"{len(self.scripts)} Scripts Available")
        header_bar.set_show_close_button(True)
        self.set_titlebar(header_bar)

        about_button = Gtk.Button(label="About")
        about_button.connect("clicked", self.show_about_dialog)
        header_bar.pack_end(about_button)

        search_entry = Gtk.SearchEntry()
        search_entry.set_placeholder_text("Search scripts...")
        search_entry.connect("search-changed", self.on_search_changed)
        vbox.pack_start(search_entry, False, False, 0)

        scrollable = Gtk.ScrolledWindow()
        scrollable.set_vexpand(True)
        scrollable.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        vbox.pack_start(scrollable, True, True, 0)

        self.listbox_container = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        scrollable.add(self.listbox_container)

        self.populate_scripts()

        self.status_label = Gtk.Label()
        vbox.pack_start(self.status_label, False, False, 0)

        button_box = Gtk.Box(spacing=10)
        vbox.pack_start(button_box, False, False, 0)

        cancel_button = Gtk.Button(label="Exit")
        cancel_button.set_tooltip_text("Exit the application")
        cancel_button.connect("clicked", self.on_exit)

        button_box.pack_start(cancel_button, True, True, 0)

        self.spinner = Gtk.Spinner()
        button_box.pack_start(self.spinner, False, False, 0)

        self.show_all()

    def on_exit(self, button):
        log_path = os.path.expanduser("~/.config/carch/carch-gtk.log")
        os.system('clear')
        logging.info(f"Application exited. Logs saved at {log_path}.")
        Gtk.main_quit()

    def load_scripts(self):
        if not os.path.exists(self.script_dir):
            logging.warning(f"Script directory '{self.script_dir}' does not exist.")
            return []

        scripts = [
            os.path.splitext(f)[0]
            for f in os.listdir(self.script_dir)
            if f.endswith(".sh")
        ]
        logging.info(f"Loaded {len(scripts)} scripts from '{self.script_dir}'.")
        return scripts

    def populate_scripts(self):
        for script in self.filtered_scripts:
            box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            box.set_margin_top(5)
            box.set_margin_bottom(5)
            box.set_margin_start(5)
            box.set_margin_end(5)

            script_label = Gtk.Label(label=script, xalign=0)
            script_label.set_justify(Gtk.Justification.LEFT)
            box.pack_start(script_label, True, True, 0)

            view_button = Gtk.Button(label="View")
            view_button.set_tooltip_text(f"View the content of '{script}'")
            view_button.connect("clicked", self.view_script, script)
            box.pack_start(view_button, False, False, 0)

            run_button = Gtk.Button(label="Run")
            run_button.set_tooltip_text(f"Run the script '{script}'")
            run_button.connect("clicked", self.run_script, script)
            box.pack_start(run_button, False, False, 0)

            self.listbox_container.pack_start(box, False, False, 0)

    def on_search_changed(self, search_entry):
        query = search_entry.get_text().lower()
        self.filtered_scripts = [s for s in self.scripts if query in s.lower()]
        for child in self.listbox_container.get_children():
            self.listbox_container.remove(child)
        self.populate_scripts()
        self.listbox_container.show_all()
        logging.info(f"Search updated with query: '{query}'.")

    def view_script(self, button, script_name):
        script_path = os.path.join(self.script_dir, f"{script_name}.sh")
        if not os.path.exists(script_path):
            self.show_message(f"Script '{script_name}' not found!")
            logging.error(f"Script '{script_path}' not found.")
            return

        with open(script_path, "r") as script_file:
            content = script_file.read()

        dialog = Gtk.Dialog(
            title=f"View Script: {script_name}",
            transient_for=self,
            modal=True,
            destroy_with_parent=True,
        )
        dialog.set_default_size(600, 400)

        text_view = Gtk.TextView()
        text_view.set_wrap_mode(Gtk.WrapMode.WORD)
        text_view.get_buffer().set_text(content)
        text_view.set_editable(False)

        scrollable = Gtk.ScrolledWindow()
        scrollable.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        scrollable.set_vexpand(True)
        scrollable.add(text_view)

        dialog.vbox.pack_start(scrollable, True, True, 0)

        close_button = dialog.add_button("Close", Gtk.ResponseType.CLOSE)
        close_button.set_tooltip_text("Close this dialog")
        dialog.connect("response", lambda d, r: d.destroy())

        dialog.show_all()
        logging.info(f"Viewed script: '{script_name}'.")

    def run_script(self, button, script_name):
        script_path = os.path.join(self.script_dir, f"{script_name}.sh")
        if not os.path.exists(script_path):
            self.show_message(f"Script '{script_name}' not found!")
            logging.error(f"Script '{script_path}' not found.")
            return

        self.status_label.set_text(f"Running '{script_name}'...")
        self.spinner.start()
        logging.info(f"Running script: '{script_name}'.")

        thread = threading.Thread(target=self.execute_script, args=(script_path,))
        thread.start()

    def execute_script(self, script_path):
        try:
            subprocess.run(["bash", script_path], check=True)
            GLib.idle_add(self.status_label.set_text, "Script executed successfully.")
            logging.info(f"Script '{script_path}' executed successfully.")
        except subprocess.CalledProcessError:
            GLib.idle_add(self.status_label.set_text, "Script execution failed.")
            logging.error(f"Execution of script '{script_path}' failed.")
        except Exception as e:
            GLib.idle_add(self.status_label.set_text, f"Error: {e}")
            logging.exception(f"Unexpected error during script execution: {e}")
        finally:
            GLib.idle_add(self.spinner.stop)

    def show_about_dialog(self, button):
        about_dialog = Gtk.AboutDialog()
        about_dialog.set_program_name("Carch")
        about_dialog.set_version("4.1.0")
        about_dialog.set_comments("A script that helps automate Arch Linux system setup.")
        about_dialog.set_website("https://harilvfs.github.io/carch/")
        about_dialog.set_logo_icon_name("system-run")
        about_dialog.run()
        about_dialog.destroy()
        logging.info("Displayed About dialog.")

    def show_message(self, message):
        dialog = Gtk.MessageDialog(
            transient_for=self,
            modal=True,
            destroy_with_parent=True,
            message_type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            text=message,
        )
        dialog.run()
        dialog.destroy()
        logging.info(f"Displayed message dialog: {message}")


if __name__ == "__main__":
    app = CarchApp()
    app.connect("destroy", Gtk.main_quit)
    Gtk.main()

