import httpclient
import terminal
import tables
import os

# Hopefully reliable places on the internet to get corpuses from.
const corpusLocations = {
    "brown": "http://www.sls.hawaii.edu/bley-vroman/brown.txt"
}.toTable

# Fetches a corpus either from the local cache or online.
proc fetchCorpus*(name: string): string =
    let location = getHomeDir() / ".tomeData" / name & ".txt"
    
    if not fileExists(location):
        createDir(location.splitPath().head)
        stdout.styledWriteLine(styleBright, fgCyan, "[INFO] ", resetStyle, fgWhite, "Corpus not found in cache, trying to download...")

        if corpusLocations.hasKey(name):
            stdout.styledWriteLine(styleBright, fgCyan, "[INFO] ", resetStyle, fgWhite, "Downloading...")

            let client = newHttpClient()
            writeFile(location, client.getContent(corpusLocations[name]))
            
            stdout.styledWriteLine(styleBright, fgGreen, "[INFO] ", resetStyle, fgWhite, "Complete!")

        else:
            raise newException(IOError, "Couldn't find the requested corpus :(")

    return readFile(location)
