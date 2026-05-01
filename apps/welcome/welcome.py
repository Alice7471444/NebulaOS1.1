#!/usr/bin/env python3
"""
NebulaOS Welcome Application
First-run setup and introduction
"""

import sys
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QStackedWidget, QLabel, QPushButton, QComboBox, QCheckBox, QFrame
)
from PyQt6.QtCore import Qt, QSettings
from PyQt6.QtGui import QFont


class WelcomeWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.settings = QSettings("NebulaOS", "welcome")
        self.setWindowTitle("Welcome to NebulaOS")
        self.setFixedSize(700, 500)
        self.current_page = 0
        self.setup_ui()
        self.apply_theme()

    def setup_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        # Pages
        self.pages = QStackedWidget()

        # Page 1: Welcome
        p1 = self.create_page(
            "Welcome to NebulaOS",
            "A modern, lightweight, AI-powered desktop operating system.\n\n"
            "Let's get you set up in just a few steps.",
            emoji="\u2728"
        )
        self.pages.addWidget(p1)

        # Page 2: Theme Selection
        p2 = QWidget()
        p2_layout = QVBoxLayout(p2)
        p2_layout.setContentsMargins(50, 40, 50, 40)
        p2_layout.addWidget(self.make_title("Choose Your Theme"))
        p2_layout.addSpacing(20)

        themes_layout = QHBoxLayout()
        for name, color, desc in [
            ("Dark", "#0a0a1a", "Deep space\naesthetics"),
            ("Light", "#f0f0f5", "Clean and\nbright"),
            ("Nebula Blue", "#050510", "Cyberpunk\nneon")
        ]:
            card = QFrame()
            card.setFixedSize(160, 160)
            card.setStyleSheet(f"""
                QFrame {{
                    background-color: {color};
                    border: 2px solid #333355;
                    border-radius: 16px;
                }}
                QFrame:hover {{ border-color: #4488ff; }}
            """)
            card_layout = QVBoxLayout(card)
            card_layout.setAlignment(Qt.AlignmentFlag.AlignCenter)
            lbl = QLabel(name)
            lbl.setStyleSheet(f"color: {'#ffffff' if color != '#f0f0f5' else '#1a1a2e'}; font-size: 15px; font-weight: bold;")
            lbl.setAlignment(Qt.AlignmentFlag.AlignCenter)
            card_layout.addWidget(lbl)
            desc_lbl = QLabel(desc)
            desc_lbl.setStyleSheet(f"color: {'#aaaacc' if color != '#f0f0f5' else '#666680'}; font-size: 11px;")
            desc_lbl.setAlignment(Qt.AlignmentFlag.AlignCenter)
            card_layout.addWidget(desc_lbl)
            themes_layout.addWidget(card)

        p2_layout.addLayout(themes_layout)
        p2_layout.addStretch()
        self.pages.addWidget(p2)

        # Page 3: AI Assistant
        p3 = self.create_page(
            "Meet Nebula AI",
            "Your built-in AI assistant can help you:\n\n"
            "\u2022 Launch applications\n"
            "\u2022 Search files and settings\n"
            "\u2022 Answer questions\n"
            "\u2022 Control system settings\n\n"
            "Press Super+Space to activate anytime.",
            emoji="\U0001F916"
        )
        self.pages.addWidget(p3)

        # Page 4: Ready
        p4 = self.create_page(
            "You're All Set!",
            "NebulaOS is ready to use.\n\n"
            "Explore the Start Menu, customize your theme in Settings,\n"
            "and check out the App Store for more apps.\n\n"
            "Enjoy your new desktop!",
            emoji="\U0001F680"
        )
        self.pages.addWidget(p4)

        layout.addWidget(self.pages)

        # Navigation
        nav = QWidget()
        nav.setFixedHeight(70)
        nav.setStyleSheet("background-color: #12122a; border-top: 1px solid #333355;")
        nav_layout = QHBoxLayout(nav)
        nav_layout.setContentsMargins(30, 0, 30, 0)

        self.skip_btn = QPushButton("Skip")
        self.skip_btn.clicked.connect(self.close)
        nav_layout.addWidget(self.skip_btn)

        nav_layout.addStretch()

        # Page indicators
        self.indicators = QHBoxLayout()
        self.indicators.setSpacing(8)
        for i in range(4):
            dot = QLabel()
            dot.setFixedSize(8, 8)
            dot.setStyleSheet(f"""
                background-color: {'#4488ff' if i == 0 else '#333355'};
                border-radius: 4px;
            """)
            self.indicators.addWidget(dot)
        nav_layout.addLayout(self.indicators)

        nav_layout.addStretch()

        self.next_btn = QPushButton("Next")
        self.next_btn.setStyleSheet("""
            QPushButton {
                background-color: #4488ff; border: none; border-radius: 8px;
                padding: 10px 30px; color: white; font-size: 14px; font-weight: bold;
            }
            QPushButton:hover { background-color: #5599ff; }
        """)
        self.next_btn.clicked.connect(self.next_page)
        nav_layout.addWidget(self.next_btn)

        layout.addWidget(nav)

    def make_title(self, text):
        lbl = QLabel(text)
        lbl.setStyleSheet("font-size: 26px; font-weight: bold; color: #ffffff;")
        lbl.setAlignment(Qt.AlignmentFlag.AlignCenter)
        return lbl

    def create_page(self, title, description, emoji=""):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setContentsMargins(50, 40, 50, 40)
        layout.setAlignment(Qt.AlignmentFlag.AlignCenter)

        if emoji:
            e = QLabel(emoji)
            e.setStyleSheet("font-size: 60px;")
            e.setAlignment(Qt.AlignmentFlag.AlignCenter)
            layout.addWidget(e)
            layout.addSpacing(16)

        layout.addWidget(self.make_title(title))
        layout.addSpacing(16)

        desc = QLabel(description)
        desc.setStyleSheet("font-size: 14px; color: #aaaacc; line-height: 1.6;")
        desc.setAlignment(Qt.AlignmentFlag.AlignCenter)
        desc.setWordWrap(True)
        layout.addWidget(desc)

        return page

    def next_page(self):
        self.current_page += 1
        if self.current_page >= self.pages.count():
            self.settings.setValue("welcome/shown", True)
            self.close()
            return

        self.pages.setCurrentIndex(self.current_page)

        if self.current_page == self.pages.count() - 1:
            self.next_btn.setText("Get Started")

        # Update indicators
        for i in range(self.indicators.count()):
            widget = self.indicators.itemAt(i).widget()
            if widget:
                widget.setStyleSheet(f"""
                    background-color: {'#4488ff' if i == self.current_page else '#333355'};
                    border-radius: 4px;
                """)

    def apply_theme(self):
        self.setStyleSheet("""
            QMainWindow { background-color: #0a0a1a; }
            QWidget { color: #ffffff; font-family: 'Inter', sans-serif; }
            QPushButton {
                background-color: transparent; border: 1px solid #333355;
                border-radius: 8px; padding: 10px 20px; color: #aaaacc; font-size: 13px;
            }
            QPushButton:hover { background-color: rgba(255,255,255,0.05); color: white; }
        """)


def main():
    app = QApplication(sys.argv)
    window = WelcomeWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
