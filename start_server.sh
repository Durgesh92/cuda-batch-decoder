cuda_flags="--cuda-use-tensor-cores=true 
--iterations=1 --cuda-memory-proportion=.5 
--max-batch-size=32 --cuda-worker-threads=2"

LOCAL_RESULT_PATH=out
KALDI_ROOT=`pwd`/kaldi
LOG_FILE="$LOCAL_RESULT_PATH/output.log"
MODEL=model/vosk-model-en-us-aspire-0.2

mkdir -p $LOCAL_RESULT_PATH
rm -rf $LOCAL_RESULT_PATH
mkdir $LOCAL_RESULT_PATH

$KALDI_ROOT/src/cudadecoderbin/batched-wav-nnet3-cuda-preloading-online $cuda_flags \
	  --frame-subsampling-factor=3 \
	  --frames-per-chunk=51 \
     	  --acoustic-scale=1.0 \
	  --beam=13.0 \
	  --lattice-beam=6.0 \
	  --max-active=7000 \
	  --endpoint.silence-phones=1:2:3:4:5:6:7:8:9:10:11:12:13:14:15 \
	  --endpoint.rule2.min-trailing-silence=0.5 \
	  --endpoint.rule3.min-trailing-silence=1.0 \
	  --endpoint.rule4.min-trailing-silence=2.0 \
	  --mfcc-config=$MODEL/conf/mfcc.conf \
	  --ivector-extraction-config=$MODEL/ivector/ivector.conf \
	  --word-symbol-table=$MODEL/graph/words.txt \
	  --max-batch-size=200 \
	  --cuda-worker-threads=2 \
	  $MODEL/am/final.mdl \
	  $MODEL/graph/HCLG.fst \
          "scp:test_audios/wav.scp" \
          "ark:|gzip -c > $LOCAL_RESULT_PATH/lat.gz"

