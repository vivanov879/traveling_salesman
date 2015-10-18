require 'mobdebug'.start()
require 'nn'
require 'nngraph'
require 'optim'
require 'Embedding'
local model_utils=require 'model_utils'
require 'project_utils'
require 'pq3'
nngraph.setDebug(true)


l = {}
l[{1,2}] = 3

print(l[{1,2}])
dummy_pass = 1