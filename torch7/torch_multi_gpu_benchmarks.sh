#!/bin/bash

source $(pwd)'/torch/install/bin/torch-activate'
echo $PATH
which th

CMBS=64
CNB=100

RMBS=128
RNB=100

FMBS=256
FNB=100

for i in "$@"
do
case $i in
    -cm=*|--cnn_mini_batch_size=*)
    CMBS="${i#*=}"
    shift # past argument=value
    ;;
    -cn=*|--cnn_num_batch=*)
    CNB="${i#*=}"
    shift # past argument=value
    ;;

    -rm=*|--rnn_mini_batch_size=*)
    RMBS="${i#*=}"
    shift # past argument=value
    ;;
    -rn=*|--rnn_num_batch=*)
    RNB="${i#*=}"
    shift # past argument=value
    ;;

    -fm=*|--fcn_mini_batch_size=*)
    fMBS="${i#*=}"
    shift # past argument=value
    ;;
    -fn=*|--fcn_num_batch=*)
    FNB="${i#*=}"
    shift # past argument=value
    ;;

    --default)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
            # unknown option
    ;;
esac
done

sudo rm -f output_alexnet_2gpu.log
sudo rm -f output_resnet_2gpu.log
sudo rm -f output_fcn5_2gpu.log
sudo rm -f output_fcn8_2gpu.log

th multi_gpu_benchmark.lua -gpus 0,1 -arch alexnet -batchSize ${CMBS} -nIterations ${CNB} -deviceId 0 2>&1 | tee output_alexnet_2gpu.log
th multi_gpu_benchmark.lua -gpus 0,1 -arch resnet -batchSize ${CMBS} -nIterations ${CNB} -deviceId 0 2>&1 | tee output_resnet_2gpu.log
th multi_gpu_benchmark.lua -gpus 0,1 -arch fcn5 -batchSize ${FMBS} -nIterations ${FNB} -deviceId 0 2>&1 | tee output_fcn5_2gpu.log
th multi_gpu_benchmark.lua -gpus 0,1 -arch fcn8 -batchSize ${FMBS} -nIterations ${FNB} -deviceId 0 2>&1 | tee output_fcn8_2gpu.log

sudo rm -f output_alexnet_4gpu.log
sudo rm -f output_resnet_4gpu.log
sudo rm -f output_fcn5_4gpu.log
sudo rm -f output_fcn8_4gpu.log

th multi_gpu_benchmark.lua -gpus 0,1,2,3 -arch alexnet -batchSize ${CMBS} -nIterations ${CNB} -deviceId 0 2>&1 | tee output_alexnet_4gpu.log
th multi_gpu_benchmark.lua -gpus 0,1,2,3 -arch resnet -batchSize ${CMBS} -nIterations ${CNB} -deviceId 0 2>&1 | tee output_resnet_4gpu.log
th multi_gpu_benchmark.lua -gpus 0,1,2,3 -arch fcn5 -batchSize ${FMBS} -nIterations ${FNB} -deviceId 0 2>&1 | tee output_fcn5_4gpu.log
th multi_gpu_benchmark.lua -gpus 0,1,2,3 -arch fcn8 -batchSize ${FMBS} -nIterations ${FNB} -deviceId 0 2>&1 | tee output_fcn8_4gpu.log