import unittest

import tome

test "Tokenize":
    assert tokenize("This isn't just a test.")[1] == "is"

test "Tag":
    let tagger = fetchTagger "en"
    assert tagger.posTag(tokenize("It is fast."))[2].tag == "ADJ"
