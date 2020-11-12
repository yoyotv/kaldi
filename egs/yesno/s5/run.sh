#!/usr/bin/env bash

# Setting the command of training and decoding.
train_cmd="utils/run.pl"    
decode_cmd="utils/run.pl"

# If directory waves_yesno does not exsit, then download the data from the internet source or exit 1 if anything went wrong.
# Thena inzip the data.
if [ ! -d waves_yesno ]; then
  wget http://www.openslr.org/resources/1/waves_yesno.tar.gz || exit 1;
  # was:
  # wget http://sourceforge.net/projects/kaldi/files/waves_yesno.tar.gz || exit 1;
  tar -xvzf waves_yesno.tar.gz || exit 1;
fi

train_yesno=train_yesno
test_base_name=test_yesno

# Remove previous data
rm -rf data exp mfcc

# Data preparation #####################

local/prepare_data.sh waves_yesno   # prepare data, including training and testing data.
local/prepare_dict.sh               # prepare dictionary (lexicon), and essential files.

# Parse "extra_questions.txt  lexicon.txt nonsilence_phones.txt  optional_silence.txt  silence_phones.txt" these five files that local/prepare_dict.sh prepared to generate langauge directory.
# utils/prepare_lang.sh Line 21 and 79. 
utils/prepare_lang.sh --position-dependent-phones false data/local/dict "<SIL>" data/local/lang data/lang 
local/prepare_lm.sh                 # Prepare language model, and convert arpabo to FST.
#########################################

# Feature extraction
for x in train_yesno test_yesno; do 
 steps/make_mfcc.sh --nj 1 data/$x exp/make_mfcc/$x mfcc
 steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x mfcc
 utils/fix_data_dir.sh data/$x
done

# Mono training
steps/train_mono.sh --nj 1 --cmd "$train_cmd" \
  --totgauss 400 \
  data/train_yesno data/lang exp/mono0a 
  
# Graph compilation  
utils/mkgraph.sh data/lang_test_tg exp/mono0a exp/mono0a/graph_tgpr

# Decoding
steps/decode.sh --nj 1 --cmd "$decode_cmd" \
    exp/mono0a/graph_tgpr data/test_yesno exp/mono0a/decode_test_yesno

for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done
