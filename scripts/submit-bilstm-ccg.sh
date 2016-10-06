# submit jobs

TASK=ccg

TASKTRAIN=eng_ccg_train.conll
TASKTEST=eng_ccg_test.conll
TASKDEV=eng_ccg_dev.conll

TIME=24:00:00
PARTITION=nodes
EXPDIR=/data/p252438/experiments/coling2016ks

SIGMA=0.2
CDIM=100
HLAYERS=3
SEED=1512141834
TRAINER=sgd
INDIM=64
#ITERS=20
ITERS=30

DURATION=b1
T1_TRAIN=tasks/pauses/$DURATION.all
T1_TEST=tasks/pauses/$DURATION/user1.dat

T1_OUT=3
T0_OUT=$HLAYERS

MODELDIR=$EXPDIR/models_$TASK/
NOHUPDIR=$EXPDIR/nohup_$TASK/
OUTDIR=predictions/$TASK/

mkdir -p $MODELDIR
mkdir -p $NOHUPDIR
mkdir -p $OUTDIR
mkdir -p $EXPDIR

BILSTM=~/projects/coling2016ks/src/bilty.py
CORPUSDIR=tasks/$TASK/


####### Baseline ######
NAME=$TASK.baseline.i$ITERS
JOBNAME=$NAME

echo "#!/bin/bash"  > $$tmp
echo "#SBATCH --ntasks=1 --cpus-per-task 2 --time=$TIME --job-name=$JOBNAME --partition=$PARTITION --mem=64GB" >> $$tmp
echo "#SBATCH --output=runs/${JOBNAME}.out" >> $$tmp
echo "#SBATCH --error=runs/${JOBNAME}.out2" >> $$tmp
echo "module load CMake" >> $$tmp

echo "python $BILSTM --cnn-seed $SEED --train $CORPUSDIR/$TASKTRAIN --test $CORPUSDIR/$TASKTEST --in_dim $INDIM --c_in_dim $CDIM --pred_layer $T0_OUT --h_layers $HLAYERS --trainer $TRAINER --iters $ITERS --sigma $SIGMA --save $MODELDIR/$NAME.model --output $OUTDIR/$TASKTEST.baseline  > $NOHUPDIR/$NAME.out 2> $NOHUPDIR/$NAME.out2" >> $$tmp
echo "perl scripts/conlleval.pl -d '\t' < $OUTDIR/$TASKTEST.baseline.task0" >> $$tmp
cat $$tmp
sbatch $$tmp
rm $$tmp

###### with auxiliary task #####

for T1_TRAIN in tasks/pauses/$DURATION.all 
do

    NAME=$TASK.hl$HLAYERS.t1`basename $T1_TRAIN`.pl$T0_OUT.$T1_OUT.i$ITERS
    JOBNAME=$NAME

    echo "#!/bin/bash"  > $$tmp
    echo "#SBATCH --ntasks=1 --cpus-per-task 2 --time=$TIME --job-name=$JOBNAME --partition=$PARTITION --mem=64GB" >> $$tmp
    echo "#SBATCH --output=runs/${JOBNAME}.out" >> $$tmp
    echo "#SBATCH --error=runs/${JOBNAME}.out2" >> $$tmp
    echo "module load CMake" >> $$tmp
    
    echo "python $BILSTM --cnn-seed $SEED --train $CORPUSDIR/$TASKTRAIN $T1_TRAIN --test $CORPUSDIR/$TASKTEST $T1_TEST --dev $CORPUSDIR/$TASKDEV --in_dim $INDIM --c_in_dim $CDIM --pred_layer $T0_OUT $T1_OUT --h_layers $HLAYERS --trainer $TRAINER --iters $ITERS --sigma $SIGMA --save $MODELDIR/$NAME.model --output $OUTDIR/$TASKTEST.$NAME > $NOHUPDIR/$NAME.out 2> $NOHUPDIR/$NAME.out2" >> $$tmp
    echo "perl scripts/conlleval.pl -d '\t' < $OUTDIR/$TASKTEST.$NAME.task0" >> $$tmp
    cat $$tmp
sbatch $$tmp
    rm $$tmp
done

