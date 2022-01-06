import strutils

# Creates a sequence of tokens from a source string.
proc tokenize*(sourceText: string): seq[string] =
    var tokenText: string
    var ready = sourceText.replace("\n", " ") & "\t"

    for i in ["'ll ", "'re ", "'ve ", "n't "]:
        ready = ready.replace(i, " " & i)

    for index, c in ready:

        # Always add a new token on whitespace.
        if c in Whitespace and tokenText.len > 0:
            result.add(tokenText)
            tokenText = ""

        # Handle punctuation.
        elif c notin Whitespace + Letters:
            if c == '\'':
                if tokenText.len > 2:
                    result.add(tokenText)
                    tokenText = ""
                tokenText &= c
            else:
                if tokenText.len > 0:
                    result.add(tokenText)
                    tokenText = ""
                result.add($c)
        
        # Add to the current token.
        elif c notin Whitespace:
            tokenText &= c
    