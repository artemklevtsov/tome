import tables

# Types for convenience.
type 
    Feature* = tuple[name, value: string]
    Weights* = Table[Feature, Table[string, int]]

# Predicts the class of an example from a set of features and the weights.
proc predict*(weights: Weights, features: seq[Feature]): string =
    var
        scores: Table[string, int]
        bestScore: int
        best: string
    
    for feature in features:
        if weights.hasKey(feature):
            
            for class, value in pairs(weights[feature]):
                scores.mgetOrPut(class, 0) += value

                let score = scores[class]
                if score > bestScore:
                    bestScore = score
                    best = class
    
    return best

# Performs one fit step given training examples.
proc fit*(weights: var Weights, examples: seq[tuple[features: seq[Feature], class: string]]): float =
    var correct = 0
    for example in examples:

        let guess = weights.predict(example.features)
        if guess != example.class:

            for feature in example.features:

                # Add one to helpful weights, subtract from unhelpful.
                var tmp: Table[string, int]
                weights.mgetOrPut(feature, tmp).mgetOrPut(guess, 0) -= 1
                weights.mgetOrPut(feature, tmp).mgetOrPut(example.class, 0) += 1
        else:
            correct += 1
    
    return correct.float / examples.len.float