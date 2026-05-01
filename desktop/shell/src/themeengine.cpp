#include "themeengine.h"
#include "settingsmanager.h"

#include <QTimer>
#include <QTime>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>

ThemeEngine::ThemeEngine(SettingsManager *settings, QObject *parent)
    : QObject(parent)
    , m_settings(settings)
{
    m_currentTheme = m_settings->value("theme/current", "nebula-dark").toString();
    m_darkMode = m_settings->value("theme/darkMode", true).toBool();
    m_accentColor = QColor(m_settings->value("theme/accentColor", "#4488ff").toString());
    m_blurRadius = m_settings->value("theme/blurRadius", 30.0).toDouble();
    m_opacity = m_settings->value("theme/opacity", 0.85).toDouble();
    m_autoTheme = m_settings->value("theme/autoSwitch", false).toBool();

    applyTheme();

    if (m_autoTheme) {
        auto *timer = new QTimer(this);
        connect(timer, &QTimer::timeout, this, &ThemeEngine::checkAutoTheme);
        timer->start(60000);
        checkAutoTheme();
    }
}

QString ThemeEngine::currentTheme() const { return m_currentTheme; }
void ThemeEngine::setCurrentTheme(const QString &theme) {
    if (m_currentTheme != theme) {
        m_currentTheme = theme;
        m_settings->setValue("theme/current", theme);
        applyTheme();
        emit themeChanged();
    }
}

bool ThemeEngine::darkMode() const { return m_darkMode; }
void ThemeEngine::setDarkMode(bool dark) {
    if (m_darkMode != dark) {
        m_darkMode = dark;
        m_settings->setValue("theme/darkMode", dark);
        applyTheme();
        emit darkModeChanged();
        emit themeChanged();
    }
}

QColor ThemeEngine::accentColor() const { return m_accentColor; }
void ThemeEngine::setAccentColor(const QColor &color) {
    if (m_accentColor != color) {
        m_accentColor = color;
        m_settings->setValue("theme/accentColor", color.name());
        emit accentColorChanged();
        emit themeChanged();
    }
}

QColor ThemeEngine::backgroundColor() const { return m_backgroundColor; }
QColor ThemeEngine::surfaceColor() const { return m_surfaceColor; }
QColor ThemeEngine::textColor() const { return m_textColor; }
QColor ThemeEngine::textSecondaryColor() const { return m_textSecondaryColor; }
QColor ThemeEngine::borderColor() const { return m_borderColor; }

qreal ThemeEngine::blurRadius() const { return m_blurRadius; }
void ThemeEngine::setBlurRadius(qreal radius) {
    if (!qFuzzyCompare(m_blurRadius, radius)) {
        m_blurRadius = radius;
        m_settings->setValue("theme/blurRadius", radius);
        emit blurRadiusChanged();
    }
}

qreal ThemeEngine::opacity() const { return m_opacity; }
void ThemeEngine::setOpacity(qreal opacity) {
    if (!qFuzzyCompare(m_opacity, opacity)) {
        m_opacity = opacity;
        m_settings->setValue("theme/opacity", opacity);
        emit opacityChanged();
    }
}

int ThemeEngine::cornerRadius() const { return m_cornerRadius; }
int ThemeEngine::animationDuration() const { return m_animationDuration; }

QVariantMap ThemeEngine::getThemeColors() const {
    QVariantMap colors;
    colors["background"] = m_backgroundColor;
    colors["surface"] = m_surfaceColor;
    colors["text"] = m_textColor;
    colors["textSecondary"] = m_textSecondaryColor;
    colors["border"] = m_borderColor;
    colors["accent"] = m_accentColor;
    return colors;
}

void ThemeEngine::loadTheme(const QString &name) {
    QString themePath = QString("/usr/share/nebula-desktop/themes/%1/theme.json").arg(name);
    QFile file(themePath);
    if (!file.open(QIODevice::ReadOnly)) return;

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    QJsonObject obj = doc.object();

    if (obj.contains("darkMode")) m_darkMode = obj["darkMode"].toBool();
    if (obj.contains("accentColor")) m_accentColor = QColor(obj["accentColor"].toString());
    if (obj.contains("blurRadius")) m_blurRadius = obj["blurRadius"].toDouble();
    if (obj.contains("opacity")) m_opacity = obj["opacity"].toDouble();
    if (obj.contains("cornerRadius")) m_cornerRadius = obj["cornerRadius"].toInt();

    m_currentTheme = name;
    applyTheme();
    emit themeChanged();
}

QStringList ThemeEngine::availableThemes() const {
    QStringList themes;
    QDir dir("/usr/share/nebula-desktop/themes");
    if (dir.exists()) {
        for (const auto &entry : dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
            themes << entry;
        }
    }
    if (themes.isEmpty()) {
        themes << "nebula-dark" << "nebula-light" << "nebula-blue";
    }
    return themes;
}

void ThemeEngine::setAutoTheme(bool enabled) {
    m_autoTheme = enabled;
    m_settings->setValue("theme/autoSwitch", enabled);
    if (enabled) checkAutoTheme();
}

void ThemeEngine::applyTheme() {
    if (m_darkMode) {
        m_backgroundColor = QColor("#0a0a1a");
        m_surfaceColor = QColor("#1a1a2e");
        m_textColor = QColor("#ffffff");
        m_textSecondaryColor = QColor("#aaaacc");
        m_borderColor = QColor("#333355");
    } else {
        m_backgroundColor = QColor("#f0f0f5");
        m_surfaceColor = QColor("#ffffff");
        m_textColor = QColor("#1a1a2e");
        m_textSecondaryColor = QColor("#666680");
        m_borderColor = QColor("#d0d0e0");
    }
}

void ThemeEngine::checkAutoTheme() {
    QTime now = QTime::currentTime();
    bool shouldBeDark = (now.hour() >= 19 || now.hour() < 7);
    if (m_darkMode != shouldBeDark) {
        setDarkMode(shouldBeDark);
    }
}
