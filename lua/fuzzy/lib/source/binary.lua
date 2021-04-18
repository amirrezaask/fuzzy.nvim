local spawn = require('spawn')

return function(command, args)
  return function()
    return spawn({
      command = command,
      args = args,
      sync = { timeout = 1000, interval = 10 },
    })
  end
end
