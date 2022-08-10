#!/usr/bin/env python3
import requests, yaml, os
from threading import Timer
from datetime import datetime
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *


# Load Config File
dfile = os.path.dirname(os.path.realpath(__file__))
confile = f"{dfile}/config.txt"
with open(confile, 'r') as f: config = yaml.safe_load(f)
hostname = config['hostname']
token = config['token']

app = QApplication([])
app.setQuitOnLastWindowClosed(False)

icon = QIcon("sync.png")

# Adding item on the menu bar
tray = QSystemTrayIcon()
tray.setIcon(icon)
tray.setVisible(True)


def showmessage():
    tray.showMessage("DynV6 Updater", lstupt, icon)


def exit():
    timer.cancel()
    app.quit()


def sync():
    global lstupt

    from requests.exceptions import ConnectionError
    try:
        response6 = requests.get(f"http://ipv6.dynv6.com/api/update?hostname={hostname}&token={token}&ipv6=auto&ipv6prefix=auto")
        response4 = requests.get(f"http://ipv4.dynv6.com/api/update?hostname={hostname}&token={token}&ipv4=auto")

        agora = datetime.now()
        hoje = agora.strftime("%d/%m/%Y - %H:%M:%S")
        lstupt = f"Last Update: {hoje}\nIPv6: {response6.text}\nIPv4: {response4.text}"

        tray.setIcon(icon)
    except ConnectionError as e:
        tray.setIcon(QIcon("error.png"))
        lstupt = e.__str__()

# Creating the options
menu = QMenu()
info = QAction("Show Info")
syncnow = QAction("Sync Now")
quit = QAction("Exit")
menu.addAction(info)
menu.addAction(syncnow)
menu.addAction(quit)

syncnow.triggered.connect(sync)
info.triggered.connect(showmessage)
quit.triggered.connect(exit)

# Adding options to the System Tray
tray.setContextMenu(menu)


class RepeatTimer(Timer):
    def run(self):
        while not self.finished.wait(self.interval):
            self.function(*self.args, **self.kwargs)


timer = RepeatTimer(config['interval'], sync)
timer.start()

sync()

app.exec_()
