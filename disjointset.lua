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
    return nil
  elseif rx['rank'] > ry['rank'] then
    ry['parent'] = rx
  else
    rx['parent'] = ry
    if rx['rank'] == ry['rank'] then
      ry['rank'] = ry['rank'] + 1
    end
  end
end

dummy_pass = 1