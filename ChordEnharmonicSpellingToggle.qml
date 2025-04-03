import MuseScore 3.0
import QtQuick 2.9

MuseScore {
    menuPath: "Plugins.Enharmonic Tools.Toggle Enharmonic Spelling For A Chord"
    description: "This plugin toggles enharmonic spelling for chord symbols"
    id: chordEnharmonicSpellingToggle
    version: "0.2"

    Component.onCompleted: {
        // Automatically load the plugin when MuseScore starts
        console.log("Toggle Enharmonic Spelling For A Chord plugin loaded.");
    }

    onRun: {

        var doubleSharpList = [
            ["C##", "D"],
            ["D##", "E"],
            ["E##", "F#"],
            ["F##", "G"],
            ["G##", "A"],
            ["A##", "B"],
            ["B##", "C#"],
        ];

        var doubleFlatList = [
            ["Cbb", "Bb"],
            ["Dbb", "C"],
            ["Ebb", "D"],
            ["Fbb", "Eb"],
            ["Gbb", "F"],
            ["Abb", "G"],
            ["Bbb", "A"],
        ];


        var flatList = [
            ["Cb", "B"],
            ["Db", "C#"],
            ["Eb", "D#"],
            ["Fb", "E"],
            ["Gb", "F#"],
            ["Ab", "G#"],
            ["Bb", "A#"],
        ];

        var sharpList = [
            ["C#", "Db"],
            ["D#", "Eb"],
            ["E#", "F"],
            ["F#", "Gb"],
            ["G#", "Ab"],
            ["A#", "Bb"],
            ["B#", "C"],
        ];

        // check if selection exists. If not – quit
        if (typeof curScore.selection.elements[0] === 'undefined') {
            console.log ("Nothing is selected");
            (typeof(quit) === 'undefined' ? Qt.quit : quit)();
        }

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

                        console.log ("Checking chord " + chordText + " for match: " + doubleSharpList[i][0] + " – " + enharmReplace);        

                        chordText = chordText.replace(enharmFind, enharmReplace);
                        scoreElement.text = chordText;

                        ++i;
                }
                
                // check and replace double flats
                i = 0;
                while ((chordText.search("bb") > -1) && (i < doubleFlatList.length)) {

                        enharmFind = RegExp(doubleFlatList[i][0], 'gi');
                        enharmReplace = doubleFlatList[i][1];

                        console.log ("Checking chord " + chordText + " for match: " + doubleFlatList[i][0] + " – " + enharmReplace);        

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

                            console.log ("Checking chord " + chordText + " for match: " + sharpList[i][0] + " – " + enharmReplace);        

                            chordText = chordText.replace(enharmFind, enharmReplace);
                            scoreElement.text = chordText;

                            ++i;
                    }

                //check and replace flats
                } else if ((chordText.substr(1,1) == "b" || chordText.substr(chordText.length - 1,1) == "b")) {
                    while ((i < flatList.length)) {

                        enharmFind = RegExp(flatList[i][0], "gi");
                        enharmReplace = flatList[i][1];

                        console.log ("Checking chord " + chordText + " for match: " + flatList[i][0] + " – " + enharmReplace);        

                        chordText = chordText.replace(enharmFind, enharmReplace, 0);
                        scoreElement.text = chordText;

                        ++i;
                    }
                }                
            }
            ++elCount; //next element in the selection
        }

        (typeof(quit) === 'undefined' ? Qt.quit : quit)();
    }
}