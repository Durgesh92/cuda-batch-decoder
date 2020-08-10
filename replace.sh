model=model/vosk-model-en-us-aspire-0.2/ivector
dir=`pwd`
original_str='model'
replace_str=$dir/model/vosk-model-en-us-aspire-0.2

mv $model/ivector.conf $model/ivector.conf.bkp

sed "s~$original_str~$replace_str~" $model/ivector.conf.bkp > $model/ivector.conf
