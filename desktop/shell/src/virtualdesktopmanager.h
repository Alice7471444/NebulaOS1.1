#pragma once

#include <QObject>
#include <QVariantList>
#include <QString>

class VirtualDesktopManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int currentDesktop READ currentDesktop WRITE setCurrentDesktop NOTIFY currentDesktopChanged)
    Q_PROPERTY(int desktopCount READ desktopCount NOTIFY desktopCountChanged)
    Q_PROPERTY(QVariantList desktops READ desktops NOTIFY desktopsChanged)

public:
    explicit VirtualDesktopManager(QObject *parent = nullptr);

    int currentDesktop() const;
    void setCurrentDesktop(int index);
    int desktopCount() const;
    QVariantList desktops() const;

    Q_INVOKABLE void addDesktop(const QString &name = "");
    Q_INVOKABLE void removeDesktop(int index);
    Q_INVOKABLE void renameDesktop(int index, const QString &name);
    Q_INVOKABLE void switchToNext();
    Q_INVOKABLE void switchToPrevious();

signals:
    void currentDesktopChanged();
    void desktopCountChanged();
    void desktopsChanged();

private:
    QVariantList m_desktops;
    int m_currentDesktop = 0;
};
