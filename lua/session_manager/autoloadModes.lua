local Enum = require('plenary.enum')

local autoloadModes = Enum {
  'Disabled',
  'CurrentDir',
  'LastSession'
}

return autoloadModes
