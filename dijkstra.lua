require 'mobdebug'.start()
require 'nn'
require 'nngraph'
require 'optim'
require 'Embedding'
local model_utils=require 'model_utils'
require 'project_utils'
require 'pq3'
nngraph.setDebug(true)

edges = { {1, 4}, { 2, 3 }, { 2, 4 }, { 3, 4 }, { 3, 5 }, { 4, 5 }, { 2, 6 } }
w = { 2, 4, 18, 2, 7, 5, 8}
vs = { 1, 2, 3, 4, 5, 6 }
dist = {}


function cmp(x1, x2)
  return x1[2] < x2[2]  
end

q = make_empty_heap(cmp)

for _, v in pairs(vs) do
  dist[v] = {v, math.huge}
  insert(q, dist[v])
end

--tables are passed as references, so we simply change the table `dist[2]`, and the change occurs in priority queue `q` as well
dist[2][2] = 0
update_priority(q, dist[2])


while not heap_empty(q) do 
  v0, d0 = unpack(extract_top(q))
  print(v0, 'visited')
  for edge_id, edge in pairs(edges) do 
    e1 = edge[1]
    e2 = edge[2]
    if edge[1] == v0 then
      if dist[e2][2] > d0 + w[edge_id] then 
        dist[e2][2] = d0 + w[edge_id]
        update_priority(q, dist[e2])
      end
    end
  end
end


dummy_pass = 1
