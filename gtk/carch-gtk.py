#!/usr/bin/env python3
import gi
import os
import subprocess
import threading

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GLib, Pango


class CarchApp(Gtk.Window):
    def __init__(self):
        super().__init__(title="Carch - Arch Linux Automation")
        self.set_border_width(10)
        self.set_default_size(700, 500)

        self.script_dir = "./scripts"
        self.scripts = self.load_scripts()
        self.filtered_scripts = self.scripts.copy()

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.add(vbox)

        header_bar = Gtk.HeaderBar(title="Carch")
        header_bar.set_subtitle("Arch Linux Automation - Version 3.0.7")
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

        button_box = Gtk.Box(spacing=10)
        vbox.pack_start(button_box, False, False, 0)

        cancel_button = Gtk.Button(label="Exit")
        cancel_button.set_tooltip_text("Exit the application")
        cancel_button.connect("clicked", Gtk.main_quit)
        button_box.pack_start(cancel_button, True, True, 0)

        self.show_all()

    def load_scripts(self):
        if not os.path.exists(self.script_dir):
            return []

        return [
            os.path.splitext(f)[0]
            for f in os.listdir(self.script_dir)
            if f.endswith(".sh")
        ]

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

            view_button = Gtk.Button(label="View Script")
            view_button.set_tooltip_text(f"View the content of '{script}'")
            view_button.connect("clicked", self.view_script, script)
            box.pack_start(view_button, False, False, 0)

            run_button = Gtk.Button(label="Run Script")
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

    def view_script(self, button, script_name):
        script_path = os.path.join(self.script_dir, f"{script_name}.sh")
        if not os.path.exists(script_path):
            self.show_message(f"Script '{script_name}' not found!")
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

        provider = Gtk.CssProvider()
        provider.load_from_data(b"GtkTextView { font-family: monospace; font-size: 10pt; }")
        text_view.get_style_context().add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_USER)

        scrollable = Gtk.ScrolledWindow()
        scrollable.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        scrollable.set_vexpand(True)
        scrollable.add(text_view)

        dialog.vbox.pack_start(scrollable, True, True, 0)

        close_button = dialog.add_button("Close", Gtk.ResponseType.CLOSE)
        close_button.set_tooltip_text("Close this dialog")
        dialog.connect("response", lambda d, r: d.destroy())

        dialog.show_all()

    def run_script(self, button, script_name):
        script_path = os.path.join(self.script_dir, f"{script_name}.sh")
        if not os.path.exists(script_path):
            self.show_message(f"Script '{script_name}' not found!")
            return

        thread = threading.Thread(target=self.execute_script, args=(script_path,))
        thread.start()

    def execute_script(self, script_path):
        try:
            subprocess.run(["bash", script_path], check=True)
        except subprocess.CalledProcessError:
            pass  
        except Exception:
            pass  

    def show_about_dialog(self, button):
        about_dialog = Gtk.AboutDialog()
        about_dialog.set_program_name("Carch")
        about_dialog.set_version("3.0.7")
        about_dialog.set_comments("A script that helps to automate Arch Linux system setup.")
        about_dialog.set_website("https://harilvfs.github.io/carch/")
        about_dialog.run()
        about_dialog.destroy()

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


if __name__ == "__main__":
    app = CarchApp()
    app.connect("destroy", Gtk.main_quit)
    Gtk.main()

