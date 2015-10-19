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

xy = torch.load('coordinates.t7')

visited = {}


function check_mem_table(l, v)
  for _, x in pairs(l) do 
    if x == v then
      return true
    end
  end
  return false
end

      
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
  local l = {}
  for v = 1, xy:size(1) do
    if not check_mem_table(visited, v) then
      l[#l + 1] = v
    end
  end
  local edges = {}
  for i = 1, #l - 1 do 
    for j = i+1, #l do 
      edges[#edges + 1] = {calc_dist(l[i], l[j]), l[i], l[j]}
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
  local v1, d1 = calc_dist2closest_unvisited(v0, visited)
  local d2 = calc_dist(v1, start0)
  return d1 + d2 + mst_len
end


function cmp(x, y)
  return x['priority'] < y['priority']
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
start0['priority'] = 0

function check_goal(s)
  --last two steps are `visiting last unvisited node` and `returning to start point`
  return #(s['visited']) == xy:size(1) - 1
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


function clone_table(l)
  local t = {}
  for _, v in pairs(l) do 
    t[#t + 1] = v
  end
  return t
end


q_states = {}
q_states[s2id(start0)] = {['visited'] = start0['visited'], ['current'] = start0['current'], ['priority'] = 0}
insert(q, q_states[s2id(start0)])

cost_so_far = {}
cost_so_far[s2id(start0)] = 0

came_from = {}

function tsp()
  while not heap_empty(q) do
    local state0 = extract_top(q)
    if not check_goal(state0) then
      for i = 1, xy:size(1) do
        if i ~= state0['current'] and not check_mem_table(state0['visited'], i) then
          local neighbor = {}
          neighbor['current'] = i
          neighbor['visited'] = clone_table(state0['visited'])
          table.insert(neighbor['visited'], neighbor['current'])
          local new_cost = cost_so_far[s2id(state0)] + calc_dist(state0['current'], neighbor['current'])
          if cost_so_far[s2id(neighbor)] == nil or new_cost <  cost_so_far[s2id(neighbor)] then
            cost_so_far[s2id(neighbor)] = new_cost
            local priority = new_cost + heuristic(neighbor['current'], neighbor['visited'], start0['current'])
            if q_states[s2id(neighbor)] == nil then
              q_states[s2id(neighbor)] = {['visited']= neighbor['visited'], ['current']= neighbor['current'], ['priority']= priority}
              insert(q, q_states[s2id(neighbor)])
            else
              q_states[s2id(neighbor)]['priority'] = priority
              update_priority(q, q_states[s2id(neighbor)])
              came_from[s2id(neighbor)] = state0
            end
          end
        end
      end
    else
      return state0
    end
  end
end

local state0 = tsp()
function find_omitted(visited)
  for i = 1, xy:size(1) do
    if not check_mem_table(visited, i) then
      return i
    end
  end
end

table.insert(state0['visited'], find_omitted(state0['visited']))

gnuplot.plot(xy, '.')
for i, v in pairs(state0['visited']) do 
  --gnuplot.raw(" set label 'ward' at ( 0.12, 0.54 ) ")
  gnuplot.raw(" set label '" .. i .. "' at " .. xy[v][1] .. "," .. xy[v][2] .. " " )
end


dummy_pass = 1
  
  
  
  



