#!/usr/bin/env python3
"""
NebulaOS App Store
A modern GUI application store with Flatpak backend
"""

import sys
import subprocess
import json
from pathlib import Path

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QStackedWidget, QLabel, QPushButton, QLineEdit, QScrollArea,
    QGridLayout, QFrame, QProgressBar, QTabWidget
)
from PyQt6.QtCore import Qt, QSize, QThread, pyqtSignal
from PyQt6.QtGui import QFont, QIcon


class InstallWorker(QThread):
    progress = pyqtSignal(str, int)
    finished = pyqtSignal(str, bool)

    def __init__(self, app_id, action="install"):
        super().__init__()
        self.app_id = app_id
        self.action = action

    def run(self):
        try:
            cmd = ["flatpak", self.action, "-y", self.app_id]
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            stdout, stderr = process.communicate()
            self.finished.emit(self.app_id, process.returncode == 0)
        except Exception as e:
            self.finished.emit(self.app_id, False)


class AppCard(QFrame):
    def __init__(self, app_data, parent=None):
        super().__init__(parent)
        self.app_data = app_data
        self.setup_ui()

    def setup_ui(self):
        self.setFixedSize(200, 240)
        self.setStyleSheet("""
            QFrame {
                background-color: #1a1a2e;
                border: 1px solid #333355;
                border-radius: 12px;
            }
            QFrame:hover {
                border-color: #4488ff;
                background-color: #1e1e35;
            }
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(8)

        # App icon placeholder
        icon_label = QLabel()
        icon_label.setFixedSize(64, 64)
        icon_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        icon_label.setStyleSheet(f"""
            background-color: {self.app_data.get('color', '#4488ff')};
            border-radius: 14px;
            font-size: 28px;
            color: white;
        """)
        icon_label.setText(self.app_data['name'][0].upper())
        layout.addWidget(icon_label, alignment=Qt.AlignmentFlag.AlignCenter)

        # App name
        name = QLabel(self.app_data['name'])
        name.setStyleSheet("font-size: 14px; font-weight: bold; color: white; border: none;")
        name.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(name)

        # Category
        cat = QLabel(self.app_data.get('category', 'App'))
        cat.setStyleSheet("font-size: 11px; color: #aaaacc; border: none;")
        cat.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(cat)

        # Rating
        rating = QLabel(f"{'★' * self.app_data.get('rating', 4)}{'☆' * (5 - self.app_data.get('rating', 4))}")
        rating.setStyleSheet("font-size: 12px; color: #ffaa44; border: none;")
        rating.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(rating)

        layout.addStretch()

        # Install button
        btn = QPushButton("Install" if not self.app_data.get('installed') else "Installed")
        btn.setStyleSheet("""
            QPushButton {
                background-color: #4488ff;
                border: none;
                border-radius: 8px;
                padding: 8px;
                font-size: 12px;
                color: white;
                font-weight: bold;
            }
            QPushButton:hover { background-color: #5599ff; }
            QPushButton:pressed { background-color: #3377dd; }
        """)
        if self.app_data.get('installed'):
            btn.setStyleSheet(btn.styleSheet().replace("#4488ff", "#2a2a4e").replace("#5599ff", "#3a3a5e"))
        layout.addWidget(btn)


class AppStoreWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("NebulaOS App Store")
        self.setMinimumSize(900, 600)
        self.resize(1100, 750)
        self.setup_ui()
        self.apply_theme()

    def setup_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        # Header
        header = QWidget()
        header.setFixedHeight(70)
        header.setStyleSheet("background-color: #12122a; border-bottom: 1px solid #333355;")
        header_layout = QHBoxLayout(header)
        header_layout.setContentsMargins(20, 0, 20, 0)

        title = QLabel("App Store")
        title.setStyleSheet("font-size: 20px; font-weight: bold; color: #4488ff;")
        header_layout.addWidget(title)

        header_layout.addStretch()

        search = QLineEdit()
        search.setPlaceholderText("Search apps...")
        search.setFixedWidth(300)
        search.setFixedHeight(36)
        search.setStyleSheet("""
            QLineEdit {
                background-color: #1a1a2e;
                border: 1px solid #333355;
                border-radius: 18px;
                padding: 0 16px;
                font-size: 13px;
                color: white;
            }
            QLineEdit:focus { border-color: #4488ff; }
        """)
        header_layout.addWidget(search)

        layout.addWidget(header)

        # Tabs
        tabs = QTabWidget()
        tabs.setStyleSheet("""
            QTabWidget::pane { border: none; }
            QTabBar::tab {
                background: transparent;
                color: #aaaacc;
                padding: 12px 24px;
                font-size: 13px;
                border: none;
                border-bottom: 2px solid transparent;
            }
            QTabBar::tab:selected {
                color: #4488ff;
                border-bottom-color: #4488ff;
            }
            QTabBar::tab:hover { color: white; }
        """)

        tabs.addTab(self.create_featured_page(), "Featured")
        tabs.addTab(self.create_category_page("Productivity"), "Productivity")
        tabs.addTab(self.create_category_page("Internet"), "Internet")
        tabs.addTab(self.create_category_page("Media"), "Media")
        tabs.addTab(self.create_category_page("Developer"), "Developer")
        tabs.addTab(self.create_category_page("Games"), "Games")
        tabs.addTab(self.create_installed_page(), "Installed")

        layout.addWidget(tabs)

    def get_featured_apps(self):
        return [
            {"name": "Firefox", "category": "Browser", "rating": 5, "color": "#ff6611", "installed": True},
            {"name": "Thunderbird", "category": "Email", "rating": 4, "color": "#0066cc"},
            {"name": "LibreOffice", "category": "Productivity", "rating": 5, "color": "#44aa44"},
            {"name": "GIMP", "category": "Graphics", "rating": 4, "color": "#88664a"},
            {"name": "VLC", "category": "Media", "rating": 5, "color": "#ff8800"},
            {"name": "VS Code", "category": "Developer", "rating": 5, "color": "#0078d7"},
            {"name": "Spotify", "category": "Music", "rating": 4, "color": "#1db954"},
            {"name": "Discord", "category": "Communication", "rating": 4, "color": "#5865f2"},
            {"name": "OBS Studio", "category": "Streaming", "rating": 5, "color": "#1a1a2e"},
            {"name": "Blender", "category": "3D Modeling", "rating": 5, "color": "#ea7600"},
            {"name": "Kdenlive", "category": "Video Editor", "rating": 4, "color": "#3daee9"},
            {"name": "Steam", "category": "Gaming", "rating": 4, "color": "#1b2838"},
        ]

    def create_featured_page(self):
        page = QWidget()
        page_layout = QVBoxLayout(page)
        page_layout.setContentsMargins(20, 20, 20, 20)

        # Banner
        banner = QFrame()
        banner.setFixedHeight(160)
        banner.setStyleSheet("""
            QFrame {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
                    stop:0 #1a2a5a, stop:1 #3a1a5a);
                border-radius: 16px;
            }
        """)
        banner_layout = QVBoxLayout(banner)
        banner_layout.setContentsMargins(32, 32, 32, 32)
        banner_title = QLabel("Welcome to NebulaOS App Store")
        banner_title.setStyleSheet("font-size: 24px; font-weight: bold; color: white;")
        banner_layout.addWidget(banner_title)
        banner_sub = QLabel("Discover apps, games, and developer tools")
        banner_sub.setStyleSheet("font-size: 14px; color: rgba(255,255,255,0.7);")
        banner_layout.addWidget(banner_sub)
        banner_layout.addStretch()
        page_layout.addWidget(banner)

        page_layout.addWidget(QLabel("<h3 style='color: white;'>Featured Apps</h3>"))

        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QFrame.Shape.NoFrame)

        grid_widget = QWidget()
        grid = QGridLayout(grid_widget)
        grid.setSpacing(16)

        apps = self.get_featured_apps()
        for i, app in enumerate(apps):
            card = AppCard(app)
            grid.addWidget(card, i // 4, i % 4)

        scroll.setWidget(grid_widget)
        page_layout.addWidget(scroll)

        return page

    def create_category_page(self, category):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.addWidget(QLabel(f"<h3 style='color: white;'>{category} Apps</h3>"))
        layout.addWidget(QLabel("<p style='color: #aaaacc;'>Browse curated apps in this category</p>"))
        layout.addStretch()
        return page

    def create_installed_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.addWidget(QLabel("<h3 style='color: white;'>Installed Apps</h3>"))

        installed = [a for a in self.get_featured_apps() if a.get('installed')]
        for app in installed:
            row = QHBoxLayout()
            name = QLabel(app['name'])
            name.setStyleSheet("font-size: 14px; color: white;")
            row.addWidget(name)
            row.addStretch()
            btn = QPushButton("Uninstall")
            btn.setStyleSheet("""
                QPushButton {
                    background-color: #2a2a4e; border: 1px solid #333355;
                    border-radius: 8px; padding: 6px 16px; color: white; font-size: 12px;
                }
            """)
            row.addWidget(btn)
            layout.addLayout(row)

        layout.addStretch()
        return page

    def apply_theme(self):
        self.setStyleSheet("""
            QMainWindow { background-color: #0a0a1a; }
            QWidget { color: #ffffff; font-family: 'Inter', sans-serif; }
        """)


def main():
    app = QApplication(sys.argv)
    app.setApplicationName("NebulaOS App Store")
    window = AppStoreWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
