require 'mobdebug'.start()
require 'nn'
require 'nngraph'
require 'optim'
require 'Embedding'
local model_utils=require 'model_utils'
require 'project_utils'
require 'disjointset'
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




function f(t1, t2)
  return t1[1] < t2[1]
end

function kruskal(vertices, edges)

  table.sort(edges, f)
  local mst = {}
  local sets = {}

  for _, vertex in pairs(vertices) do 
    sets[vertex] = make_set(vertex)
  end

  for _, edge in pairs(edges) do
    if find_set(sets[edge[2]]) ~= find_set(sets[edge[3]]) then
      mst[#mst + 1] = edge
      union_set(sets[edge[2]], sets[edge[3]])
    end
  end
  return mst
end

local mst = kruskal(vertices, edges)

dummy_pass = 1