#include "virtualdesktopmanager.h"
#include <QVariantMap>

VirtualDesktopManager::VirtualDesktopManager(QObject *parent)
    : QObject(parent)
{
    addDesktop("Desktop 1");
}

int VirtualDesktopManager::currentDesktop() const { return m_currentDesktop; }
void VirtualDesktopManager::setCurrentDesktop(int index) {
    if (index >= 0 && index < m_desktops.size() && m_currentDesktop != index) {
        m_currentDesktop = index;
        emit currentDesktopChanged();
    }
}

int VirtualDesktopManager::desktopCount() const { return m_desktops.size(); }
QVariantList VirtualDesktopManager::desktops() const { return m_desktops; }

void VirtualDesktopManager::addDesktop(const QString &name) {
    QVariantMap desktop;
    desktop["name"] = name.isEmpty() ? QString("Desktop %1").arg(m_desktops.size() + 1) : name;
    desktop["index"] = m_desktops.size();
    m_desktops.append(desktop);
    emit desktopsChanged();
    emit desktopCountChanged();
}

void VirtualDesktopManager::removeDesktop(int index) {
    if (m_desktops.size() <= 1 || index < 0 || index >= m_desktops.size()) return;
    m_desktops.removeAt(index);
    if (m_currentDesktop >= m_desktops.size()) {
        m_currentDesktop = m_desktops.size() - 1;
        emit currentDesktopChanged();
    }
    emit desktopsChanged();
    emit desktopCountChanged();
}

void VirtualDesktopManager::renameDesktop(int index, const QString &name) {
    if (index < 0 || index >= m_desktops.size()) return;
    auto map = m_desktops[index].toMap();
    map["name"] = name;
    m_desktops[index] = map;
    emit desktopsChanged();
}

void VirtualDesktopManager::switchToNext() {
    setCurrentDesktop((m_currentDesktop + 1) % m_desktops.size());
}

void VirtualDesktopManager::switchToPrevious() {
    setCurrentDesktop((m_currentDesktop - 1 + m_desktops.size()) % m_desktops.size());
}
