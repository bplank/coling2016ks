# submit job

TIME=24:00:00
PARTITION=nodes
EXPDIR=/data/p252438/experiments/coling2016ks
mkdir -p $EXPDIR
mkdir -p runs
OUTDIR=predictions/chunking
mkdir -p $OUTDIR

## biLSTM parameters
SIGMA=0.2
CDIM=100
#HLAYERS=1    
SEED=1512141834
TRAINER=sgd
INDIM=64
ITERS=30

for HLAYERS in 3 #1 2 3 4
do
T0_OUT=$HLAYERS
NAME=chunks.i$ITERS.s$SIGMA.c$CDIM.i$INDIM.hl$HLAYERS.baseline
echo "#!/bin/bash"  > $$tmp
echo "#SBATCH --ntasks=1 --cpus-per-task 2 --time=$TIME --job-name=$NAME --partition=$PARTITION --mem=64GB" >> $$tmp
echo "#SBATCH --output=runs/${NAME}.out" >> $$tmp
echo "#SBATCH --error=runs/${NAME}.out2" >> $$tmp
echo "module load CMake" >> $$tmp

MODELDIR=$EXPDIR/models/chunking
NOHUPDIR=$EXPDIR/nohup_chunking

mkdir -p $MODELDIR
mkdir -p $NOHUPDIR
BILSTM=~/projects/coling2016ks/src/bilty.py
CORPUSDIR=tasks/chunking/

echo "python $BILSTM --cnn-seed $SEED --train $CORPUSDIR/eng_chunking_train.conll --test $CORPUSDIR/eng_chunking_dev+test.conll --in_dim $INDIM --c_in_dim $CDIM --pred_layer $T0_OUT  --h_layers $HLAYERS --trainer $TRAINER --iters $ITERS --sigma $SIGMA --save $MODELDIR/$NAME.model --output $OUTDIR/eng_chunking_test.conll.$NAME  > $NOHUPDIR/$NAME.out 2> $NOHUPDIR/$NAME.out2" >> $$tmp
cat $$tmp
sbatch $$tmp
rm $$tmp

done
