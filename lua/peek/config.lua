local module = {}

local DEFAULT_THEME = 'dark'
local DEFAULT_PORT = 8888

local config = {
  auto_load = true,
  close_on_bdelete = true,
  syntax = true,
  theme = DEFAULT_THEME,
  update_on_change = true,
  throttle_at = 200000,
  throttle_time = 'auto',
  app = 'webview',
  filetype = { 'markdown' },
  port = DEFAULT_PORT,
}

local function optional(predicate)
  return function(value)
    if not value then
      return true
    end
    return predicate(value)
  end
end

local function one_of(values)
  return function(value)
    for _, predicate in pairs(values) do
      if (type(predicate) == 'function' and predicate(value)) or value == predicate then
        return true
      end
    end
  end
end

local function of_type(t)
  return function(value)
    return type(value) == t
  end
end

local function every(predicate)
  return function(t)
    if type(t) ~= 'table' then
      return
    end
    for _, value in pairs(t) do
      if not predicate(value) then
        return
      end
    end
    return true
  end
end

function module.setup(incoming)
  incoming = incoming or {}

  vim.validate({
    config = { incoming, 'table' },
  })

  vim.validate({
    close_on_bdelete = { incoming.close_on_bdelete, 'boolean', true },
    auto_load = { incoming.auto_load, 'boolean', true },
    syntax = { incoming.syntax, 'boolean', true },
    -- Ensure theme is one of the valid options if provided, key is optional
    theme = { incoming.theme, one_of({ DEFAULT_THEME, 'light' }), true },
    update_on_change = { incoming.update_on_change, 'boolean', true },
    throttle_at = { incoming.throttle_at, 'number', true },
    throttle_time = { incoming.throttle_time, optional(one_of({ 'auto', of_type('number') })), '"auto" or number' },
    app = { incoming.app, optional(one_of({ of_type('string'), every(of_type('string')) })), 'string or string[]' },
    filetype = { incoming.filetype, optional(every(of_type('string'))), 'string[]' },
    -- Ensure port is a number if provided, key is optional
    port = { incoming.port, 'number', true },
  })

  config = vim.tbl_extend('force', config, incoming)

  -- Ensure critical string/number options have defaults if user provided `nil`
  config.theme = config.theme or DEFAULT_THEME
  config.port = config.port or DEFAULT_PORT
end

function module.get(key)
  return config[key]
end

return module
