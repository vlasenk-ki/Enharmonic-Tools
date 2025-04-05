// qmllint disable

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import MuseScore 3.0

MuseScore {
    id: enharmonicTools
    version: "1.0"
    menuPath: "Plugins.Enharmonic Tools.Enharmonic Tools"
    description: "A plugin for managing enharmonic spellings in chords and notes. Author: Konstantin Vlasenko."

    Component.onCompleted: {
        console.log("Enharmonic Tools plugin loaded.");
    }

    property bool debug: true // Global flag to enable or disable logging

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

    property var tpcMatrix: [
        { tpc: -1, note: "Fbb" },
        { tpc: 0, note: "Cbb" },
        { tpc: 1, note: "Gbb" },
        { tpc: 2, note: "Dbb" },
        { tpc: 3, note: "Abb" },
        { tpc: 4, note: "Ebb" },
        { tpc: 5, note: "Bbb" },
        { tpc: 6, note: "Fb" },
        { tpc: 7, note: "Cb" },
        { tpc: 8, note: "Gb" },
        { tpc: 9, note: "Db" },
        { tpc: 10, note: "Ab" },
        { tpc: 11, note: "Eb" },
        { tpc: 12, note: "Bb" },
        { tpc: 13, note: "F" },
        { tpc: 14, note: "C" },
        { tpc: 15, note: "G" },
        { tpc: 16, note: "D" },
        { tpc: 17, note: "A" },
        { tpc: 18, note: "E" },
        { tpc: 19, note: "B" },
        { tpc: 20, note: "F#" },
        { tpc: 21, note: "C#" },
        { tpc: 22, note: "G#" },
        { tpc: 23, note: "D#" },
        { tpc: 24, note: "A#" },
        { tpc: 25, note: "E#" },
        { tpc: 26, note: "B#" },
        { tpc: 27, note: "F##" },
        { tpc: 28, note: "C##" },
        { tpc: 29, note: "G##" },
        { tpc: 30, note: "D##" },
        { tpc: 31, note: "A##" },
        { tpc: 32, note: "E##" },
        { tpc: 33, note: "B##" }
    ]

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
    property var flatListCH: [7,6]
    property var sharpListCH: [25,26]

    // Data models for enharmonic pairs (NOTES)
    property var flatListNT: [7,6]
    property var sharpListNT: [25,26]

    // Split the chord into main chord and bass note
    function splitChord(chordText) {
        
        var chordParts = chordText.split("/");
        var mainChord = chordParts[0]; // Main chord (e.g., "Cb7b9")
        var bass = chordParts.length > 1 ? chordParts[1] : ""; // Bass note (e.g., "Gb")

        // Extract the root and extension from the main chord
        var rootMatch = mainChord.match(/^[A-Ga-g][#b]{0,2}/); // Match root (e.g., "Cb", "C#", "F##")
        var root = rootMatch ? rootMatch[0] : ""; // Extract root
        var extension = mainChord.slice(root.length); // Remaining part is the extension (e.g., "7b9")

        // Return the parts
        return {
            mainChord: mainChord,
            bass: bass,
            root: root,
            extension: extension,
        };
    }

    function reassembleChord(root, extension, bass) {
        var chordText = bass ? root + extension + "/" + bass : root + extension;
        log("Reassembled chord: " + chordText);
        return chordText;
    }

    function getNoteByTPC(tpc) {
        var entry = tpcMatrix.find(function(item) {
            return item.tpc === tpc;
        });
        
        return entry ? entry.note : null; // Return the note name or null if not found
    }

    function getTPCByNote(note) {
        var entry = tpcMatrix.find(function(item) {
            return item.note === note;
        });

        return entry ? entry.tpc : null; // Return the TPC number or null if not found
    }

    function changeTPCdoubleAcc (tpc, doubleAccChecked) {
        if (tpc === null) {
            return tpc; // Return as is if TPC is null
        }
        if (doubleAccChecked) {
            if (tpc >= -1 && tpc <= 5) { // Check for double flats
                tpc += 12;
            } else if (tpc >= 27 && tpc <= 33) { // Check for double sharps
                tpc -= 12;
            }
        }
        return tpc;
    }

    function changeTPCsingleAcc (tpc, flatList, sharpList) {
        if ((tpc >= 6 && tpc <= 12) && (flatList.indexOf(tpc) !== -1)) { //Check for flats
            tpc += 12;
        } else if ((tpc >= 20 && tpc <= 26) && (sharpList.indexOf(tpc) !== -1)) { //Check for sharps
            tpc -= 12;
        }
        return tpc;
    }
    
    // Function to add an item to a list
    function addToList(list, item) {
            list.push(item);
            log("Added TPC: " + item + " Updated list: " + JSON.stringify(list));
    }

    // Function to remove an item from a list
    function removeFromList(list, item) {
        var index = list.indexOf(item);
        if (index !== -1) {
            list.splice(index, 1);
            log("Removed TPC: " + item + " Updated list: " + JSON.stringify(list));
        } else {
            log("TPC " + item + " is not in the list.");
        }
    }
    
    // Function to handle checkbox changes
    function handleCheckboxChange(checked, list, item, otherCheckbox) {
        if (checked) {
            addToList(list, item); // Add the item to the list
            if (otherCheckbox) {
                otherCheckbox.checked = false; // Uncheck the other checkbox if provided
            }
        } else {
            removeFromList(list, item); // Remove the item from the list
        }
    }

    // Function to set the checked state of a column of checkboxes
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
            modality: Qt.ApplicationModal
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
                            height: 1
                            color: "dimgrey"
                            Layout.fillWidth: true
                        }

                        // Layout for individual enharmonic checkboxes
                        ColumnLayout {
                            spacing: 3
                            Layout.fillWidth: true
                            anchors.margins: 100
                            
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
                                            handleCheckboxChange(checked, flatListCH, modelData[2], secondOption);
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
                                            handleCheckboxChange(checked, sharpListCH, secondColumnPairs[index][2], firstOption);
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
                            height: 1
                            color: "dimgrey"
                            Layout.fillWidth: true
                        }

                        // Layout for individual enharmonic checkboxes
                        ColumnLayout {
                            spacing: 3
                            Layout.fillWidth: true
                           
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
                                            handleCheckboxChange(checked, flatListNT, modelData[2], secondNoteOption);
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
                                            handleCheckboxChange(checked, sharpListNT, secondColumnPairs[index][2], firstNoteOption);
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
                
                GroupBox {
                    title: "Chord symbols"
                    Layout.fillWidth: true          

                    ColumnLayout {
                        spacing: 25
                        Layout.fillWidth: true
                        
                        RowLayout {
                            spacing: 25
                            Layout.fillWidth: true
                            
                            ColumnLayout {
                                spacing: 3
                                Layout.fillWidth: true

                                CheckBox {
                                    text: "Cb → B"
                                    checked: true
                                    onCheckedChanged: handleCheckboxChange(checked, flatListCH, 7);
                                }

                                CheckBox {
                                    text: "Fb → E"
                                    checked: true
                                    onCheckedChanged: handleCheckboxChange(checked, flatListCH, 6);
                                }
                            }
                            
                            ColumnLayout {
                                spacing: 3
                                Layout.fillWidth: true

                                CheckBox {
                                    text: "E# → F"
                                    checked: true
                                    onCheckedChanged: handleCheckboxChange(checked, sharpListCH, 25);
                                }

                                CheckBox {
                                    text: "B# → C"
                                    checked: true
                                    onCheckedChanged: handleCheckboxChange(checked, sharpListCH, 26);
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
                                    onCheckedChanged: handleCheckboxChange(checked, flatListNT, 7);
                                }

                                CheckBox {
                                    text: "Fb → E"
                                    checked: true
                                    onCheckedChanged: handleCheckboxChange(checked, flatListNT, 6);
                                }
                            }

                            // Second column
                            ColumnLayout {
                                spacing: 3
                                Layout.fillWidth: true

                                CheckBox {
                                    text: "E# → F"
                                    checked: true
                                    onCheckedChanged: handleCheckboxChange(checked, sharpListNT, 25);
                                }

                                CheckBox {
                                    text: "B# → C"
                                    checked: true
                                    onCheckedChanged: handleCheckboxChange(checked, sharpListNT, 26);
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
                                                        
                            var chordParts = splitChord(scoreElement.text)
                            var chordRoot = chordParts.root;
                            var chordExtension = chordParts.extension;
                            var chordBass = chordParts.bass;

                            log("Chord root: " + chordRoot);
                            log("Chord extension: " + chordExtension);
                            log("Chord bass: " + chordBass);

                            var chordRootTPC = getTPCByNote(chordRoot);
                            var chordBassTPC = getTPCByNote(chordBass);

                            log("Root: " + chordRoot + " TPC:" + getTPCByNote(chordRoot));
                            log("Extension: " + chordExtension);
                            log("Bass: " + chordBass + " TPC:" + getTPCByNote(chordBass));
                            
                            chordRootTPC = changeTPCdoubleAcc(chordRootTPC,doubleAccidentalsCheckCH.checked);
                            chordBassTPC = changeTPCdoubleAcc(chordBassTPC,doubleAccidentalsCheckCH.checked);

                            log("Root TPC after double accidental check: " + chordRootTPC);
                            log("Bass TPC after double accidental check: " + chordBassTPC);

                            chordRootTPC = changeTPCsingleAcc(chordRootTPC, flatListCH, sharpListCH);
                            chordBassTPC = changeTPCsingleAcc(chordBassTPC, flatListCH, sharpListCH);

                            log("Root TPC after single accidental check: " + chordRootTPC);
                            log("Bass TPC after single accidental check: " + chordBassTPC);

                            var chordRoot = getNoteByTPC(chordRootTPC);
                            var chordBass = getNoteByTPC(chordBassTPC);

                            log("Root after TPC check: " + chordRoot);
                            log("Bass after TPC check: " + chordBass);

                            scoreElement.text = reassembleChord(chordRoot, chordExtension, chordBass);                        
                        
                        // If element is of type NOTE - respell  notes
                        } else if (scoreElement.type == Element.NOTE) { 

                            scoreElement.tpc = changeTPCdoubleAcc(scoreElement.tpc,doubleAccidentalsCheckNT.checked);
                            scoreElement.tpc = changeTPCsingleAcc(scoreElement.tpc, flatListNT, sharpListNT);
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