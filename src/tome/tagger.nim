import terminal
import strutils
import marshal
import tables

import perceptron

type Tagged* = tuple[text, tag: string]

# Gets various features used by the tagger. Maybe in future this can be part of the tagger?
proc getFeatures(token, tokenBefore, tokenAfter: string, classBefore: string): seq[Feature] =

    # Whole tokens.
    result.add(("token", token.toLowerAscii()))
    result.add(("tokenBefore", tokenBefore.toLowerAscii()))
    result.add(("tokenAfter", tokenAfter.toLowerAscii()))

    # The suffix of the target token.
    try:
        result.add(("suffix", token[^3..^1].toLowerAscii()))
    except:
        discard
    
    # Info about the first letter of the target token.
    result.add(("pref", $token[0].toLowerAscii()))
    result.add(("isUpper", $isUpperAscii(token[0])))

    # The class of the token before.
    result.add(("classBefore", classBefore))

# Trains a tagger. More or less wraps the fit proc.
proc trainTagger*(tokens: seq[Tagged], nIter: int): Weights =
    var examples: seq[tuple[features: seq[Feature], class: string]]
    for index, token in tokens:

        # Find the token before.
        var tBefore: Tagged
        if index == 0:
            tBefore = (text: "", tag: "")
        else:
            tBefore = tokens[index-1]
        
        # Find the token after.
        var tAfter: Tagged
        if index == len(tokens)-1:
            tAfter = (text: "", tag: "")
        else:
            tAfter = tokens[index+1]
        
        # Hand all the context to the feature getter.
        examples.add((features: getFeatures(token.text, tBefore.text, tAfter.text, tBefore.tag), class: token.tag))
    
    # Iteritively fit.
    for iter in 0..<nIter:
        let accuracy = result.fit(examples)
        stdout.styledWriteLine(styleBright, fgGreen, "[INFO] ", fgWhite, "Accuracy: ", $accuracy)

# Tag a sequence of tokens.
proc posTag*(weights: Weights, tokens: seq[string]): seq[Tagged] =
    for index, token in tokens:

        # Get token and class before.
        var tBefore: string
        var classBefore: string
        if index == 0:
            tBefore = ""
            classBefore = ""
        else:
            tBefore = tokens[index-1]

            # Class before is previously predicted.
            classBefore = result[index-1].tag
        
        # Get token after.
        var tAfter: string
        if index == len(tokens)-1:
            tAfter = ""
        else:
            tAfter = tokens[index+1]

        # Predict and add to the sequence.
        let class = weights.predict(getFeatures(token, tBefore, tAfter, classBefore))
        result.add((text: token, tag: class))

# Saves a tagger as JSON. Makes very large files.
proc save*(weights: Weights, fn: string) =
    writeFile(fn, $$weights)

# Loads a tagger from JSON.
proc loadTagger*(fn: string): Weights =
    return to[Weights](readFile(fn))