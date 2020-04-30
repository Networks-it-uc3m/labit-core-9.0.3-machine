import tkinter as tk
from tkinter import ttk

from core.gui.themes import Styles


class Tooltip(object):
    """
    Create tool tip for a given widget
    """

    def __init__(self, widget: tk.Widget, text: str = "widget info"):
        self.widget = widget
        self.text = text
        self.widget.bind("<Enter>", self.on_enter)
        self.widget.bind("<Leave>", self.on_leave)
        self.waittime = 400
        self.id = None
        self.tw = None

    def on_enter(self, event: tk.Event = None):
        self.schedule()

    def on_leave(self, event: tk.Event = None):
        self.unschedule()
        self.close(event)

    def schedule(self):
        self.unschedule()
        self.id = self.widget.after(self.waittime, self.enter)

    def unschedule(self):
        id_ = self.id
        self.id = None
        if id_:
            self.widget.after_cancel(id_)

    def enter(self, event: tk.Event = None):
        x, y, cx, cy = self.widget.bbox("insert")
        x += self.widget.winfo_rootx()
        y += self.widget.winfo_rooty() + 32

        self.tw = tk.Toplevel(self.widget)
        self.tw.wm_overrideredirect(True)
        self.tw.wm_geometry("+%d+%d" % (x, y))
        self.tw.rowconfigure(0, weight=1)
        self.tw.columnconfigure(0, weight=1)
        frame = ttk.Frame(self.tw, style=Styles.tooltip_frame, padding=3)
        frame.grid(sticky="nsew")
        label = ttk.Label(frame, text=self.text, style=Styles.tooltip)
        label.grid()

    def close(self, event: tk.Event = None):
        if self.tw:
            self.tw.destroy()
