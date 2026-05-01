#!/usr/bin/env python3
"""
NebulaOS Settings Application
A modern settings panel inspired by Windows 11 Settings
Built with Qt6 for native integration with the desktop shell
"""

import sys
import json
import subprocess
from pathlib import Path

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QStackedWidget, QListWidget, QListWidgetItem, QLabel, QSlider,
    QComboBox, QCheckBox, QPushButton, QLineEdit, QGroupBox,
    QFormLayout, QSpinBox, QColorDialog, QFileDialog, QScrollArea
)
from PyQt6.QtCore import Qt, QSettings, QSize
from PyQt6.QtGui import QIcon, QFont, QColor, QPalette


class SettingsWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.settings = QSettings("NebulaOS", "nebula-settings")
        self.setWindowTitle("Settings")
        self.setMinimumSize(900, 600)
        self.resize(1000, 700)

        self.setup_ui()
        self.apply_theme()

    def setup_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        layout = QHBoxLayout(central)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        # Sidebar navigation
        self.sidebar = QListWidget()
        self.sidebar.setFixedWidth(260)
        self.sidebar.setIconSize(QSize(24, 24))
        self.sidebar.currentRowChanged.connect(self.switch_page)

        pages = [
            ("System", "Display, sound, notifications, power"),
            ("Network & Internet", "Wi-Fi, Ethernet, VPN, proxy"),
            ("Bluetooth & Devices", "Bluetooth, printers, mouse"),
            ("Personalization", "Themes, colors, lock screen, taskbar"),
            ("Apps", "Installed apps, default apps, startup"),
            ("Accounts", "Your account, email, sync"),
            ("Privacy & Security", "Permissions, firewall, encryption"),
            ("AI Assistant", "Nebula AI settings, voice, API"),
            ("Time & Language", "Date, time, region, language"),
            ("Accessibility", "Vision, hearing, interaction"),
            ("Updates", "System updates, recovery"),
            ("About", "System information"),
        ]

        for name, desc in pages:
            item = QListWidgetItem(name)
            item.setToolTip(desc)
            item.setSizeHint(QSize(240, 48))
            self.sidebar.addItem(item)

        layout.addWidget(self.sidebar)

        # Pages stack
        self.pages = QStackedWidget()
        self.pages.addWidget(self.create_system_page())
        self.pages.addWidget(self.create_network_page())
        self.pages.addWidget(self.create_bluetooth_page())
        self.pages.addWidget(self.create_personalization_page())
        self.pages.addWidget(self.create_apps_page())
        self.pages.addWidget(self.create_accounts_page())
        self.pages.addWidget(self.create_privacy_page())
        self.pages.addWidget(self.create_ai_page())
        self.pages.addWidget(self.create_time_page())
        self.pages.addWidget(self.create_accessibility_page())
        self.pages.addWidget(self.create_updates_page())
        self.pages.addWidget(self.create_about_page())

        layout.addWidget(self.pages)
        self.sidebar.setCurrentRow(0)

    def switch_page(self, index):
        self.pages.setCurrentIndex(index)

    def create_scroll_page(self, widget):
        scroll = QScrollArea()
        scroll.setWidget(widget)
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QScrollArea.Shape.NoFrame)
        return scroll

    def create_system_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.setSpacing(16)

        layout.addWidget(QLabel("<h2>System</h2>"))

        # Display settings
        display_group = QGroupBox("Display")
        display_layout = QFormLayout(display_group)

        resolution = QComboBox()
        resolution.addItems(["3840x2160", "2560x1440", "1920x1080", "1366x768"])
        display_layout.addRow("Resolution:", resolution)

        scale = QComboBox()
        scale.addItems(["100%", "125%", "150%", "175%", "200%"])
        display_layout.addRow("Scale:", scale)

        refresh = QComboBox()
        refresh.addItems(["60 Hz", "75 Hz", "120 Hz", "144 Hz"])
        display_layout.addRow("Refresh rate:", refresh)

        brightness = QSlider(Qt.Orientation.Horizontal)
        brightness.setRange(0, 100)
        brightness.setValue(80)
        display_layout.addRow("Brightness:", brightness)

        night_light = QCheckBox("Enable Night Light")
        display_layout.addRow(night_light)

        layout.addWidget(display_group)

        # Sound settings
        sound_group = QGroupBox("Sound")
        sound_layout = QFormLayout(sound_group)

        volume = QSlider(Qt.Orientation.Horizontal)
        volume.setRange(0, 100)
        volume.setValue(70)
        sound_layout.addRow("Volume:", volume)

        output = QComboBox()
        output.addItems(["Speakers", "Headphones", "HDMI"])
        sound_layout.addRow("Output device:", output)

        layout.addWidget(sound_group)

        # Power settings
        power_group = QGroupBox("Power & Battery")
        power_layout = QFormLayout(power_group)

        power_mode = QComboBox()
        power_mode.addItems(["Balanced", "Best performance", "Best power efficiency"])
        power_layout.addRow("Power mode:", power_mode)

        sleep_after = QComboBox()
        sleep_after.addItems(["Never", "5 minutes", "15 minutes", "30 minutes", "1 hour"])
        power_layout.addRow("Sleep after:", sleep_after)

        layout.addWidget(power_group)
        layout.addStretch()

        return self.create_scroll_page(page)

    def create_network_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.addWidget(QLabel("<h2>Network & Internet</h2>"))

        wifi_group = QGroupBox("Wi-Fi")
        wifi_layout = QVBoxLayout(wifi_group)
        wifi_toggle = QCheckBox("Wi-Fi enabled")
        wifi_toggle.setChecked(True)
        wifi_layout.addWidget(wifi_toggle)
        wifi_layout.addWidget(QLabel("Connected to: NebulaOS-Network"))
        scan_btn = QPushButton("Scan for networks")
        wifi_layout.addWidget(scan_btn)
        layout.addWidget(wifi_group)

        vpn_group = QGroupBox("VPN")
        vpn_layout = QVBoxLayout(vpn_group)
        vpn_layout.addWidget(QPushButton("Add VPN connection"))
        layout.addWidget(vpn_group)

        proxy_group = QGroupBox("Proxy")
        proxy_layout = QFormLayout(proxy_group)
        proxy_layout.addRow("HTTP Proxy:", QLineEdit())
        proxy_layout.addRow("HTTPS Proxy:", QLineEdit())
        proxy_layout.addRow("Port:", QSpinBox())
        layout.addWidget(proxy_group)

        dns_group = QGroupBox("DNS")
        dns_layout = QFormLayout(dns_group)
        dns_layout.addRow("Primary DNS:", QLineEdit("1.1.1.1"))
        dns_layout.addRow("Secondary DNS:", QLineEdit("8.8.8.8"))
        layout.addWidget(dns_group)

        layout.addStretch()
        return self.create_scroll_page(page)

    def create_bluetooth_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.addWidget(QLabel("<h2>Bluetooth & Devices</h2>"))

        bt_group = QGroupBox("Bluetooth")
        bt_layout = QVBoxLayout(bt_group)
        bt_toggle = QCheckBox("Bluetooth enabled")
        bt_layout.addWidget(bt_toggle)
        bt_layout.addWidget(QPushButton("Add device"))
        bt_layout.addWidget(QLabel("No paired devices"))
        layout.addWidget(bt_group)

        mouse_group = QGroupBox("Mouse")
        mouse_layout = QFormLayout(mouse_group)
        mouse_speed = QSlider(Qt.Orientation.Horizontal)
        mouse_speed.setRange(1, 20)
        mouse_speed.setValue(10)
        mouse_layout.addRow("Pointer speed:", mouse_speed)
        mouse_layout.addRow(QCheckBox("Natural scrolling"))
        layout.addWidget(mouse_group)

        layout.addStretch()
        return self.create_scroll_page(page)

    def create_personalization_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.addWidget(QLabel("<h2>Personalization</h2>"))

        theme_group = QGroupBox("Theme")
        theme_layout = QVBoxLayout(theme_group)
        dark_mode = QCheckBox("Dark mode")
        dark_mode.setChecked(True)
        theme_layout.addWidget(dark_mode)
        auto_theme = QCheckBox("Auto switch (dark at night)")
        theme_layout.addWidget(auto_theme)
        layout.addWidget(theme_group)

        accent_group = QGroupBox("Accent Color")
        accent_layout = QHBoxLayout(accent_group)
        colors = ["#4488ff", "#ff4488", "#44bb88", "#ff8844", "#8844ff", "#44bbff", "#ff4444", "#44ff88"]
        for color in colors:
            btn = QPushButton()
            btn.setFixedSize(36, 36)
            btn.setStyleSheet(f"background-color: {color}; border-radius: 18px; border: 2px solid transparent;")
            accent_layout.addWidget(btn)
        accent_layout.addWidget(QPushButton("Custom..."))
        layout.addWidget(accent_group)

        wallpaper_group = QGroupBox("Wallpaper")
        wallpaper_layout = QVBoxLayout(wallpaper_group)
        wallpaper_layout.addWidget(QPushButton("Browse wallpapers..."))
        wallpaper_layout.addWidget(QCheckBox("Dynamic wallpaper"))
        layout.addWidget(wallpaper_group)

        effects_group = QGroupBox("Visual Effects")
        effects_layout = QFormLayout(effects_group)
        blur = QSlider(Qt.Orientation.Horizontal)
        blur.setRange(0, 60)
        blur.setValue(30)
        effects_layout.addRow("Blur intensity:", blur)
        opacity = QSlider(Qt.Orientation.Horizontal)
        opacity.setRange(50, 100)
        opacity.setValue(85)
        effects_layout.addRow("Panel opacity:", opacity)
        effects_layout.addRow(QCheckBox("Animations enabled"))
        effects_layout.addRow(QCheckBox("Transparency effects"))
        layout.addWidget(effects_group)

        taskbar_group = QGroupBox("Taskbar")
        taskbar_layout = QFormLayout(taskbar_group)
        taskbar_pos = QComboBox()
        taskbar_pos.addItems(["Bottom", "Top", "Left", "Right"])
        taskbar_layout.addRow("Position:", taskbar_pos)
        taskbar_layout.addRow(QCheckBox("Center taskbar icons"))
        taskbar_layout.addRow(QCheckBox("Auto-hide taskbar"))
        taskbar_layout.addRow(QCheckBox("Show widgets button"))
        layout.addWidget(taskbar_group)

        layout.addStretch()
        return self.create_scroll_page(page)

    def create_apps_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.addWidget(QLabel("<h2>Apps</h2>"))
        layout.addWidget(QPushButton("Open App Store"))

        installed_group = QGroupBox("Installed Apps")
        installed_layout = QVBoxLayout(installed_group)
        apps = ["Firefox", "Files", "Terminal", "Text Editor", "Calculator",
                "Calendar", "Settings", "App Store", "Nebula AI"]
        for app in apps:
            row = QHBoxLayout()
            row.addWidget(QLabel(app))
            row.addStretch()
            row.addWidget(QPushButton("Uninstall"))
            installed_layout.addLayout(row)
        layout.addWidget(installed_group)

        layout.addStretch()
        return self.create_scroll_page(page)

    def create_accounts_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.addWidget(QLabel("<h2>Accounts</h2>"))

        user_group = QGroupBox("Your Account")
        user_layout = QFormLayout(user_group)
        user_layout.addRow("Username:", QLabel("nebula"))
        user_layout.addRow("Full name:", QLineEdit("Nebula User"))
        user_layout.addRow(QPushButton("Change password"))
        user_layout.addRow(QPushButton("Change profile picture"))
        layout.addWidget(user_group)

        layout.addWidget(QPushButton("Add another user"))
        layout.addStretch()
        return self.create_scroll_page(page)

    def create_privacy_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.addWidget(QLabel("<h2>Privacy & Security</h2>"))

        firewall_group = QGroupBox("Firewall")
        fw_layout = QVBoxLayout(firewall_group)
        fw_layout.addWidget(QCheckBox("Firewall enabled"))
        fw_layout.addWidget(QPushButton("Configure firewall rules"))
        layout.addWidget(firewall_group)

        perms_group = QGroupBox("App Permissions")
        perms_layout = QVBoxLayout(perms_group)
        for perm in ["Location", "Camera", "Microphone", "Notifications", "Files"]:
            perms_layout.addWidget(QCheckBox(f"Allow {perm} access"))
        layout.addWidget(perms_group)

        layout.addStretch()
        return self.create_scroll_page(page)

    def create_ai_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.addWidget(QLabel("<h2>AI Assistant</h2>"))

        general_group = QGroupBox("General")
        gen_layout = QFormLayout(general_group)
        gen_layout.addRow(QCheckBox("Enable Nebula AI"))
        gen_layout.addRow(QCheckBox("Start at login"))
        gen_layout.addRow("Activation shortcut:", QLineEdit("Super+Space"))
        layout.addWidget(general_group)

        voice_group = QGroupBox("Voice")
        voice_layout = QFormLayout(voice_group)
        voice_layout.addRow(QCheckBox("Enable voice input"))
        voice_layout.addRow(QCheckBox("Enable text-to-speech"))
        voice = QComboBox()
        voice.addItems(["Default", "Female 1", "Male 1", "Custom"])
        voice_layout.addRow("Voice:", voice)
        layout.addWidget(voice_group)

        api_group = QGroupBox("AI Backend")
        api_layout = QFormLayout(api_group)
        backend = QComboBox()
        backend.addItems(["Local (Offline)", "OpenAI API", "Custom API"])
        api_layout.addRow("Backend:", backend)
        api_layout.addRow("API Key:", QLineEdit())
        api_layout.addRow("Model:", QComboBox())
        layout.addWidget(api_group)

        layout.addStretch()
        return self.create_scroll_page(page)

    def create_time_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.addWidget(QLabel("<h2>Time & Language</h2>"))

        time_group = QGroupBox("Date & Time")
        time_layout = QFormLayout(time_group)
        time_layout.addRow(QCheckBox("Set time automatically"))
        tz = QComboBox()
        tz.addItems(["UTC", "US/Eastern", "US/Pacific", "Europe/London", "Asia/Tokyo"])
        time_layout.addRow("Timezone:", tz)
        time_layout.addRow(QCheckBox("24-hour format"))
        layout.addWidget(time_group)

        lang_group = QGroupBox("Language")
        lang_layout = QFormLayout(lang_group)
        lang = QComboBox()
        lang.addItems(["English (US)", "English (UK)", "Spanish", "French", "German", "Japanese", "Chinese"])
        lang_layout.addRow("Display language:", lang)
        layout.addWidget(lang_group)

        layout.addStretch()
        return self.create_scroll_page(page)

    def create_accessibility_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.addWidget(QLabel("<h2>Accessibility</h2>"))

        vision_group = QGroupBox("Vision")
        vision_layout = QVBoxLayout(vision_group)
        text_size = QSlider(Qt.Orientation.Horizontal)
        text_size.setRange(80, 200)
        text_size.setValue(100)
        vision_layout.addWidget(QLabel("Text size"))
        vision_layout.addWidget(text_size)
        vision_layout.addWidget(QCheckBox("High contrast"))
        vision_layout.addWidget(QCheckBox("Screen reader"))
        vision_layout.addWidget(QCheckBox("Magnifier"))
        layout.addWidget(vision_group)

        layout.addStretch()
        return self.create_scroll_page(page)

    def create_updates_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.addWidget(QLabel("<h2>Updates</h2>"))

        status_group = QGroupBox("Update Status")
        status_layout = QVBoxLayout(status_group)
        status_layout.addWidget(QLabel("NebulaOS is up to date"))
        status_layout.addWidget(QPushButton("Check for updates"))
        status_layout.addWidget(QCheckBox("Automatic updates"))
        layout.addWidget(status_group)

        recovery_group = QGroupBox("Recovery")
        recovery_layout = QVBoxLayout(recovery_group)
        recovery_layout.addWidget(QPushButton("Create recovery point"))
        recovery_layout.addWidget(QPushButton("Reset this PC"))
        layout.addWidget(recovery_group)

        layout.addStretch()
        return self.create_scroll_page(page)

    def create_about_page(self):
        page = QWidget()
        layout = QVBoxLayout(page)
        layout.addWidget(QLabel("<h2>About</h2>"))

        info_group = QGroupBox("System Information")
        info_layout = QFormLayout(info_group)
        info_layout.addRow("OS:", QLabel("NebulaOS 1.0 (Aurora)"))
        info_layout.addRow("Kernel:", QLabel("Linux 6.x"))
        info_layout.addRow("Desktop:", QLabel("Nebula Shell 1.0"))
        info_layout.addRow("Architecture:", QLabel("x86_64"))

        try:
            hostname = subprocess.check_output(["hostname"], text=True).strip()
        except Exception:
            hostname = "nebulaos"
        info_layout.addRow("Hostname:", QLabel(hostname))

        layout.addWidget(info_group)

        # NebulaOS branding
        layout.addWidget(QLabel(
            "<br><center>"
            "<h1 style='color: #4488ff;'>NebulaOS</h1>"
            "<p>Version 1.0 (Aurora)</p>"
            "<p style='color: gray;'>A modern, lightweight, AI-powered desktop OS</p>"
            "</center>"
        ))

        layout.addStretch()
        return self.create_scroll_page(page)

    def apply_theme(self):
        self.setStyleSheet("""
            QMainWindow { background-color: #0a0a1a; }
            QWidget { color: #ffffff; font-family: 'Inter', sans-serif; }
            QListWidget {
                background-color: #12122a;
                border: none;
                border-right: 1px solid #333355;
                font-size: 14px;
                padding: 8px;
            }
            QListWidget::item {
                padding: 12px 16px;
                border-radius: 8px;
                margin: 2px 4px;
            }
            QListWidget::item:selected {
                background-color: rgba(68, 136, 255, 0.2);
                color: #4488ff;
            }
            QListWidget::item:hover {
                background-color: rgba(255, 255, 255, 0.05);
            }
            QGroupBox {
                background-color: #1a1a2e;
                border: 1px solid #333355;
                border-radius: 12px;
                margin-top: 16px;
                padding: 16px;
                padding-top: 32px;
                font-size: 13px;
            }
            QGroupBox::title {
                color: #ffffff;
                font-weight: bold;
                padding: 4px 12px;
            }
            QPushButton {
                background-color: #2a2a4e;
                border: 1px solid #333355;
                border-radius: 8px;
                padding: 8px 16px;
                font-size: 13px;
                color: #ffffff;
            }
            QPushButton:hover { background-color: #3a3a5e; }
            QPushButton:pressed { background-color: #4488ff; }
            QComboBox {
                background-color: #2a2a4e;
                border: 1px solid #333355;
                border-radius: 8px;
                padding: 8px 12px;
                font-size: 13px;
                color: #ffffff;
            }
            QLineEdit {
                background-color: #2a2a4e;
                border: 1px solid #333355;
                border-radius: 8px;
                padding: 8px 12px;
                font-size: 13px;
                color: #ffffff;
            }
            QLineEdit:focus { border-color: #4488ff; }
            QCheckBox { font-size: 13px; spacing: 8px; }
            QCheckBox::indicator {
                width: 20px;
                height: 20px;
                border-radius: 4px;
                border: 2px solid #555577;
            }
            QCheckBox::indicator:checked { background-color: #4488ff; border-color: #4488ff; }
            QSlider::groove:horizontal {
                height: 6px;
                background: #333355;
                border-radius: 3px;
            }
            QSlider::handle:horizontal {
                background: #4488ff;
                width: 18px;
                height: 18px;
                margin: -6px 0;
                border-radius: 9px;
            }
            QSlider::sub-page:horizontal {
                background: #4488ff;
                border-radius: 3px;
            }
            QScrollArea { border: none; background: transparent; }
            QScrollBar:vertical {
                background: transparent;
                width: 8px;
            }
            QScrollBar::handle:vertical {
                background: #444466;
                border-radius: 4px;
                min-height: 30px;
            }
            QLabel { font-size: 13px; }
        """)


def main():
    app = QApplication(sys.argv)
    app.setApplicationName("NebulaOS Settings")
    app.setOrganizationName("NebulaOS")

    window = SettingsWindow()
    window.show()

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
