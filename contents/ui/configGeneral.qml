import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.5 as QQC2
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page
    property alias cfg_systemPrompt: systemPrompt.text
    property alias cfg_endpoint: endpoint.text
    Item {
        Layout.columnSpan: 2
        Layout.preferredHeight: Kirigami.Units.largeSpacing
    }
    QQC2.TextField {
        id: endpoint
        Kirigami.FormData.label: qsTr("Ollama Instance URL")
        placeholderText: qsTr("http://localhost:11434")
    }
    QQC2.TextField {
        id: systemPrompt
        Kirigami.FormData.label: qsTr("systemPrompt")
        placeholderText: qsTr("Help the user in the most efficient way you can.")
    }
}