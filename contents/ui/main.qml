import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.0
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrolsaddons as KQuickControlsAddons

PlasmoidItem {
    id: rootcontainer
    
    compactRepresentation: PlasmaComponents.ToolButton {
        id: compactButton
        anchors.fill: parent
        icon.name: plasmoid.icon || "message-new"
        display: PlasmaComponents.AbstractButton.IconOnly
        Accessible.name: i18n("Open pipsqueak")

        onClicked: {
            rootcontainer.expanded = !rootcontainer.expanded
        }
    }

    fullRepresentation: Item {

        id: fullrep
        Layout.preferredWidth: 640
        Layout.preferredHeight: 450
        Layout.minimumWidth: 420
        Layout.minimumHeight: 300
        KQuickControlsAddons.Clipboard { 
            id: clipboard
        }
        
        property string selectedModel: ""
        property string modelText: selectedModel === "" ? "none" : selectedModel
        
        function getModels() {
            var request = new XMLHttpRequest()
            var endpoint = plasmoid.configuration.endpoint
            if (endpoint.endsWith("/"))
                endpoint = endpoint.slice(0, -1)

            request.open("GET", endpoint + "/v1/models")
            request.onreadystatechange = function() {
                if (request.readyState !== XMLHttpRequest.DONE)
                    return
                if (request.status === 200) {
                    var response = JSON.parse(request.responseText)
                    for (var i = 0; i < response.data.length; ++i) {
                        modelList.append({
                            name: response.data[i].id
                        })
                    }
                }
            }
            modelList.clear()
            request.send()
        }
        function sendPrompt() {
            var request = new XMLHttpRequest()
            var endpoint = plasmoid.configuration.endpoint
            var systemPrompt = plasmoid.configuration.systemPrompt
            if (endpoint.endsWith("/"))
                endpoint = endpoint.slice(0, -1)
            request.open("POST", endpoint + "/v1/chat/completions")
            request.setRequestHeader("Content-Type", "application/json")

            var body = {
                model: selectedModel,
                messages: [
                    {
                        role: "system",
                        content: systemPrompt
                        },
                    {
                        role: "user",
                        content: promptArea.text
                        }
                ],
                stream: false
            }

            request.onreadystatechange = function() {
                if (request.readyState !== XMLHttpRequest.DONE)
                    return
                var response = JSON.parse(request.responseText)
                responseArea.text = response.choices[0].message.content
            }
            request.send(JSON.stringify(body))
        }
        
        ListModel {
            id: modelList
        }

        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                id: promptControl
                Layout.alignment: Qt.AlignTop

                PlasmaComponents.Label {
                    id: promptLabel
                    text: "Prompt:"
                    font.bold: true
                    Layout.fillWidth: true
                }

                PlasmaComponents.Label {
                    id: modelLabel
                    opacity: 0.5
                    text: "current model: " + modelText
                    Layout.alignment: Qt.AlignRight
                }

                PlasmaComponents.Button {
                    id: sendButton
                    text: "Send"
                    Layout.alignment: Qt.AlignRight
                    onClicked: {sendPrompt()}
                }

                PlasmaComponents.Button {
                    id: clearButton
                    text: "Clear"
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        promptArea.text = ""
                    }
                }

                PlasmaComponents.Button {
                    id: dropdownButton
                    text: "Model"
                    onClicked: {
                        getModels()
                        popup.open()
                    }
                    Layout.alignment: Qt.AlignRight
                }
            }
            PlasmaComponents.ScrollView {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.minimumHeight: 2
                Layout.maximumHeight: 150
                ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }
                PlasmaComponents.TextArea {
                    id: promptArea
                    wrapMode: TextEdit.Wrap
                }
            }

            RowLayout {
                PlasmaComponents.Label {
                    id: responseLabel
                    text: "Response:"
                    font.bold: true
                    Layout.fillWidth: true
                }

                PlasmaComponents.Button {
                    id: copyButton
                    text: "Copy"
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        clipboard.content = responseArea.text
                    }
                }
            }
            PlasmaComponents.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0
                ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }
                PlasmaComponents.TextArea {
                    id: responseArea
                    readOnly: true
                    wrapMode: TextEdit.Wrap
                }
            }
        }

        PlasmaComponents.Popup {
            id: popup
            parent: dropdownButton
            
            width: 125
            height: Math.max(30, Math.min(250, modelList.count * 30 + 16))

            x: parent.width - width
            y: parent.height

            contentItem: ListView {
                id: popupList
                anchors {
                    fill: parent
                    leftMargin: 10
                    rightMargin: 10
                    topMargin: 10
                    bottomMargin: 10
                }
                clip: true
                model: modelList

                delegate: PlasmaComponents.ItemDelegate {
                    width: ListView.view.width
                    id: popupDelegate
                    height: 30
                    text: model.name
                    onClicked: {
                        selectedModel = model.name
                    }
                }
            }
        }

        x: 0
        y: dropdownButton.height - 5
    }

}
