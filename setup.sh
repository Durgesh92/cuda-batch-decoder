#!/bin/bash
sudo apt-get install git zlib1g-dev make automake autoconf sox libtool subversion libatlas3-base g++ python3 python3-pip gstreamer1.0-plugins-bad  gstreamer1.0-plugins-base gstreamer1.0-plugins-good  gstreamer1.0-pulseaudio  gstreamer1.0-plugins-ugly  gstreamer1.0-tools libgstreamer1.0-dev libjansson-dev libfcgi-dev python-gi python-yaml openjdk-8-jdk wget unzip gradle

sudo apt-get install zlib-devel zlib1g-dev make automake autoconf patch grep bzip2 gzip unzip wget git sox python2.7 gawk subversion 

sudo pip install tornado ws4py

git clone https://github.com/kaldi-asr/kaldi 
cp -r cudadecoderbin kaldi/src/ 

cd kaldi/tools 
./extras/install_mkl.sh || exit 0;
make -j 4 || exit 0;
cd ../src 
./configure --shared || exit 0;
make depend -j 4 || exit 0;
make -j 4 || exit 0
make ext -j 4 || exit 0

wget https://alphacephei.com/vosk/models/vosk-model-en-us-aspire-0.2.zip

mkdir -p model

unzip vosk-model-en-us-aspire-0.2.zip -d model/

model=model/vosk-model-en-us-aspire-0.2/ivector
dir=`pwd`
original_str='model'
replace_str=$dir/model/vosk-model-en-us-aspire-0.2

mv $model/ivector.conf $model/ivector.conf.bkp

sed "s~$original_str~$replace_str~" $model/ivector.conf.bkp > $model/ivector.conf
