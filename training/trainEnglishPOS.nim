import zip/zipfiles
import strutils
import marshal
import streams

import tome
import tome/tagger

var 
    tokens: seq[Tagged]

let lines = readFile("training/data/ud-treebanks-v2.9/UD_English-GUM/en_gum-ud-train.conllu").split("\n")
for index, i in lines:
    if i.len > 0 and i[0] != '#':

        let
            cols = i.split(Whitespace)
            word = cols[1]
            pos = cols[4]
        
        tokens.add((text: word, tag: pos))

let json = $$trainTagger(tokens, 10)
writeFile("training/data/en.json", json)

var z: ZipArchive
if z.open("training/data/en.zip", fmWrite):
    z.addFile("en.json", newStringStream(json))
    z.close()