#!/usr/bin/env python3
import requests, yaml, tkinter as tk, pystray
from threading import Timer
from datetime import datetime
from PIL import Image

with open('config.txt', 'r') as f: config = yaml.safe_load(f)
hostname = config['hostname']
token = config['token']
interval = config['interval']

def sync():
    from requests.exceptions import ConnectionError

    try:
        response6 = requests.get(
            f"http://ipv6.dynv6.com/api/update?hostname={hostname}&token={token}&ipv6prefix=auto")
        response4 = requests.get(
            f"http://ipv4.dynv6.com/api/update?hostname={hostname}&token={token}&ipv4=auto")

        agora = datetime.now()
        hoje = agora.strftime("%d/%m/%Y - %H:%M:%S")
        lstupt = (f"Host: {hostname}\n"
                  f"Last Update: {hoje}\n"
                  f"IPv6: {response6.text}\n"
                  f"IPv4: {response4.text}"
                  )

    except ConnectionError as e:
        lstupt = e.__str__()
        app.show_window()

    return lstupt

class RepeatTimer(Timer):
    def run(self):
        while not self.finished.wait(self.interval):
            self.function(*self.args, **self.kwargs)

class Dv6Upt(tk.Tk):

    def __init__(self):
        super().__init__()
        self.title("DynV6 Updater")
        self.geometry('250x70')
        self.resizable(False, False)
        self.protocol('WM_DELETE_WINDOW', self.minimize_to_tray)
        #self.attributes(toolwindow=1) #Enable only on Windows
        self.attributes('-topmost', True)
        self.lINFO = tk.Label(self, text=sync())
        self.lINFO.pack(side="top")
        self.minimize_to_tray()

    def minimize_to_tray(self):
        self.withdraw()
        image = Image.open("sync.png")
        menu = (pystray.MenuItem('Show Info', self.show_window, default=1),
                pystray.MenuItem('Update Now', self.dyn_update),
                pystray.MenuItem('Exit', self.quit_window)
                )

        icon = pystray.Icon("name", image, 'DynV6 Updater', menu)
        icon.run()

    def quit_window(self, icon):
        icon.stop()
        self.destroy()

    def show_window(self, icon):
        icon.stop()
        self.after(0,self.deiconify)

    def dyn_update(self):
        self.lINFO.config(text=sync())

if __name__ == "__main__":
    app = Dv6Upt()
    timer = RepeatTimer(interval, app.dyn_update)
    timer.start()
    app.mainloop()
    timer.cancel()
