function alexnet(batch_size, deviceId)
    local n_classes = 1000

    require 'nn'
    local SpatialConvolution = nn.SpatialConvolution
    local SpatialMaxPooling = nn.SpatialMaxPooling
    local ReLU = nn.ReLU

    if deviceId >= 0 then
        require 'cunn'
        require 'cudnn'
        SpatialConvolution = cudnn.SpatialConvolution
        SpatialMaxPooling = cudnn.SpatialMaxPooling
        ReLU = cudnn.ReLU
    end

    local SpatialZeroPadding = nn.SpatialZeroPadding
    local padding = false 
    local stride1only = false

    -- from https://code.google.com/p/cuda-convnet2/source/browse/layers/layers-imagenet-1gpu.cfg
    -- this is AlexNet that was presented in the One Weird Trick paper. http://arxiv.org/abs/1404.5997
    local features = nn.Sequential()
    -- features:add(SpatialConvolution(3,64,11,11,4,4,2,2))       -- 224 -> 55
    features:add(SpatialConvolution(3,96,11,11,4,4,2,2))       -- 224 -> 55
    features:add(ReLU(true))
    features:add(SpatialMaxPooling(3,3,2,2))                   -- 55 ->  27
    -- features:add(SpatialConvolution(64,192,5,5,1,1,2,2))       --  27 -> 27
    features:add(SpatialConvolution(96,256,5,5,1,1,2,2))       --  27 -> 27
    features:add(ReLU(true))
    features:add(SpatialMaxPooling(3,3,2,2))                   --  27 ->  13
    -- features:add(SpatialConvolution(192,384,3,3,1,1,1,1))      --  13 ->  13
    features:add(SpatialConvolution(256,384,3,3,1,1,1,1))      --  13 ->  13
    features:add(ReLU(true))
    -- features:add(SpatialConvolution(384,256,3,3,1,1,1,1))      --  13 ->  13
    features:add(SpatialConvolution(384,384,3,3,1,1,1,1))      --  13 ->  13
    features:add(ReLU(true))
    --features:add(SpatialConvolution(256,256,3,3,1,1,1,1))      --  13 ->  13
    features:add(SpatialConvolution(384,256,3,3,1,1,1,1))      --  13 ->  13
    features:add(ReLU(true))
    features:add(SpatialMaxPooling(3,3,2,2))                   -- 13 -> 6

    local classifier = nn.Sequential()
    classifier:add(nn.View(256*6*6))
    classifier:add(nn.Linear(256*6*6, 4096))
    classifier:add(nn.Threshold(0, 1e-6))
    classifier:add(nn.Linear(4096, 4096))
    classifier:add(nn.Threshold(0, 1e-6))
    classifier:add(nn.Linear(4096, n_classes))
    if deviceId >= 0 then
        classifier:add(cudnn.LogSoftMax())
    else
        classifier:add(nn.LogSoftMax())
    end

    features:get(1).gradInput = nil

    local model = nn.Sequential()
    model:add(features):add(classifier)

    return model, 'AlexNet', {batch_size,3,224,224}, batch_size, n_classes
end

return alexnet
