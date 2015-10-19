require 'mobdebug'.start()
require 'nn'
require 'nngraph'
require 'optim'
require 'Embedding'
local model_utils=require 'model_utils'
require 'project_utils'
require 'pq3'
nngraph.setDebug(true)



function cmp(x1, x2)
  return x1[2] < x2[2]  
end

q = make_empty_heap(cmp)
es = {}
es[1] = {'a', 1}
es[2] = {'b', 2}
es[3] = {'c', 3}

for _, e in pairs(es) do 
  insert(q, e)  
end

print(find_top(q))

-- `q` changed because the tables are passed by reference
es[2][2] = 0.5
update_priority(q, es[2])

print(find_top(q))

-- `q` doesnt see the change
es[3] = {'c', 0.1}
update_priority(q, es[3])

print(find_top(q))



