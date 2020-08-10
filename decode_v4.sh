#cuda_flags="--cuda-use-tensor-cores=true 
#--iterations=10 --cuda-memory-proportion=.5 
#--max-batch-size=32 --cuda-worker-threads=2"

LOCAL_RESULT_PATH=out
KALDI_ROOT=`pwd`/kaldi
LOG_FILE="$LOCAL_RESULT_PATH/output.log"
MODEL=model/vosk-model-en-us-aspire-0.2

#mkdir -p $LOCAL_RESULT_PATH
#rm -rf $LOCAL_RESULT_PATH
#mkdir $LOCAL_RESULT_PATH

#$KALDI_ROOT/src/cudadecoderbin/batched-wav-nnet3-cuda2 $cuda_flags \
#	  --frame-subsampling-factor=3 \
#	  --frames-per-chunk=51 \
#     	  --acoustic-scale=1.0 \
#	  --beam=13.0 \
#	  --lattice-beam=6.0 \
#	  --max-active=7000 \
#	  --endpoint.silence-phones=1:2:3:4:5:6:7:8:9:10:11:12:13:14:15 \
#	  --endpoint.rule2.min-trailing-silence=0.5 \
#	  --endpoint.rule3.min-trailing-silence=1.0 \
#	  --endpoint.rule4.min-trailing-silence=2.0 \
#	  --mfcc-config=conf/mfcc.conf \
#	  --ivector-extraction-config=ivector/ivector.conf \
#	  --word-symbol-table=graph/words.txt \
#	  --max-batch-size=200 \
#	  --cuda-worker-threads=2 \
#	  am/final.mdl \
#	  graph/HCLG.fst \
#          "scp:$1/wav.scp" \
#          "ark:|gzip -c > $LOCAL_RESULT_PATH/lat.gz" &> $LOG_FILE


#--print-partial-hypotheses=false \
#--print-endpoints=false \
#2>&1  | tee -a result.txt


  echo "$0 lattice to transcript"
  # convert lattice to transcript
  $KALDI_ROOT/src/latbin/lattice-best-path \
    "ark:gunzip -c $LOCAL_RESULT_PATH/lat.gz |"\
    "ark,t:|gzip -c > $LOCAL_RESULT_PATH/trans_int.gz" || exit 0;

  echo "$0 making trans_int"
  gunzip -c $LOCAL_RESULT_PATH/trans_int.gz | sort -n > $LOCAL_RESULT_PATH/trans_int || exit 0;

  echo "$0 awk"

   awk '{
      start=match($1,"-[0-9]+-[0-9]+$")-1;
      end=length($1)+2;
      key=substr($1, 1, start);
      trans=substr($0,end);
      transcriptions[key]=transcriptions[key] trans
    }
    END {
     for (key in transcriptions) {
       print key " " transcriptions[key]
     }
  }' \
  $LOCAL_RESULT_PATH/trans_int | sort -n > $LOCAL_RESULT_PATH/trans_int_combined || exit 0;

  echo "$0 int2sym"

  #translate ints to words
  $KALDI_ROOT/egs/wsj/s5/utils/int2sym.pl -f 2- $MODEL/graph/words.txt $LOCAL_RESULT_PATH/trans_int> $LOCAL_RESULT_PATH/trans || exit 0;
  $KALDI_ROOT/egs/wsj/s5/utils/int2sym.pl -f 2- $MODEL/graph/words.txt $LOCAL_RESULT_PATH/trans_int_combined> $LOCAL_RESULT_PATH/trans_combined || exit 0;

#  echo "Transcripts output to $LOCAL_RESULT_PATH/trans" 2>&1 >> $LOG_FILE

#mkdir -p $LOCAL_RESULT_PATH
#rm -rf $LOCAL_RESULT_PATH
#mkdir $LOCAL_RESULT_PATH
