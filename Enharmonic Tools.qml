// qmllint disable

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import MuseScore 3.0

MuseScore {
    id: enharmonicTools
    version: "0.2"
    menuPath: "Plugins.Enharmonic Tools"
    description: "A plugin for managing enharmonic spellings in chords and notes. Author: Konstantin Vlasenko."

    property bool debug: false // Global flag to enable or disable logging

    function log(message) {
        if (debug) {
            console.log(message);
        }
    }

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

    // Data models for enharmonic pairs
    property var flatList: [
        ["Cb", "B"],
        ["Fb", "E"]
    ]
    property var sharpList: [
        ["E#", "F"],
        ["B#", "C"]
    ]
    property var doubleSharpList: [
        ["C##", "D"],
        ["D##", "E"],
        ["E##", "F#"],
        ["F##", "G"],
        ["G##", "A"],
        ["A##", "B"],
        ["B##", "C#"]
    ]
    property var doubleFlatList: [
        ["Cbb", "Bb"],
        ["Dbb", "C"],
        ["Ebb", "D"],
        ["Fbb", "Eb"],
        ["Gbb", "F"],
        ["Abb", "G"],
        ["Bbb", "A"]
    ]

    Component.onCompleted: {
        log("Prepopulated flatList:", flatList);
        log("Prepopulated sharpList:", sharpList);
        log("Prepopulated doubleSharpList:", doubleSharpList);
        log("Prepopulated doubleFlatList:", doubleFlatList);
    }

    // Function to add or remove items from a list
    function updateList(list, pair, checked) {
        if (checked) {
            if (!list.includes(pair)) {
                list.push(pair);
            }
        } else {
            var index = list.indexOf(pair);
            if (index !== -1) {
                list.splice(index, 1);
            }
        }
        log("Updated list:", list);
    }

    // Function to add a pair to a list
    function addToList(list, pair) {
        if (!list.some(function(item) { return item[0] === pair[0] && item[1] === pair[1]; })) {
            list.push(pair);
            log("Added pair: " + pair + " Updated list: " + list);
        }
    }

    // Function to remove a pair from a list
    function removeFromList(list, pair) {
        var index = list.findIndex(function(item) {
            return item[0] === pair[0] && item[1] === pair[1];
        });
        if (index !== -1) {
            list.splice(index, 1);
            log("Removed pair: " + pair + " Updated list: " + list);
        }
    }

    function setColumnChecked(column, checked) {
        for (var i = 0; i < column.length; i++) {
            column[i].checked = checked;
        }
    }

    onRun: {
    enharmonicDialog.visible = true;
    }

    Dialog {
            id: enharmonicDialog
            title: "Enharmonic Tools"
            modality: Qt.ApplicationModal // Make the dialog modal
            visible: false
            width: 450
            height: 400
            standardButtons: Dialog.Ok | Dialog.Cancel

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20

            // Layout for the "Chord Symbols" and "Notes" section
            RowLayout {
                spacing: 20
                Layout.fillWidth: true

                // GroupBox for "Chord Symbols"
                GroupBox {
                    title: "Chord Symbols"
                    Layout.fillWidth: true

                    // Layout for the content inside the "Chord Symbols" GroupBox
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true

                        // Row for global checkboxes ("b to #" and "# to b")
                        RowLayout {
                            spacing: 25
                            Layout.fillWidth: true

                            // Left column for "b to #" checkbox
                            CheckBox {
                                id: allBtoSharp
                                text: "All b → #"
                                Layout.alignment: Qt.AlignLeft
                                onCheckedChanged: {
                                    setColumnChecked(firstColumnCheckBoxes, checked);
                                    if (checked) {
                                        allSharpToB.checked = false;
                                    }
                                }
                            }

                            // Right column for "# to b" checkbox
                            CheckBox {
                                id: allSharpToB
                                text: "All # → b"
                                Layout.alignment: Qt.AlignRight
                                onCheckedChanged: {
                                    setColumnChecked(secondColumnCheckBoxes, checked);
                                    if (checked) {
                                        allBtoSharp.checked = false;
                                    }
                                }
                            }
                        }

                        Rectangle {
                            height: 1 // Adjust the height to control the spacing
                            color: "dimgrey" // Ensure it doesn't affect the layout visually
                            Layout.fillWidth: true
                        }

                        // Layout for individual enharmonic checkboxes
                        ColumnLayout {
                            spacing: 3
                            Layout.fillWidth: true
                            anchors.margins: 100

                            // Repeater for dynamically generating checkboxes
                            Repeater {
                                model: firstColumnPairs
                                delegate: RowLayout {
                                    spacing: 25
                                    Layout.fillWidth: true

                                    // Checkbox for the first column
                                    CheckBox {
                                        id: firstOption
                                        text: modelData[0] + " → " + modelData[1];
                                        Layout.alignment: Qt.AlignLeft
                                        Layout.fillWidth: true
                                        onCheckedChanged: {
                                            if (checked) {
                                                addToList(flatList, [modelData[0], modelData[1]]);
                                                secondOption.checked = false;
                                            } else {
                                                removeFromList(flatList, [modelData[0], modelData[1]]);
                                            }
                                        }
                                        Component.onCompleted: firstColumnCheckBoxes.push(firstOption)
                                    }

                                    // Checkbox for the second column
                                    CheckBox {
                                        id: secondOption
                                        text: secondColumnPairs[index][0] + " → " + secondColumnPairs[index][1];
                                        Layout.alignment: Qt.AlignLeft
                                        Layout.fillWidth: true
                                        onCheckedChanged: {
                                            if (checked) {
                                                addToList(sharpList, [secondColumnPairs[index][0], secondColumnPairs[index][1]]);
                                                firstOption.checked = false;
                                            } else {
                                                removeFromList(sharpList, [secondColumnPairs[index][0], secondColumnPairs[index][1]]);
                                            }
                                        }
                                        Component.onCompleted: secondColumnCheckBoxes.push(secondOption)
                                    }
                                }
                            }
                        }
                    }
                }

                // GroupBox for "Notes" section
                GroupBox {
                    title: "Notes"
                    Layout.fillWidth: true

                    // Layout for the content inside the "Notes" GroupBox
                    ColumnLayout {
                        spacing: 5
                        Layout.fillWidth: true
                        anchors.margins: 100

                        // Row for global checkboxes ("b to #" and "# to b")
                        RowLayout {
                            spacing: 25
                            Layout.fillWidth: true

                            // Left column for "b to #" checkbox
                            CheckBox {
                                id: allBtoSharpNotes
                                text: "All b → #"
                                onCheckedChanged: {
                                    setColumnChecked(firstColumnNoteCheckBoxes, checked);
                                    if (checked) {
                                        allSharpToBNotes.checked = false;
                                    }
                                }
                            }

                            // Right column for "# to b" checkbox
                            CheckBox {
                                id: allSharpToBNotes
                                text: "All # → b"
                                onCheckedChanged: {
                                    setColumnChecked(secondColumnNoteCheckBoxes, checked);
                                    if (checked) {
                                        allBtoSharpNotes.checked = false;
                                    }
                                }
                            }
                        }

                        Rectangle {
                            height: 1 // Adjust the height to control the spacing
                            color: "dimgrey" // Ensure it doesn't affect the layout visually
                            Layout.fillWidth: true
                        }

                        // Layout for individual enharmonic checkboxes
                        ColumnLayout {
                            spacing: 3
                            Layout.fillWidth: true

                            // Repeater for dynamically generating checkboxes
                            Repeater {
                                model: firstColumnPairs
                                delegate: RowLayout {
                                    spacing: 25
                                    Layout.fillWidth: true

                                    // Checkbox for the first column
                                    CheckBox {
                                        id: firstNoteOption
                                        text: modelData[0] + " → " + modelData[1];
                                        Layout.alignment: Qt.AlignLeft
                                        Layout.fillWidth: true
                                        onCheckedChanged: {
                                            if (!checked) allBtoSharpNotes.checked = false;
                                            if (checked) secondNoteOption.checked = false;
                                        }
                                        Component.onCompleted: firstColumnNoteCheckBoxes.push(firstNoteOption)
                                    }

                                    // Checkbox for the second column
                                    CheckBox {
                                        id: secondNoteOption
                                        text: secondColumnPairs[index][0] + " → " + secondColumnPairs[index][1]
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

            // RowLayout for white semitone enharmonics
            RowLayout {
                spacing: 20
                Layout.fillWidth: true

                // GroupBox for "Chords (white semitone enharmonics)"
                GroupBox {
                    title: "Chord symbols"
                    Layout.fillWidth: true          

                    ColumnLayout {
                        spacing: 25
                        Layout.fillWidth: true

                        // Layout for individual enharmonic checkboxes
                        RowLayout {
                            spacing: 25
                            Layout.fillWidth: true

                            // First column
                            ColumnLayout {
                                spacing: 3
                                Layout.fillWidth: true

                                CheckBox {
                                    text: "Cb → B"
                                    checked: true
                                    onCheckedChanged: {
                                        if (checked) {
                                            addToList(flatList, ["Cb", "B"]);
                                        } else {
                                            removeFromList(flatList, ["Cb", "B"]);
                                        }
                                    }
                                }

                                CheckBox {
                                    text: "Fb → E"
                                    checked: true
                                    onCheckedChanged: {
                                        if (checked) {
                                            addToList(flatList, ["Fb", "E"]);
                                        } else {
                                            removeFromList(flatList, ["Fb", "E"]);
                                        }
                                    }
                                }
                            }

                            // Second column
                            ColumnLayout {
                                spacing: 3
                                Layout.fillWidth: true

                                CheckBox {
                                    text: "E# → F"
                                    checked: true
                                    onCheckedChanged: {
                                        if (checked) {
                                            addToList(sharpList, ["E#", "F"]);
                                        } else {
                                            removeFromList(sharpList, ["E#", "F"]);
                                        }
                                    }
                                }

                                CheckBox {
                                    text: "B# → C"
                                    checked: true
                                    onCheckedChanged: {
                                        if (checked) {
                                            addToList(sharpList, ["B#", "C"]);
                                        } else {
                                            removeFromList(sharpList, ["B#", "C"]);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // GroupBox for "Notes (white semitone enharmonics)"
                GroupBox {
                    title: "Notes"
                    Layout.fillWidth: true
                    
                    ColumnLayout {
                        spacing: 0
                        Layout.fillWidth: true

                        // Layout for individual enharmonic checkboxes
                        RowLayout {
                            spacing: 25
                            Layout.fillWidth: true

                            // First column
                            ColumnLayout {
                                spacing: 3
                                Layout.fillWidth: true

                                CheckBox {
                                    text: "Cb → B"
                                    checked: true
                                }

                                CheckBox {
                                    text: "Fb → E"
                                    checked: true
                                }
                            }

                            // Second column
                            ColumnLayout {
                                spacing: 3
                                Layout.fillWidth: true

                                CheckBox {
                                    text: "E# → F"
                                    checked: true
                                }

                                CheckBox {
                                    text: "B# → C"
                                    checked: true
                                }
                            }
                        }
                    }
                }
            }

            // Checkboxes for changing spelling outside of frames
            ColumnLayout {
                spacing: 5
                Layout.alignment: Qt.AlignLeft// Center the checkboxes horizontally

                CheckBox {
                    id: changeChordsSpelling
                    text: "Change chords spelling for ##/bb"
                    checked: true
                }

                CheckBox {
                    id: changeNotesSpelling
                    text: "Change notes spelling for ##/bb"
                    checked: true
                }
            }        
        }

        onAccepted: {
            log("Dialog accepted");

            // check if selection exists. If not – quit
                    if (typeof curScore.selection.elements[0] === 'undefined') {
                        log ("Nothing is selected");
                        (typeof(quit) === 'undefined' ? Qt.quit : quit)();
                    }

                    curScore.startCmd("Enharmonic Replacement");
                    var elCount = 0;

                    while (curScore.selection.elements[elCount]) {

                        var scoreElement = curScore.selection.elements[elCount];

                        // If element is of type HARMONY - replace all the matching extensions with proper formatted ones
                        if (scoreElement.type == Element.HARMONY){
                            
                            var enharmFind = "";
                            var enharmReplace = "";
                            var chordText = scoreElement.text.toString();

                            //check and replace double sharps
                            var i = 0;
                            while ((chordText.search("##") > -1) && (i < doubleSharpList.length)) {

                                    enharmFind = RegExp(doubleSharpList[i][0], 'gi'); //make a regular exppression for a case-insensitive replace call
                                    enharmReplace = doubleSharpList[i][1];

                                    log ("Checking chord " + chordText + " for match: " + doubleSharpList[i][0] + " – " + enharmReplace);        

                                    chordText = chordText.replace(enharmFind, enharmReplace);
                                    scoreElement.text = chordText;

                                    ++i;
                            }
                            
                            // check and replace double flats
                            i = 0;
                            while ((chordText.search("bb") > -1) && (i < doubleFlatList.length)) {

                                    enharmFind = RegExp(doubleFlatList[i][0], 'gi');
                                    enharmReplace = doubleFlatList[i][1];

                                    log ("Checking chord " + chordText + " for match: " + doubleFlatList[i][0] + " – " + enharmReplace);        

                                    chordText = chordText.replace(enharmFind, enharmReplace);
                                    scoreElement.text = chordText;

                                    ++i;
                            }


                            // decide what to check first – flats or sharps

                            //check and replace sharps
                            i = 0;

                            if ((chordText.substr(1,1) == "#" || chordText.substr(chordText.length - 1,1) == "#")) {
                            
                                while (i < sharpList.length) {

                                        enharmFind = RegExp(sharpList[i][0], 'gi');
                                        enharmReplace = sharpList[i][1];

                                        log ("Checking chord " + chordText + " for match: " + sharpList[i][0] + " – " + enharmReplace);        

                                        chordText = chordText.replace(enharmFind, enharmReplace);
                                        scoreElement.text = chordText;

                                        ++i;
                                }

                            //check and replace flats
                            } else if ((chordText.substr(1,1) == "b" || chordText.substr(chordText.length - 1,1) == "b")) {
                                while ((i < flatList.length)) {

                                    enharmFind = RegExp(flatList[i][0], "gi");
                                    enharmReplace = flatList[i][1];

                                    log ("Checking chord " + chordText + " for match: " + flatList[i][0] + " – " + enharmReplace);        

                                    chordText = chordText.replace(enharmFind, enharmReplace, 0);
                                    scoreElement.text = chordText;

                                    ++i;
                                }
                            }                
                        }
                        ++elCount; //next element in the selection
                    }
                        // End the command
                        curScore.endCmd();
                    

            enharmonicDialog.visible = false;
            (typeof(quit) === 'undefined' ? Qt.quit : quit)(); // Version-agnostic quit// Perform any additional actions after acceptancequ
        }

        onRejected: {
            log("Dialog rejected");
            enharmonicDialog.visible = false;
            (typeof(quit) === 'undefined' ? Qt.quit : quit)(); // Version-agnostic quit
        }
    }
}

