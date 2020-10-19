local uv = vim.loop

local M = {}

function M.NewBinSource(bin, args, stdout_handler, stderr_handler)
  return function()
    local stdout = uv.new_pipe(false)
    local stderr = uv.new_pipe(false)
    uv.spawn(bin, {args=args, stdio={_, stdout, stderr}}, function(code, signal)
        if code ~= 0 then
          print(string.format('process exited with %s and %s', code, signal))
          stdout:read_stop()
          stderr:read_stop()
          stdout:close()
          stderr:close()
        end
      end)
    uv.read_start(stdout, function(err, data)
      if err then
        stderr_handler(err)
        return
      end
      if data then
        for _, d in ipairs(vim.split(data, '\n')) do
          if d == "" then goto continue end
          stdout_handler(d)
          ::continue::
        end
      end
    end)
    uv.read_start(stderr, function(err, data)
      if err then
        stderr_handler(err)
      end
      if data then
        stderr_handler(err)
      end
    end)
  end
end



return M
