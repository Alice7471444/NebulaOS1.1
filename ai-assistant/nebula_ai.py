#!/usr/bin/env python3
"""
Nebula AI - NebulaOS Integrated AI Assistant v1.1 (Aurora)
Supports local mode and optional OpenAI API integration
"""

import sys
import os
import json
import subprocess
import threading
import random
from pathlib import Path
from datetime import datetime

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QTextEdit, QLineEdit, QPushButton, QLabel, QScrollArea,
    QFrame, QComboBox, QCheckBox
)
from PyQt6.QtCore import Qt, QTimer, pyqtSignal, QThread, QSettings
from PyQt6.QtGui import QFont, QTextCursor, QColor, QPalette


class AIBackend:
    """Handles AI response generation"""

    def __init__(self, settings):
        self.settings = settings
        self.mode = settings.value("ai/mode", "local")
        self.api_key = settings.value("ai/api_key", "")
        self.model = settings.value("ai/model", "gpt-3.5-turbo")
        self.conversation_history = []

    def get_response(self, user_input):
        """Generate a response based on the configured backend"""
        self.conversation_history.append({"role": "user", "content": user_input})

        if self.mode == "openai" and self.api_key:
            return self._openai_response(user_input)
        else:
            return self._local_response(user_input)

    def _local_response(self, user_input):
        """Local rule-based AI responses for system tasks"""
        lower = user_input.lower().strip()

        # System commands
        if any(w in lower for w in ["open", "launch", "start", "run"]):
            return self._handle_launch_command(lower)

        if any(w in lower for w in ["search", "find", "locate"]):
            return self._handle_search_command(lower)

        if any(w in lower for w in ["time", "date", "clock"]):
            now = datetime.now()
            return f"The current time is {now.strftime('%I:%M %p')} on {now.strftime('%A, %B %d, %Y')}."

        if any(w in lower for w in ["weather"]):
            return "Weather integration requires an API key. You can configure this in Settings > AI Assistant."

        if any(w in lower for w in ["battery", "power"]):
            return self._get_battery_info()

        if any(w in lower for w in ["system", "info", "about"]):
            return self._get_system_info()

        if any(w in lower for w in ["help", "what can you do"]):
            return self._get_help()

        if any(w in lower for w in ["hello", "hi", "hey", "hey"]):
            responses = [
                "Hello! I'm Nebula AI, your personal assistant. How can I help you today?",
                "Hey there! What can I do for you?",
                "Hi! Ready to assist you with NebulaOS!"
            ]
            return random.choice(responses)

        if any(w in lower for w in ["shutdown", "power off", "turn off"]):
            return "To shut down, say 'shutdown now' or use the power button in the Start Menu."

        if "shutdown now" in lower or "power off now" in lower:
            try:
                subprocess.run(["sudo", "poweroff"], check=True)
                return "Shutting down..."
            except:
                return "I need root privileges to shut down. Use the Start Menu instead."

        if "restart" in lower or "reboot" in lower:
            try:
                subprocess.run(["sudo", "reboot"], check=True)
                return "Restarting..."
            except:
                return "I need root privileges to restart. Use the Start Menu instead."

        if "screenshot" in lower:
            try:
                subprocess.Popen(["scrot", "-d", "5", str(Path.home()) + "/Screenshot.png"])
                return "Screenshot in 5 seconds! Look good 📸"
            except:
                return "Screenshot tool not found. Use the Print key or install scrot."

        if "lock" in lower or "lock screen" in lower:
            return "To lock the screen, press Super+L or say 'lock screen now'"

        if any(w in lower for w in ["update", "upgrade"]):
            return "To update your system, go to Settings > Updates or run 'sudo apt update && sudo apt upgrade' in the terminal."

        return (
            "I understand you said: '" + user_input + "'. "
            "In local mode, I can help with system tasks like launching apps, "
            "searching files, and checking system info. For advanced AI conversations, "
            "configure an API key in Settings > AI Assistant."
        )

    def _openai_response(self, user_input):
        """Generate response using OpenAI API"""
        try:
            import openai
            client = openai.OpenAI(api_key=self.api_key)

            messages = [
                {"role": "system", "content":
                    "You are Nebula AI, the built-in assistant for NebulaOS. "
                    "You help users with system tasks, answer questions, and provide "
                    "a friendly conversational experience. Be concise and helpful."}
            ] + self.conversation_history[-10:]

            response = client.chat.completions.create(
                model=self.model,
                messages=messages,
                max_tokens=500,
                temperature=0.7
            )
            reply = response.choices[0].message.content
            self.conversation_history.append({"role": "assistant", "content": reply})
            return reply

        except ImportError:
            return "OpenAI library not installed. Run: pip install openai"
        except Exception as e:
            return f"API error: {str(e)}. Check your API key in Settings."

    def _handle_launch_command(self, text):
        app_map = {
            "firefox": "firefox",
            "browser": "firefox",
            "terminal": "alacritty",
            "files": "thunar",
            "file manager": "thunar",
            "settings": "nebula-settings",
            "calculator": "gnome-calculator",
            "text editor": "gedit",
            "calendar": "gnome-calendar",
            "app store": "nebula-store",
        }
        for name, cmd in app_map.items():
            if name in text:
                try:
                    subprocess.Popen([cmd])
                    return f"Opening {name}..."
                except FileNotFoundError:
                    return f"Could not find {name}. It may not be installed."

        return "Which app would you like me to open? Try: browser, terminal, files, settings, calculator, or text editor."

    def _handle_search_command(self, text):
        words = text.split()
        query = " ".join(w for w in words if w not in ["search", "find", "locate", "for", "file", "files"])
        if query.strip():
            try:
                result = subprocess.run(
                    ["find", str(Path.home()), "-maxdepth", "3", "-name", f"*{query.strip()}*", "-type", "f"],
                    capture_output=True, text=True, timeout=5
                )
                files = result.stdout.strip().split('\n')[:5]
                if files and files[0]:
                    return "Found these files:\n" + "\n".join(f"  - {f}" for f in files)
                return f"No files matching '{query.strip()}' found."
            except Exception:
                return "Search encountered an error. Try using the file manager."
        return "What would you like me to search for?"

    def _get_battery_info(self):
        try:
            capacity = Path("/sys/class/power_supply/BAT0/capacity").read_text().strip()
            status = Path("/sys/class/power_supply/BAT0/status").read_text().strip()
            return f"Battery: {capacity}% ({status})"
        except FileNotFoundError:
            return "No battery detected. You're running on AC power."

    def _get_system_info(self):
        info = ["System Information:"]
        try:
            info.append(f"  OS: NebulaOS 1.0 (Aurora)")
            kernel = subprocess.check_output(["uname", "-r"], text=True).strip()
            info.append(f"  Kernel: {kernel}")
            hostname = subprocess.check_output(["hostname"], text=True).strip()
            info.append(f"  Hostname: {hostname}")
            uptime = subprocess.check_output(["uptime", "-p"], text=True).strip()
            info.append(f"  Uptime: {uptime}")
            with open("/proc/meminfo") as f:
                for line in f:
                    if "MemTotal" in line:
                        mem_kb = int(line.split()[1])
                        info.append(f"  RAM: {mem_kb // 1024} MB")
                        break
        except Exception:
            pass
        return "\n".join(info)

    def _get_help(self):
        return """I'm Nebula AI v1.1 (Aurora), and here's what I can do:

  🤖 AI Chat (with OpenAI API key in Settings)
  
  📱 Apps:
  - "Open Firefox", "Launch terminal", "Start settings"
  - "Calculator", "Files", "Calendar", "App store"
  
  🔍 Search:
  - "Find document.pdf", "Search for [filename]"
  
  💻 System:
  - "System info" - Show system status
  - "Check battery" - Power status
  - "Weather" - Requires API key
  - "Time", "Date" - Current time
  
  ⚡ Quick Actions:
  - "Screenshot", "Lock screen"
  - "Shutdown now", "Restart"
  
Keyboard shortcut: Super+Space to toggle me!

For advanced AI chat, configure an OpenAI API key in Settings > AI Assistant."""


