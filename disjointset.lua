require 'mobdebug'.start()
require 'nn'
require 'nngraph'
require 'optim'
require 'Embedding'
local model_utils=require 'model_utils'
require 'project_utils'
nngraph.setDebug(true)


function make_set(x)
  local set = {}
  set['rank'] = 0
  set['value'] = x
  set['parent'] = set  
  return set
end


function find_set(x)
  if x['parent'] ~= x then
    x['parent'] = find_set(x['parent'])
  end
  return x
end

function union_set(x, y)
  local rx = find_set(x)
  local ry = find_set(y)
  if rx == ry then 
    return rx
  elseif rx['rank'] > ry['rank'] then
    ry['parent'] = rx
    return rx
  else
    rx['parent'] = ry
    if rx['rank'] == ry['rank'] then
      ry['rank'] = ry['rank'] + 1
    end
    return ry
  end
end

vertices = {'A', 'B', 'C', 'D', 'E', 'F'}
edges = {
            {1, 'A', 'B'},
            {5, 'A', 'C'},
            {3, 'A', 'D'},
            {4, 'B', 'C'},
            {2, 'B', 'D'},
            {1, 'C', 'D'},
            {3, 'C', 'F'},
            {1, 'F', 'E'},
        }




function f(t1, t2)
  return t1[1] < t2[1]
end


table.sort(edges, f)
mst = {}
sets = {}

for _, vertex in pairs(vertices) do 
  sets[vertex] = make_set(vertex)
end

for _, edge in pairs(edges) do
  if find_set(sets[edge[2]]) ~= find_set(sets[edge[3]]) then
    mst[#mst + 1] = edge
    union_set(sets[edge[2]], sets[edge[3]])
  end
end

dummy_pass = 1