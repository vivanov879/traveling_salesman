require 'mobdebug'.start()
require 'nn'
require 'nngraph'
require 'optim'
require 'Embedding'
local model_utils=require 'model_utils'
require 'project_utils'
require 'pq3'
require 'kruskal'
nngraph.setDebug(true)

xy = torch.load('coordinates.t7')

visited = {}
      
function calc_dist(v0, v)
  local x1 = xy[v0][1]
  local y1 = xy[v0][2]
  local x2 = xy[v][1]
  local y2 = xy[v][2]
  return ((x1 - x2)^2 + (y1 - y2)^2)^0.5
end

function calc_dist2closest_unvisited(v0, visited)
  local d_min = math.huge
  local v_min = nil
  for v = 1, xy:size(1) do 
    if not visited[v] then
      local d = calc_dist(v0, v)
      if d < d_min then
        d_min = d
        v_min = v
      end
    end
  end
  return v_min, d_min
end

function calc_mst_len(visited)
  for v = 1, xy:size(1) do
    local l = {}
    if not visited[v] then
      l[#l + 1] = v
    end
    edges = {}
    for i = 1, #l - 1 do 
      for j = i+1, #l do 
        edges[#edges + 1] = {calc_dist(i, j), i, j}
      end
    end
  end
  local mst = kruskal(l, edges)
  local mst_len = 0
  for _, edge in pairs(mst) do
    mst_len = mst_len + edge[1]
  end
  return mst_len
end

function heuristic(v0, visited, start0)
  local mst_len = calc_mst_len(visited)
  local v1, d1 = calc_dist2closest_unvisited
  local d2 = calc_dist(v1, start0)
  return d1 + d2 + mst_len
end


function cmp(x, y)
  return x[3] < y[3]
end

function s2id(s)
  --multipliers we use to get hash from state elements are chosen to be high enough to cover the possible values of the state element
  local hash = 0
  for _, x in pairs(s['visited']) do
    hash = hash + (2^x)
  end
  hash = hash + s['current'] * 1e5
  return hash  
end

q = make_empty_heap(cmp)

start0 = {}
start0['visited'] = {1}
start0['current'] = 1
start0['d'] = 0

function check_goal(s)
  return s['current'] == 1 and #(s['visited']) == xy:size(1)
end

function state_in_heap(h, state0)
  local states = h['locations']
  for _, state in pairs(states) do 
    v = state['visited']
    v0 = state0['visited']
    if #v == #v0 then
      local flag = true
      for i, _ in pairs(v) do 
        if v[i] ~= v0[i] then
          flag = false
        end
      end
      if flag then 
        return true
      end
    end
  end
  return false
end

function check_mem_table(l, v)
  for _, x in pairs(l) do 
    if x == v then
      return true
    end
  end
  return false
end


function clone_table(l)
  local t = {}
  for _, v in pairs(l) do 
    t[#t + 1] = v
  end
  return t
end


q_states = {}
q_states[s2id(start0)] = {start0['visited'], start0['current'], 0}
insert(q, q_states[start0])

cost_so_far = {}
cost_so_far[s2id(start0)] = 0

came_from = {}

while not heap_empty(q) do
  local state0 = extract_top(q)
  for i = 1, xy:size(1) do
    if i ~= state0['current'] and not check_mem_table(state0['visited'], i) then
      local neighbor = {}
      neighbor['current'] = i
      neighbor['visited'] = clone_table(state0['visited'])
      local new_cost = cost_so_far[s2id(state0)] + calc_dist(state0['current'], neighbor['current'])
      if cost_so_far[s2id(neighbor)] == nil or new_cost <  cost_so_far[s2id(neighbor)] then
        cost_so_far[s2id(neighbor)] = new_cost
        local priority = new_cost + heuristic(neighbor['current'], neighbor['visited'], start0['current'])
        if q_states[s2id(neighbor)] == nil then
          q_states[s2id(neighbor)] = {neighbor['visited'], neighbor['current'], priority}
          insert(q, q_states[s2id(neighbor)])
        else
          q_states[s2id(neighbor)][3] = priority
          update(q, q_states[s2id(neighbor)])
          came_from[s2id(neighbor)] = state0
        end
      end
    end
  end
end


dummy_pass = 1
  
  
  
  



