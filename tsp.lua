require 'mobdebug'.start()
require 'nn'
require 'nngraph'
require 'optim'
require 'Embedding'
local model_utils=require 'model_utils'
require 'project_utils'
require 'pq3'
nngraph.setDebug(true)

xy = torch.load('coordinates.t7')

visited = {}
      
function calc_dist(v0, v)
  local x1 = xy[v0][1]
  local y1 = xy[v0][2]
  local x2 = xy[v][1]
  local y2 = xy[v][2]
  return ((x1 - x2)^2 + (y1 - y2)^2)^0.5

function dist2unvisited(v0)
  local d_min = math.huge
  local v_min = nil
  for v = 1, maze:size(1) do 
    if not visited[v] then
      local d = calc_dist(v0, v)
      if d < d_min then
        d_min = d
        v_min = v
      end
    end
  end
  return v_min, d_min



function get_neighbors(i, j)
  local t = {{i+1, j}, {i-1, j}, {i, j+1}, {i, j-1}}
  local l = {}
  for _, p in pairs(t) do
    local i, j = unpack(p)
    if i >= 1 and i <= 20 and j >= 1 and j <= 20 and maze[i][j] ~= 0 then
      l[#l + 1] = p
    end
  end
  return l
end


function heuristic(a, b)
  local x1, y1 = unpack(a)
  local x2, y2 = unpack(b)
  local d = ((x1 - x2)^2 + (y1 - y2)^2)^0.5
  return d
end
  
graph_cost = 1

function cmp(x, y)
  return x[3] < y[3]
end

id2ij = {}
for i = 1, 20 do 
  for j = 1, 20 do
    id2ij[(i-1)* 20 + j] = {i, j}
  end
end

function ij2id(i, j)
  return (i-1) * 20 + j
end

q = make_empty_heap(cmp)
dist = {}
goal = {20, 20}

dist[ij2id(1, 1)] = {1,1,0}
insert(q, dist[ij2id(1,1)])

cost_so_far = {}
cost_so_far[ij2id(1, 1)] = 0

came_from = {}

while not heap_empty(q) do
  local i0, j0, cost = unpack(extract_top(q))
  for _, neighbor in pairs(get_neighbors(i0, j0)) do 
    i, j = unpack(neighbor)
    local new_cost = cost_so_far[ij2id(i0, j0)] + graph_cost
    if cost_so_far[ij2id(i, j)] == nil or new_cost <  cost_so_far[ij2id(i, j)] then
       cost_so_far[ij2id(i, j)] = new_cost
       local priority = new_cost + heuristic(neighbor, goal)
       dist[ij2id(i, j)] = {i, j, priority}
       update_or_insert(q, dist[ij2id(i, j)])
       came_from[ij2id(i, j)] = {i0, j0}
    end
  end
end

i, j = unpack(goal)
while i ~= 1 and j ~= 1 do
  maze[i][j] = 2
  i, j = unpack(came_from[ij2id(i, j)])
end

print(maze)


dummy_pass = 1
  
  
  
  



