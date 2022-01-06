import zip/zipfiles
import httpclient
import terminal
import marshal
import streams
import tables
import os

import perceptron

# For now the pretrained taggers are stored on the Internet Archive (all hail).
# Returns Penn-Treebank tags.
const taggerLocations = {
    "en": "http://archive.org/download/tomeTaggers/en.zip"
}.toTable

# Fetch a tagger and unzip it.
proc fetchTagger*(name: string): Weights =
    let location = getHomeDir() / ".tomeData" / name & ".json"
    
    if not fileExists(location):
        createDir(location.splitPath().head)
        stdout.styledWriteLine(styleBright, fgCyan, "[INFO] ", resetStyle, fgWhite, "Tagger not found in cache, trying to download...")

        if taggerLocations.hasKey(name):
            stdout.styledWriteLine(styleBright, fgCyan, "[INFO] ", resetStyle, fgWhite, "Downloading...")

            let dLoc = getTempDir() / name & ".zip"
            let client = newHttpClient()
            writeFile(dLoc, client.getContent(taggerLocations[name]))
            
            # Unzip.
            var z: ZipArchive
            if z.open(dLoc, fmRead):
                let outStream = newStringStream("")
                z.extractFile(name & ".json", outStream)
                writeFile(location, outStream.data)

            stdout.styledWriteLine(styleBright, fgGreen, "[INFO] ", resetStyle, fgWhite, "Complete!")

        else:
            raise newException(IOError, "Couldn't find the requested tagger :(")
    
    return to[Weights](readFile(location))