## Usage
# ./train-infer-mallet.sh NAME NUMTOPICS
# Where:
# NAME - the name of the work as saved in /tmp/train-{{NAME}}.txt
# NUMTOPICS - the number of topics to build the model for

NAME=$1
NUM_TOPICS=$2
#MALLET_HOME=mallet-2.0.7
: ${MALLET_HOME:?"Need to set MALLET_HOME before running this script. e.g. export MALLET_HOME=/mallet-2.0.7"}
exit
TRAIN=tmp/train-$NAME.txt
INFER=tmp/infer-$NAME.txt

### Index single-page docs (training) for Mallet
$MALLET_HOME/bin/mallet import-file --input $TRAIN \
       	--output tmp/singlepage.mallet \
	--remove-stopwords --keep-sequence TRUE

# Keep-sequence TRUE is a false assumption but necessary to run for programmatic reasons. LDA assumes conditional independence between features.


### Index sliding-frame docs (inference) for Mallet
$MALLET_HOME/bin/mallet import-file --input $INFER \
       	--output tmp/slidingframe.mallet \
	--remove-stopwords --keep-sequence TRUE \
	--use-pipe-from tmp/singlepage.mallet

# It is important to use --use-pipe-from with the single-page mallet, so the inferencer will be compatible.


### Train topics and save inferencer
$MALLET_HOME/bin/mallet train-topics --input tmp/singlepage.mallet \
       	--num-topics $NUM_TOPICS --output-topic-keys tmp/topic_keys.txt \
	--optimize-interval 20 --num-iterations 3500 \
	--inferencer-filename tmp/book.inferencer

# Note that the --num-iterations in this example is quite high, it can be removed or set to the default of 1000. Watch when the log-likelihood goes down.


### Infer topics for sliding page frame
$MALLET_HOME/bin/mallet infer-topics \
	--inferencer tmp/book.inferencer \
	--input tmp/slidingframe.mallet \
	--output-doc-topics tmp/inferred-pageframe-topics.txt
