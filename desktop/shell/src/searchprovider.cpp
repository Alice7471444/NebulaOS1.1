#include "searchprovider.h"

#include <QDir>
#include <QDirIterator>
#include <QVariantMap>

SearchProvider::SearchProvider(QObject *parent)
    : QObject(parent)
{
}

QVariantList SearchProvider::results() const { return m_results; }
bool SearchProvider::searching() const { return m_searching; }

void SearchProvider::search(const QString &query) {
    if (query.isEmpty()) {
        clearResults();
        return;
    }

    m_searching = true;
    emit searchingChanged();

    m_results.clear();
    searchApplications(query);
    searchFiles(query);
    searchSettings(query);

    m_searching = false;
    emit searchingChanged();
    emit resultsChanged();
}

void SearchProvider::clearResults() {
    m_results.clear();
    emit resultsChanged();
}

void SearchProvider::searchApplications(const QString &query) {
    QDir appDir("/usr/share/applications");
    if (!appDir.exists()) return;

    for (const auto &entry : appDir.entryInfoList({"*.desktop"}, QDir::Files)) {
        if (entry.baseName().toLower().contains(query.toLower())) {
            QVariantMap result;
            result["type"] = "application";
            result["name"] = entry.baseName();
            result["path"] = entry.absoluteFilePath();
            result["icon"] = "application-x-desktop";
            m_results.append(result);
        }
    }
}

void SearchProvider::searchFiles(const QString &query) {
    QDir homeDir(QDir::homePath());
    QDirIterator it(homeDir.absolutePath(), QDir::Files | QDir::NoDotAndDotDot,
                    QDirIterator::Subdirectories);

    int count = 0;
    while (it.hasNext() && count < 10) {
        it.next();
        if (it.fileName().toLower().contains(query.toLower())) {
            QVariantMap result;
            result["type"] = "file";
            result["name"] = it.fileName();
            result["path"] = it.filePath();
            result["icon"] = "text-x-generic";
            m_results.append(result);
            count++;
        }
    }
}

void SearchProvider::searchSettings(const QString &query) {
    QStringList settingsPages = {
        "Display", "Audio", "Network", "Bluetooth", "Users",
        "Storage", "Privacy", "Themes", "AI Settings", "Updates"
    };

    for (const auto &page : settingsPages) {
        if (page.toLower().contains(query.toLower())) {
            QVariantMap result;
            result["type"] = "setting";
            result["name"] = page;
            result["icon"] = "preferences-system";
            m_results.append(result);
        }
    }
}