class ChatMessage(QFrame):
    def __init__(self, text, is_user=False, parent=None):
        super().__init__(parent)
        self.setStyleSheet(f"""
            QFrame {{
                background-color: {'#2a2a4e' if is_user else '#1a1a2e'};
                border: 1px solid {'#4488ff' if is_user else '#333355'};
                border-radius: 12px;
                {'margin-left: 60px;' if is_user else 'margin-right: 60px;'}
            }}
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(14, 10, 14, 10)

        sender = QLabel("You" if is_user else "Nebula AI")
        sender.setStyleSheet(f"color: {'#4488ff' if is_user else '#44bbaa'}; font-size: 11px; font-weight: bold; border: none;")
        layout.addWidget(sender)

        msg = QLabel(text)
        msg.setWordWrap(True)
        msg.setTextInteractionFlags(Qt.TextInteractionFlag.TextSelectableByMouse)
        msg.setStyleSheet("color: #ffffff; font-size: 13px; border: none; line-height: 1.4;")
        layout.addWidget(msg)


class AIResponseWorker(QThread):
    response_ready = pyqtSignal(str)

    def __init__(self, backend, user_input):
        super().__init__()
        self.backend = backend
        self.user_input = user_input

    def run(self):
        response = self.backend.get_response(self.user_input)
        self.response_ready.emit(response)


class NebulaAIWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.settings = QSettings("NebulaOS", "nebula-ai")
        self.backend = AIBackend(self.settings)
        self.setWindowTitle("Nebula AI")
        self.setMinimumSize(480, 600)
        self.resize(520, 720)
        self.setup_ui()
        self.apply_theme()
        self.show_welcome()

    def setup_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        # Header
        header = QWidget()
        header.setFixedHeight(60)
        header.setStyleSheet("background-color: #12122a; border-bottom: 1px solid #333355;")
        header_layout = QHBoxLayout(header)
        header_layout.setContentsMargins(20, 0, 20, 0)

        title = QLabel("\u2728 Nebula AI")
        title.setStyleSheet("font-size: 18px; font-weight: bold; color: #4488ff;")
        header_layout.addWidget(title)

        header_layout.addStretch()

        mode_label = QLabel("Mode:")
        mode_label.setStyleSheet("color: #aaaacc; font-size: 12px;")
        header_layout.addWidget(mode_label)

        self.mode_combo = QComboBox()
        self.mode_combo.addItems(["Local", "OpenAI"])
        self.mode_combo.setFixedWidth(100)
        self.mode_combo.setStyleSheet("""
            QComboBox {
                background-color: #1a1a2e; border: 1px solid #333355;
                border-radius: 6px; padding: 4px 8px; color: white; font-size: 12px;
            }
        """)
        header_layout.addWidget(self.mode_combo)

        layout.addWidget(header)

        # Chat area
        self.chat_scroll = QScrollArea()
        self.chat_scroll.setWidgetResizable(True)
        self.chat_scroll.setFrameShape(QFrame.Shape.NoFrame)
        self.chat_scroll.setStyleSheet("background-color: #0a0a1a; border: none;")

        self.chat_container = QWidget()
        self.chat_layout = QVBoxLayout(self.chat_container)
        self.chat_layout.setContentsMargins(16, 16, 16, 16)
        self.chat_layout.setSpacing(12)
        self.chat_layout.addStretch()

        self.chat_scroll.setWidget(self.chat_container)
        layout.addWidget(self.chat_scroll)

        # Input area
        input_area = QWidget()
        input_area.setFixedHeight(70)
        input_area.setStyleSheet("background-color: #12122a; border-top: 1px solid #333355;")
        input_layout = QHBoxLayout(input_area)
        input_layout.setContentsMargins(16, 12, 16, 12)
        input_layout.setSpacing(8)

        self.input_field = QLineEdit()
        self.input_field.setPlaceholderText("Ask Nebula AI anything...")
        self.input_field.setFixedHeight(44)
        self.input_field.setStyleSheet("""
            QLineEdit {
                background-color: #1a1a2e;
                border: 1px solid #333355;
                border-radius: 22px;
                padding: 0 20px;
                font-size: 14px;
                color: white;
            }
            QLineEdit:focus { border-color: #4488ff; }
        """)
        self.input_field.returnPressed.connect(self.send_message)
        input_layout.addWidget(self.input_field)

        send_btn = QPushButton("\u27A4")
        send_btn.setFixedSize(44, 44)
        send_btn.setStyleSheet("""
            QPushButton {
                background-color: #4488ff;
                border: none;
                border-radius: 22px;
                font-size: 18px;
                color: white;
            }
            QPushButton:hover { background-color: #5599ff; }
            QPushButton:pressed { background-color: #3377dd; }
        """)
        send_btn.clicked.connect(self.send_message)
        input_layout.addWidget(send_btn)

        layout.addWidget(input_area)

    def show_welcome(self):
        welcome = (
            "Hello! I'm Nebula AI v1.1 (Aurora), your personal assistant on NebulaOS. ✨\n\n"
            "I can help you with:\n"
            "• Launching apps (say 'Open Firefox')\n"
            "• Searching files (say 'Find document')\n"
            "• System info and status\n"
            "• And much more!\n\n"
            "Type a message or say 'help' to see all commands!"
        )
        self.add_message(welcome, is_user=False)

    def send_message(self):
        text = self.input_field.text().strip()
        if not text:
            return

        self.input_field.clear()
        self.add_message(text, is_user=True)

        # Show typing indicator
        typing = QLabel("Nebula AI is thinking...")
        typing.setStyleSheet("color: #aaaacc; font-size: 12px; font-style: italic; padding: 8px;")
        self.chat_layout.addWidget(typing)
        self.scroll_to_bottom()

        # Get AI response in background
        self.worker = AIResponseWorker(self.backend, text)
        self.worker.response_ready.connect(lambda response: self.on_response(response, typing))
        self.worker.start()

    def on_response(self, response, typing_widget):
        typing_widget.deleteLater()
        self.add_message(response, is_user=False)

    def add_message(self, text, is_user):
        msg = ChatMessage(text, is_user)
        self.chat_layout.insertWidget(self.chat_layout.count() - 1, msg)
        self.scroll_to_bottom()

    def scroll_to_bottom(self):
        QTimer.singleShot(100, lambda: self.chat_scroll.verticalScrollBar().setValue(
            self.chat_scroll.verticalScrollBar().maximum()
        ))

    def apply_theme(self):
        self.setStyleSheet("""
            QMainWindow { background-color: #0a0a1a; }
            QWidget { color: #ffffff; font-family: 'Inter', sans-serif; }
        """)


def main():
    app = QApplication(sys.argv)
    app.setApplicationName("Nebula AI")
    app.setOrganizationName("NebulaOS")
    window = NebulaAIWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
