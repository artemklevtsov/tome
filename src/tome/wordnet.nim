import httpclient
import strutils
import terminal
import tables
import untar
import os

import tagger

type WordNet* = object
    version*: string
    location*: string

const wordNetURL = "http://wordnetcode.princeton.edu/3.0/WNdb-3.0.tar.gz"

# Downloads wordnet.
proc fetchWordNet*(): WordNet =
    result.version = "3.0"
    result.location = getHomeDir() / ".tomeData" / "wordnet"
    
    if not dirExists(result.location):
        stdout.styledWriteLine(styleBright, fgCyan, "[INFO] ", resetStyle, fgWhite, "WordNet not found in cache, downloading...")

        let client = newHttpClient()
        let dLoc = getTempDir() / "wordnet.tar.gz"
        writeFile(dLoc, client.getContent(wordNetURL))

        # Extract.
        createDir(result.location)
        newTarFile(dLoc).extract(result.location)
        
        stdout.styledWriteLine(styleBright, fgGreen, "[INFO] ", resetStyle, fgWhite, "Complete!")

# Get the synonyms for a word in chosen categories.
proc getSyns*(wn: WordNet, word: string, searchIn: openArray[string] = ["adj", "adv", "noun", "verb"]): seq[string] =
    
    for wt in searchIn:

        # Find word location in an index file.
        let 
            iText = readFile(wn.location / "index." & wt)
            loc = iText.find("\n" & word & " ")
        
        if loc != -1:

            # Find all the sets the word is in.
            let 
                line = iText[loc+1..^1].split("\n", 1)[0].split(" ")
                nPointers = parseInt(line[3])
                sets = line[nPointers+6..^3]
            
            # Find all other words in those sets and add them to the list.
            for s in sets:
                for i in iText.split(s):

                    let r = i.rsplit("\n", 1)[^1].split(" ", 1)[0]
                    if r notin result & word & "":
                        result.add(r)

# Get synonyms for a taged token.
proc getSyns*(wn: WordNet, token: Tagged): seq[string] =
    var searchIn: seq[string]

    if token.tag[0] == 'J':
        searchIn = @["adj"]

    elif token.tag[0] == 'V':
        searchIn = @["verb"]
    
    elif token.tag[0..1] == "RB":
        searchIn = @["adv"]
    
    elif token.tag[0] == 'N' and 'P' notin token.tag:
        searchIn = @["noun"]
    
    if searchIn.len > 0:
        result = wn.getSyns(token.text, searchIn)