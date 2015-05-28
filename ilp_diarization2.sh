#!/bin/bash

PATH=$PATH:..:.

audio=$1

mem=1G
show=`basename $audio .sph`
show=`basename $show .wav`

echo $show

#need JVM 1.6
java=java

datadir=$3/${show}

pmsgmm=./models/sms.gmms
sgmm=./models/s.gmms
ggmm=./models/gender.gmms

#uem=./sph/$show.uem.seg

LOCALCLASSPATH=./LIUM_SpkDiarization-8.4.1.jar

echo "#####################################################"
echo "#   $show"
echo "#####################################################"

mkdir ./$datadir >& /dev/null

features=./$datadir/%s.mfcc
fDescStart="audio16kHz2sphinx,1:1:0:0:0:0,13,0:0:0"
fDesc="sphinx,1:1:0:0:0:0,13,0:0:0"
fDescD="sphinx,1:3:2:0:0:0,13,0:0:0:0"
fDescLast="sphinx,1:3:2:0:0:0,13,1:1:0:0"
fDescCLR="sphinx,1:3:2:0:0:0,13,1:1:300:4"



echo compute the MFCC
java -Xmx$mem -classpath "$LOCALCLASSPATH" fr.lium.spkDiarization.tools.Wave2FeatureSet --help --fInputMask=$audio --fInputDesc=$fDescStart --fOutputMask=$features --fOutputDesc=$fDesc $show

echo check the MFCC 
java -Xmx$mem -classpath "$LOCALCLASSPATH" fr.lium.spkDiarization.programs.MSegInit   --help --fInputMask=$features --fInputDesc=$fDesc --sInputMask=$uem --sOutputMask=./$datadir/%s.i.seg  $show

echo GLR based segmentation, make small segments
java -Xmx$mem -classpath "$LOCALCLASSPATH" fr.lium.spkDiarization.programs.MSeg   --kind=FULL --sMethod=GLR  --help --fInputMask=$features --fInputDesc=$fDesc --sInputMask=./$datadir/%s.i.seg --sOutputMask=./$datadir/%s.s.seg  $show

echo  Segmentation: linear clustering
l=2
java -Xmx$mem -classpath "$LOCALCLASSPATH" fr.lium.spkDiarization.programs.MClust    --help --fInputMask=$features --fInputDesc=$fDesc --sInputMask=./$datadir/%s.s.seg --sOutputMask=./$datadir/%s.l.seg --cMethod=l --cThr=$l $show

h=3
echo  hierarchical clustering
java -Xmx$mem -classpath "$LOCALCLASSPATH" fr.lium.spkDiarization.programs.MClust    --help --fInputMask=$features --fInputDesc=$fDesc --sInputMask=./$datadir/%s.l.seg --sOutputMask=./$datadir/%s.h.$h.seg --cMethod=h --cThr=$h $show

echo  initialize GMM
java -Xmx$mem -classpath "$LOCALCLASSPATH" fr.lium.spkDiarization.programs.MTrainInit   --help --nbComp=8 --kind=DIAG --fInputMask=$features --fInputDesc=$fDesc --sInputMask=./$datadir/%s.h.$h.seg --tOutputMask=./$datadir/%s.init.gmms $show

echo  EM computation
java -Xmx$mem -classpath "$LOCALCLASSPATH" fr.lium.spkDiarization.programs.MTrainEM   --help  --nbComp=8 --kind=DIAG --fInputMask=$features --fInputDesc=$fDesc --sInputMask=./$datadir/%s.h.$h.seg --tOutputMask=./$datadir/%s.gmms  --tInputMask=./$datadir/%s.init.gmms  $show 

echo Viterbi decoding
java -Xmx$mem -classpath "$LOCALCLASSPATH" fr.lium.spkDiarization.programs.MDecode    --help --fInputMask=${features} --fInputDesc=$fDesc --sInputMask=./$datadir/%s.h.$h.seg --sOutputMask=./$datadir/%s.d.$h.seg --dPenality=250  --tInputMask=$datadir/%s.gmms $show

echo ----------------
echo Speech/Music/Silence segmentation
pmsseg=./$datadir/$show.pms.seg
java -Xmx$mem -classpath "$LOCALCLASSPATH" fr.lium.spkDiarization.programs.MDecode  --help  --fInputDesc=$fDescD --fInputMask=$features --sInputMask=./$datadir/%s.i.seg --sOutputMask=$pmsseg --dPenality=10,10,50 --tInputMask=$pmsgmm $show

echo filter spk segmentation according pms segmentation
fltseg=./$datadir/$show.flt.$h.seg
java -Xmx$mem -classpath "$LOCALCLASSPATH" fr.lium.spkDiarization.tools.SFilter --help  --fInputDesc=$fDescD --fInputMask=$features --fltSegMinLenSpeech=150 --fltSegMinLenSil=25 --sFilterClusterName=j --fltSegPadding=25 --sFilterMask=$pmsseg --sInputMask=./$datadir/%s.d.$h.seg --sOutputMask=$fltseg $show

echo Set gender and bandwith
gseg=./$datadir/$show.g.$h.seg
java -Xmx$mem -classpath "$LOCALCLASSPATH" fr.lium.spkDiarization.programs.MScore --help  --sGender --sByCluster --fInputDesc=$fDescLast --fInputMask=$features --sInputMask=$fltseg --sOutputMask=$gseg --tInputMask=$ggmm $show


echo ILP Clustering
c=$2
java -Xmx$mem  -cp $LOCALCLASSPATH fr.lium.spkDiarization.programs.ivector.ILPClustering --cMethod=es_iv --ilpThr=$c --help --sInputMask=$gseg --sOutputMask=./$datadir/%s.ev_is.$c.seg --fInputMask=$features --fInputDesc=$fDescLast --tInputMask=./ubm/wld.gmm --nEFRMask=mat/wld.efn.xml --ilpGLPSolProgram=glpsol --nMahanalobisCovarianceMask=./mat/wld.mahanalobis.mat --tvTotalVariabilityMatrixMask=./mat/wld.tv.mat --ilpOutputProblemMask=./$datadir/%s.ilp.problem.$c.txt --ilpOutputSolutionMask=./$datadir/%s.ilp.solution.$c.txt $show
