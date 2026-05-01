#pragma once

#include <QObject>
#include <QVariantList>
#include <QString>

class SearchProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList results READ results NOTIFY resultsChanged)
    Q_PROPERTY(bool searching READ searching NOTIFY searchingChanged)

public:
    explicit SearchProvider(QObject *parent = nullptr);

    QVariantList results() const;
    bool searching() const;

    Q_INVOKABLE void search(const QString &query);
    Q_INVOKABLE void clearResults();

signals:
    void resultsChanged();
    void searchingChanged();

private:
    void searchApplications(const QString &query);
    void searchFiles(const QString &query);
    void searchSettings(const QString &query);

    QVariantList m_results;
    bool m_searching = false;
};
