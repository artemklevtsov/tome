# tome

*A natural language library for Nim.*

```Nim
import tome

const text = """
There should be one and only one
programming language for everything. 
That language is Nim.
"""

let tokens = tokenize text

let tagger = fetchTagger "en"
echo tagger.posTag(tokens)
```

```
@[(text: "There", tag: "EX"), (text: "should", tag: "MD"), (text: "be", tag: "VB"), (text: "one", tag: "CD"), (text: "and", tag: "CC"), (text: "only", tag: "RB"), (text: "one", tag: "CD"), (text: "programming", tag: "NN"), (text: "language", tag: "NN"), (text: "for", tag: "IN"), (text: "everything", tag: "NN"), (text: ".", tag: "."), (text: "That", tag: "IN"), (text: "language", tag: "NN"), (text: "is", tag: "VBZ"), (text: "Nim", tag: "NNP"), (text: ".", tag: ".")]
```

## Features

- [x] Tokenization
- [x] Parts of Speech (POS) tagging
- [ ] Word2Vec

## Languages

- [x] English
- [ ] *please contribute...*

Training a POS tagger for a new language should be trivial once we have a working tokenizer for it. The English tokenizer should work OK but not great for many other languages. Open an issue if you want support for your language.