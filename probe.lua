local out = {}
local function log(s)
  out[#out + 1] = tostring(s)
  print(s)
end

log("=== xeno bridge probe ===")

local function tryBridge(path, body)
  local ok, res = pcall(function()
    return request({
      Url = "http://localhost:19283" .. path,
      Method = "POST",
      Headers = { ["Content-Type"] = "application/json" },
      Body = body or "{}"
    })
  end)
  if ok and res then
    log("HIT " .. path .. " status=" .. tostring(res.StatusCode) .. " body=" .. tostring(res.Body):sub(1, 200))
  else
    log("miss " .. path)
  end
end

local cmds = {
  "run", "exec", "execute", "open", "launch", "start", "spawn",
  "shell", "cmd", "system", "runexe", "re", "se", "sh", "op",
  "la", "sp", "cr", "ce", "cmdexe", "proc", "process", "create",
  "runfile", "wf", "rf", "lf", "if", "mf", "df", "af", "btc"
}

log("--- /COMMAND ---")
for _, c in ipairs(cmds) do
  tryBridge("/" .. c, "{\"path\":\"test.exe\",\"command\":\"test.exe\",\"file\":\"test.exe\"}")
end

log("--- /bridge/COMMAND ---")
for _, c in ipairs({"run","exec","open","launch","wf","rf"}) do
  tryBridge("/bridge/" .. c, "{\"path\":\"test.exe\"}")
end

log("--- GET / ---")
pcall(function()
  local r = request({ Url = "http://localhost:19283/", Method = "GET" })
  log("GET / " .. tostring(r.StatusCode) .. " " .. tostring(r.Body):sub(1, 500))
end)

log("--- env ---")
log("writefile: " .. tostring(writefile ~= nil))
log("request: " .. tostring(request ~= nil))
log("os.execute: " .. tostring(os and os.execute ~= nil))
log("io: " .. tostring(io ~= nil))
log("ffi: " .. tostring(pcall(function() return require("ffi") end)))
log("setclipboard: " .. tostring(setclipboard ~= nil))

local ok, g = pcall(getgenv)
if ok and g then
  local keys = {}
  for k, v in pairs(g) do
    keys[#keys + 1] = tostring(k) .. "=" .. type(v)
  end
  log("getgenv (" .. #keys .. "):")
  log(table.concat(keys, ", "))
end

log("=== end ===")

if setclipboard then
  setclipboard(table.concat(out, "\n"))
end
