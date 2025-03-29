import QtQuick 2.2
import MuseScore 3.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

MuseScore {
    id: myPlugin
    pluginType: "dialog"
    version: "0.1"
    width: 500  // Increased width to accommodate side-by-side layout
    height: 500

    // Enharmonic pairs for each column (5 rows, no Cb, Fb, E#, B#)
    property var firstColumnPairs: [
        ["Db", "C#"],
        ["Eb", "D#"],
        ["Gb", "F#"],
        ["Ab", "G#"],
        ["Bb", "A#"]
    ]
    
    property var secondColumnPairs: [
        ["C#", "Db"],
        ["D#", "Eb"],
        ["F#", "Gb"],
        ["G#", "Ab"],
        ["A#", "Bb"]
    ]

    property var firstColumnCheckBoxes: []
    property var secondColumnCheckBoxes: []

    property var firstColumnNoteCheckBoxes: []  // For notes
    property var secondColumnNoteCheckBoxes: []  // For notes

    function setColumnChecked(column, checked) {
        for (var i = 0; i < column.length; i++) {
            column[i].checked = checked;
        }
    }

    function onOKClicked() {
        // Placeholder function
        console.log("OK clicked");
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        RowLayout {
            spacing: 20
            Layout.fillWidth: true

            // Global selection checkboxes for Chord Symbols
            GroupBox {
                title: "Chord Symbols"
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: 15
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter

                        CheckBox {
                            id: allBtoSharp
                            text: "b to #"
                            onCheckedChanged: {
                                setColumnChecked(firstColumnCheckBoxes, checked);
                                if (checked) {
                                    allSharpToB.checked = false;
                                }
                            }
                        }

                        CheckBox {
                            id: allSharpToB
                            text: "# to b"
                            onCheckedChanged: {
                                setColumnChecked(secondColumnCheckBoxes, checked);
                                if (checked) {
                                    allBtoSharp.checked = false;
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 8
                        Layout.fillWidth: true

                        Repeater {
                            model: firstColumnPairs
                            delegate: RowLayout {
                                spacing: 25
                                Layout.fillWidth: true

                                CheckBox {
                                    id: firstOption
                                    text: modelData[0] + " to " + modelData[1];
                                    Layout.alignment: Qt.AlignLeft
                                    Layout.fillWidth: true
                                    onCheckedChanged: {
                                        if (!checked) allBtoSharp.checked = false;
                                        if (checked) secondOption.checked = false;
                                    }
                                    Component.onCompleted: firstColumnCheckBoxes.push(firstOption)
                                }

                                CheckBox {
                                    id: secondOption
                                    text: secondColumnPairs[index][0] + " to " + secondColumnPairs[index][1]
                                    Layout.alignment: Qt.AlignLeft
                                    Layout.fillWidth: true
                                    onCheckedChanged: {
                                        if (!checked) allSharpToB.checked = false;
                                        if (checked) firstOption.checked = false;
                                    }
                                    Component.onCompleted: secondColumnCheckBoxes.push(secondOption)
                                }
                            }
                        }
                    }
                }
            }

            // Global selection checkboxes for Notes
            GroupBox {
                title: "Notes"
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: 15
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter

                        CheckBox {
                            id: allBtoSharpNotes
                            text: "b to #"
                            onCheckedChanged: {
                                setColumnChecked(firstColumnNoteCheckBoxes, checked);
                                if (checked) {
                                    allSharpToBNotes.checked = false;
                                }
                            }
                        }

                        CheckBox {
                            id: allSharpToBNotes
                            text: "# to b"
                            onCheckedChanged: {
                                setColumnChecked(secondColumnNoteCheckBoxes, checked);
                                if (checked) {
                                    allBtoSharpNotes.checked = false;
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 8
                        Layout.fillWidth: true

                        Repeater {
                            model: firstColumnPairs
                            delegate: RowLayout {
                                spacing: 25
                                Layout.fillWidth: true

                                CheckBox {
                                    id: firstNoteOption
                                    text: modelData[0] + " to " + modelData[1];
                                    Layout.alignment: Qt.AlignLeft
                                    Layout.fillWidth: true
                                    onCheckedChanged: {
                                        if (!checked) allBtoSharpNotes.checked = false;
                                        if (checked) secondNoteOption.checked = false;
                                    }
                                    Component.onCompleted: firstColumnNoteCheckBoxes.push(firstNoteOption)
                                }

                                CheckBox {
                                    id: secondNoteOption
                                    text: secondColumnPairs[index][0] + " to " + secondColumnPairs[index][1]
                                    Layout.alignment: Qt.AlignLeft
                                    Layout.fillWidth: true
                                    onCheckedChanged: {
                                        if (!checked) allSharpToBNotes.checked = false;
                                        if (checked) firstNoteOption.checked = false;
                                    }
                                    Component.onCompleted: secondColumnNoteCheckBoxes.push(secondNoteOption)
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                text: "OK"
                onClicked: {
                    onOKClicked();
                    Qt.quit();
                }
            }

            Button {
                text: "Cancel"
                onClicked: Qt.quit();
            }
        }
    }
}
