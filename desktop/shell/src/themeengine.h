#pragma once

#include <QObject>
#include <QColor>
#include <QString>
#include <QVariantMap>

class SettingsManager;

class ThemeEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentTheme READ currentTheme WRITE setCurrentTheme NOTIFY themeChanged)
    Q_PROPERTY(bool darkMode READ darkMode WRITE setDarkMode NOTIFY darkModeChanged)
    Q_PROPERTY(QColor accentColor READ accentColor WRITE setAccentColor NOTIFY accentColorChanged)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor NOTIFY themeChanged)
    Q_PROPERTY(QColor surfaceColor READ surfaceColor NOTIFY themeChanged)
    Q_PROPERTY(QColor textColor READ textColor NOTIFY themeChanged)
    Q_PROPERTY(QColor textSecondaryColor READ textSecondaryColor NOTIFY themeChanged)
    Q_PROPERTY(QColor borderColor READ borderColor NOTIFY themeChanged)
    Q_PROPERTY(qreal blurRadius READ blurRadius WRITE setBlurRadius NOTIFY blurRadiusChanged)
    Q_PROPERTY(qreal opacity READ opacity WRITE setOpacity NOTIFY opacityChanged)
    Q_PROPERTY(int cornerRadius READ cornerRadius NOTIFY themeChanged)
    Q_PROPERTY(int animationDuration READ animationDuration NOTIFY themeChanged)

public:
    explicit ThemeEngine(SettingsManager *settings, QObject *parent = nullptr);

    QString currentTheme() const;
    void setCurrentTheme(const QString &theme);

    bool darkMode() const;
    void setDarkMode(bool dark);

    QColor accentColor() const;
    void setAccentColor(const QColor &color);

    QColor backgroundColor() const;
    QColor surfaceColor() const;
    QColor textColor() const;
    QColor textSecondaryColor() const;
    QColor borderColor() const;

    qreal blurRadius() const;
    void setBlurRadius(qreal radius);

    qreal opacity() const;
    void setOpacity(qreal opacity);

    int cornerRadius() const;
    int animationDuration() const;

    Q_INVOKABLE QVariantMap getThemeColors() const;
    Q_INVOKABLE void loadTheme(const QString &name);
    Q_INVOKABLE QStringList availableThemes() const;
    Q_INVOKABLE void setAutoTheme(bool enabled);

signals:
    void themeChanged();
    void darkModeChanged();
    void accentColorChanged();
    void blurRadiusChanged();
    void opacityChanged();

private:
    void applyTheme();
    void checkAutoTheme();

    SettingsManager *m_settings;
    QString m_currentTheme = "nebula-dark";
    bool m_darkMode = true;
    QColor m_accentColor = QColor("#4488ff");
    qreal m_blurRadius = 30.0;
    qreal m_opacity = 0.85;
    bool m_autoTheme = false;

    // Theme palette
    QColor m_backgroundColor;
    QColor m_surfaceColor;
    QColor m_textColor;
    QColor m_textSecondaryColor;
    QColor m_borderColor;
    int m_cornerRadius = 12;
    int m_animationDuration = 250;
};
