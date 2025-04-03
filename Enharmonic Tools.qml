// qmllint disable

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import MuseScore 3.0

MuseScore {
    id: enharmonicTools
    version: "0.3"
    menuPath: "Plugins.Enharmonic Tools.Enharmonic Tools"
    description: "A plugin for managing enharmonic spellings in chords and notes. Author: Konstantin Vlasenko."

    Component.onCompleted: {
        console.log("Enharmonic Tools plugin loaded.");
    }

    property bool debug: false // Global flag to enable or disable logging

    function log(message) {
        if (debug) {
            console.log(message);
        }
    }

    // TPC Matrix for reference
    //   -1: Fbb |  6: Fb | 13: F | 20: F# | 27: F##
    //    0: Cbb |  7: Cb | 14: C | 21: C# | 28: C##
    //    1: Gbb |  8: Gb | 15: G | 22: G# | 29: G##
    //    2: Dbb |  9: Db | 16: D | 23: D# | 30: D##
    //    3: Abb | 10: Ab | 17: A | 24: A# | 31: A##
    //    4: Ebb | 11: Eb | 18: E | 25: E# | 32: E##
    //    5: Bbb | 12: Bb | 19: B | 26: B# | 33: B##


    property var firstColumnPairs: [
        ["Db", "C#", 9],
        ["Eb", "D#", 11],
        ["Gb", "F#", 8],
        ["Ab", "G#", 10],
        ["Bb", "A#", 12]
    ]
    
    property var secondColumnPairs: [
        ["C#", "Db", 21],
        ["D#", "Eb", 23],
        ["F#", "Gb", 20],
        ["G#", "Ab", 22],
        ["A#", "Bb", 24]
    ]

    property var firstColumnCheckBoxesCH: [] // For storing chords checkboxes
    property var secondColumnCheckBoxesCH: [] // For storing chords checkboxes 

    property var firstColumnCheckBoxesNT: []  // For storing notes checkboxes
    property var secondColumnCheckBoxesNT: []  // For storing notes checkboxes

    // Data models for enharmonic pairs (CHORDS)
    property var flatListCH: [
        ["Cb", "B"],
        ["Fb", "E"]
    ]
    property var sharpListCH: [
        ["E#", "F"],
        ["B#", "C"]
    ]
    property var doublesharpListCH: [
        ["C##", "D"],
        ["D##", "E"],
        ["E##", "F#"],
        ["F##", "G"],
        ["G##", "A"],
        ["A##", "B"],
        ["B##", "C#"]
    ]
    property var doubleflatListCH: [
        ["Cbb", "Bb"],
        ["Dbb", "C"],
        ["Ebb", "D"],
        ["Fbb", "Eb"],
        ["Gbb", "F"],
        ["Abb", "G"],
        ["Bbb", "A"]
    ]

    // Data models for enharmonic pairs (NOTES)
    property var flatListNT: [7,6]

    property var sharpListNT: [25,26]



    // Function to add an item to a list
    function addToList(list, item) {
        // Check if the list is a 2D array of strings
        if (Array.isArray(item) && typeof item[0] === "string") {
            list.push(item); // Directly add the pair
            log("Added pair: " + item + " Updated list: " + JSON.stringify(list));
        }
        // Check if the list is a 1D array of numbers
        else if (typeof item === "number") {
            list.push(item); // Directly add the number
            log("Added number: " + item + " Updated list: " + JSON.stringify(list));
        } else {
            log("Invalid item type for addToList: " + item);
        }
    }

    // Function to remove an item from a list
    function removeFromList(list, item) {
        // Check if the list is a 2D array of strings
        if (Array.isArray(item) && typeof item[0] === "string") {
            var index = list.findIndex(function(pair) {
                return pair[0] === item[0] && pair[1] === item[1];
            });
            if (index !== -1) {
                list.splice(index, 1); // Remove the pair
                log("Removed pair: " + item + " Updated list: " + JSON.stringify(list));
            }
        }
        // Check if the list is a 1D array of numbers
        else if (typeof item === "number") {
            var index = list.indexOf(item);
            if (index !== -1) {
                list.splice(index, 1); // Remove the number
                log("Removed number: " + item + " Updated list: " + JSON.stringify(list));
            }
        } else {
            log("Invalid item type for removeFromList: " + item);
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
                                id: globalFlatToSharpCH
                                text: "All b → #"
                                Layout.alignment: Qt.AlignLeft
                                onCheckedChanged: {
                                    setColumnChecked(firstColumnCheckBoxesCH, checked);
                                    if (checked) {
                                        globalSharpToFlatCH.checked = false;
                                    }
                                }
                            }

                            // Right column for "# to b" checkbox
                            CheckBox {
                                id: globalSharpToFlatCH
                                text: "All # → b"
                                Layout.alignment: Qt.AlignRight
                                onCheckedChanged: {
                                    setColumnChecked(secondColumnCheckBoxesCH, checked);
                                    if (checked) {
                                        globalFlatToSharpCH.checked = false;
                                    }
                                }
                            }
                        }

                        // Separator line
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
                                                addToList(flatListCH, [modelData[0], modelData[1]]);
                                                secondOption.checked = false;
                                            } else {
                                                removeFromList(flatListCH, [modelData[0], modelData[1]]);
                                            }
                                        }
                                        Component.onCompleted: firstColumnCheckBoxesCH.push(firstOption)
                                    }

                                    // Checkbox for the second column
                                    CheckBox {
                                        id: secondOption
                                        text: secondColumnPairs[index][0] + " → " + secondColumnPairs[index][1];
                                        Layout.alignment: Qt.AlignLeft
                                        Layout.fillWidth: true
                                        onCheckedChanged: {
                                            if (checked) {
                                                addToList(sharpListCH, [secondColumnPairs[index][0], secondColumnPairs[index][1]]);
                                                firstOption.checked = false;
                                            } else {
                                                removeFromList(sharpListCH, [secondColumnPairs[index][0], secondColumnPairs[index][1]]);
                                            }
                                        }
                                        Component.onCompleted: secondColumnCheckBoxesCH.push(secondOption)
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
                                id: globalFlatToSharpNT
                                text: "All b → #"
                                onCheckedChanged: {
                                    setColumnChecked(firstColumnCheckBoxesNT, checked);
                                    if (checked) {
                                        globalSharpToFlatNT.checked = false;
                                    }
                                }
                            }

                            // Right column for "# to b" checkbox
                            CheckBox {
                                id: globalSharpToFlatNT
                                text: "All # → b"
                                onCheckedChanged: {
                                    setColumnChecked(secondColumnCheckBoxesNT, checked);
                                    if (checked) {
                                        globalFlatToSharpNT.checked = false;
                                    }
                                }
                            }
                        }

                        // Separator line
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
                                            if (!checked) {
                                                removeFromList(flatListNT, modelData[2]);
                                                globalFlatToSharpNT.checked = false;
                                            }
                                            if (checked) {
                                                addToList(flatListNT, modelData[2]);
                                                secondNoteOption.checked = false;
                                            }
                                        }
                                        Component.onCompleted: firstColumnCheckBoxesNT.push(firstNoteOption)
                                    }

                                    // Checkbox for the second column
                                    CheckBox {
                                        id: secondNoteOption
                                        text: secondColumnPairs[index][0] + " → " + secondColumnPairs[index][1]
                                        Layout.alignment: Qt.AlignLeft
                                        Layout.fillWidth: true
                                        onCheckedChanged: {
                                            if (!checked) {
                                                removeFromList(sharpListNT, secondColumnPairs[index][2]);
                                                globalSharpToFlatNT.checked = false;
                                                }
                                            if (checked) {
                                                firstNoteOption.checked = false;
                                                addToList(sharpListNT, secondColumnPairs[index][2]);
                                            }
                                        }
                                        Component.onCompleted: secondColumnCheckBoxesNT.push(secondNoteOption)
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
                                            addToList(flatListCH, ["Cb", "B"]);
                                        } else {
                                            removeFromList(flatListCH, ["Cb", "B"]);
                                        }
                                    }
                                }

                                CheckBox {
                                    text: "Fb → E"
                                    checked: true
                                    onCheckedChanged: {
                                        if (checked) {
                                            addToList(flatListCH, ["Fb", "E"]);
                                        } else {
                                            removeFromList(flatListCH, ["Fb", "E"]);
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
                                            addToList(sharpListCH, ["E#", "F"]);
                                        } else {
                                            removeFromList(sharpListCH, ["E#", "F"]);
                                        }
                                    }
                                }

                                CheckBox {
                                    text: "B# → C"
                                    checked: true
                                    onCheckedChanged: {
                                        if (checked) {
                                            addToList(sharpListCH, ["B#", "C"]);
                                        } else {
                                            removeFromList(sharpListCH, ["B#", "C"]);
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
                                    onCheckedChanged: {
                                        if (checked) {
                                            addToList(flatListNT, 7);
                                        } else {
                                            removeFromList(flatListNT, 7);
                                        }
                                    }
                                }

                                CheckBox {
                                    text: "Fb → E"
                                    checked: true
                                    onCheckedChanged: {
                                        if (checked) {
                                            addToList(flatListNT, 6);
                                        } else {
                                            removeFromList(flatListNT, 6);
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
                                            addToList(sharpListNT, 25);
                                        } else {
                                            removeFromList(sharpListNT, 25);
                                        }
                                    }
                                }

                                CheckBox {
                                    text: "B# → C"
                                    checked: true
                                    onCheckedChanged: {
                                        if (checked) {
                                            addToList(sharpListNT, 26);
                                        } else {
                                            removeFromList(sharpListNT, 26);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Checkboxes for changing spelling of double accidentals
            ColumnLayout {
                spacing: 5
                Layout.alignment: Qt.AlignLeft

                CheckBox {
                    id: doubleAccidentalsCheckCH
                    text: "Change chords spelling for ##/bb"
                    checked: true
                }

                CheckBox {
                    id: doubleAccidentalsCheckNT
                    text: "Change notes spelling for ##/bb"
                    checked: true
                }
            }        
        }

        onRejected: {
            log("Dialog rejected");
            enharmonicDialog.visible = false;
            (typeof(quit) === 'undefined' ? Qt.quit : quit)(); // Version-agnostic quit
        }

        onAccepted: {
            // check if selection exists. If not – quit
                    if (typeof curScore.selection.elements[0] === 'undefined') {
                        log ("Nothing is selected");
                        (typeof(quit) === 'undefined' ? Qt.quit : quit)();
                    }

                    curScore.startCmd("Enharmonic Replacement");
                    var elCount = 0;

                    while (curScore.selection.elements[elCount]) {

                        var scoreElement = curScore.selection.elements[elCount];

                        // If element is of type HARMONY - respell chords
                        if (scoreElement.type == Element.HARMONY){
                            
                            var enharmFind = "";
                            var enharmReplace = "";
                            var chordText = scoreElement.text.toString();

                            //check and replace double sharps
                            var i = 0;
                            while ((chordText.search("##") > -1) && (i < doublesharpListCH.length)) {

                                    enharmFind = RegExp(doublesharpListCH[i][0], 'gi'); //make a regular exppression for a case-insensitive replace call
                                    enharmReplace = doublesharpListCH[i][1];

                                    log ("Checking chord " + chordText + " for match: " + doublesharpListCH[i][0] + " – " + enharmReplace);        

                                    chordText = chordText.replace(enharmFind, enharmReplace);
                                    scoreElement.text = chordText;

                                    ++i;
                            }
                            
                            // check and replace double flats
                            i = 0;
                            while ((chordText.search("bb") > -1) && (i < doubleflatListCH.length)) {

                                    enharmFind = RegExp(doubleflatListCH[i][0], 'gi');
                                    enharmReplace = doubleflatListCH[i][1];

                                    log ("Checking chord " + chordText + " for match: " + doubleflatListCH[i][0] + " – " + enharmReplace);        

                                    chordText = chordText.replace(enharmFind, enharmReplace);
                                    scoreElement.text = chordText;

                                    ++i;
                            }


                            // decide what to check first – flats or sharps

                            //check and replace sharps
                            i = 0;

                            if ((chordText.substr(1,1) == "#" || chordText.substr(chordText.length - 1,1) == "#")) {
                            
                                while (i < sharpListCH.length) {

                                        enharmFind = RegExp(sharpListCH[i][0], 'gi');
                                        enharmReplace = sharpListCH[i][1];

                                        log ("Checking chord " + chordText + " for match: " + sharpListCH[i][0] + " – " + enharmReplace);        

                                        chordText = chordText.replace(enharmFind, enharmReplace);
                                        scoreElement.text = chordText;

                                        ++i;
                                }

                            //check and replace flats
                            } else if ((chordText.substr(1,1) == "b" || chordText.substr(chordText.length - 1,1) == "b")) {
                                while ((i < flatListCH.length)) {

                                    enharmFind = RegExp(flatListCH[i][0], "gi");
                                    enharmReplace = flatListCH[i][1];

                                    log ("Checking chord " + chordText + " for match: " + flatListCH[i][0] + " – " + enharmReplace);        

                                    chordText = chordText.replace(enharmFind, enharmReplace, 0);
                                    scoreElement.text = chordText;

                                    ++i;
                                }
                            }                
                        } else if (scoreElement.type == Element.NOTE) { // If element is of type NOTE - respell  notes
                            var note = scoreElement;

                            if (doubleAccidentalsCheckNT.checked == true){
                                if (scoreElement.tpc >= -1 && scoreElement.tpc <= 5) { //Check for doubleFlats
                                    scoreElement.tpc = scoreElement.tpc + 12;
                                } else if (scoreElement.tpc >= 27 && scoreElement.tpc <= 33) { //Check for doubleSharps
                                    scoreElement.tpc = scoreElement.tpc - 12;
                                }
                            }

                            if ((scoreElement.tpc >= 6 && scoreElement.tpc <= 12) && (flatListNT.indexOf(scoreElement.tpc) !== -1)) { //Check for flats
                                scoreElement.tpc = scoreElement.tpc + 12;
                            } else if ((scoreElement.tpc >= 20 && scoreElement.tpc <= 26) && (sharpListNT.indexOf(scoreElement.tpc) !== -1)) { //Check for sharps
                                scoreElement.tpc = scoreElement.tpc - 12;
                            }
                        }
                    //next element in the selection
                    ++elCount;
                    }


                    // End the command
                    curScore.endCmd();
                    

                    enharmonicDialog.visible = false;
                    (typeof(quit) === 'undefined' ? Qt.quit : quit)(); // Version-agnostic quit
        }
    }
}