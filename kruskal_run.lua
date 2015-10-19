require 'mobdebug'.start()
require 'nn'
require 'nngraph'
require 'optim'
require 'Embedding'
local model_utils=require 'model_utils'
require 'project_utils'
require 'pq3'
require 'kruskal'
require 'gnuplot'
nngraph.setDebug(true)


local vertices = {'A', 'B', 'C', 'D'}
local edges = {
            {1, 'A', 'B'},
            {5, 'A', 'C'},
            {3, 'A', 'D'},
            {4, 'B', 'C'},
            {2, 'B', 'D'},
            {1, 'C', 'D'},
        }


local mst = kruskal(vertices, edges)

dummy_pass = 1