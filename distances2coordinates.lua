require 'mobdebug'.start()
require 'nn'
require 'nngraph'
require 'optim'
require 'Embedding'
local model_utils=require 'model_utils'
require 'project_utils'
nngraph.setDebug(true)

sentences = read_words('data.txt')
sentences = convert2tensors(sentences)

vocab_size = sentences:size(1)

x = nn.Identity()()
target = nn.Identity()()

e = Embedding(15, 2)(x)
l = {}
for i = 1, 15 do 
  for j = 1, 15 do
    x1 = nn.Select(1, i)(e)
    x2 = nn.Select(1, j)(e)
    x2 = nn.MulConstant(-1)(x2)
    d = nn.CAddTable()({x1, x2})
    d = nn.Square()(d)
    d = nn.Sum(1)(d)
    d = nn.Sqrt()(d)
    l[#l + 1] = d
  end
end
z = nn.JoinTable(1)(l)
m = nn.gModule({x}, {z, e})

criterion = nn.MSECriterion()

local params, grad_params = model_utils.combine_all_parameters(m)
params:uniform(-0.08, 0.08)

x = torch.zeros(15)
for i = 1, 15 do 
  x[i] = i
end


target = torch.zeros(15 * 15, 1)
counter = 1
for i = 1, 15 do 
  for j = 1, 15 do 
    target[counter][1] = sentences[i][j]
    counter = counter + 1
  end
  
end

function feval(x_arg)
    if x_arg ~= params then
        params:copy(x_arg)
    end
    grad_params:zero()
    
    local loss = 0
    
    
    
    ------------------- forward pass -------------------
    prediction, e = unpack(m:forward(x))
    loss_m = criterion:forward(prediction, target)
    loss = loss + loss_m
    
    -- complete reverse order of the above
    de = torch.zeros(e:size())
    dprediction = criterion:backward(prediction, target)
    dx = m:backward(x, {dprediction, de})

    return loss, grad_params

end



optim_state = {learningRate = 1e-2}


for i = 1, 20000 do

  local _, loss = optim.adam(feval, params, optim_state)
  if i % 100 == 0 then
    print(string.format( 'loss = %6.8f, grad_params:norm() = %6.4e, params:norm() = %6.4e', loss[1], grad_params:norm(), params:norm()))
    print(e)
  end
end

torch.save('coordinates.t7', e)
f = io.open('coordinates.txt', 'w')
for i = 1, e:size(1) do 
  f:write(tostring(e[i][1]) .. ' ' .. tostring(e[i][2]) .. '\n');
  
end

dummy_pass = 1


