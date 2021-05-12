local job = require('plenary.job')

return function(command, args)
  return function()
    return job:new({
      command = command,
      args = args,
    }):sync(1000)
  end
end
