#!/usr/bin/env bash

mkdir -p data/local/dict

# copy lexicon without silence phone. (for prepare_lang.sh)
cp input/lexicon_nosil.txt data/local/dict/lexicon_words.txt

# copy lexicon with silence phone. (for prepare_lang.sh)
cp input/lexicon.txt data/local/dict/lexicon.txt

# grep (search) for lines mismatch "SIL" in input/phones.txt then input into data/local/dict/nonsilence_phones.txt. (for prepare_lang.sh)
cat input/phones.txt | grep -v SIL > data/local/dict/nonsilence_phones.txt

# Create silence_phones.txt. (for prepare_lang.sh)
echo "SIL" > data/local/dict/silence_phones.txt

# Create optional_silence.txt. (for prepare_lang.sh)
echo "SIL" > data/local/dict/optional_silence.txt

echo "Dictionary preparation succeeded"
