print("=== xeno bridge probe ===")

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
    print("HIT " .. path .. " status=" .. tostring(res.StatusCode) .. " body=" .. tostring(res.Body):sub(1, 200))
    return true
  else
    print("miss " .. path)
    return false
  end
end

local cmds = {
  "run", "exec", "execute", "open", "launch", "start", "spawn",
  "shell", "cmd", "system", "runexe", "re", "se", "sh", "op",
  "la", "sp", "cr", "ce", "cmdexe", "proc", "process", "create",
  "runfile", "rf2", "wf", "rf", "lf", "if", "mf", "df", "af", "btc"
}

print("--- probing /COMMAND ---")
for _, c in ipairs(cmds) do
  tryBridge("/" .. c, "{\"path\":\"test.exe\",\"command\":\"test.exe\"}")
end

print("--- probing /bridge/COMMAND ---")
for _, c in ipairs({"run","exec","open","launch","wf","rf"}) do
  tryBridge("/bridge/" .. c, "{\"path\":\"test.exe\"}")
end

print("--- GET / ---")
pcall(function()
  local r = request({ Url = "http://localhost:19283/", Method = "GET" })
  print("GET / " .. tostring(r.StatusCode) .. " " .. tostring(r.Body):sub(1, 500))
end)

print("--- env check ---")
print("writefile: " .. tostring(writefile ~= nil))
print("request: " .. tostring(request ~= nil))
print("os.execute: " .. tostring(os and os.execute ~= nil))
print("io: " .. tostring(io ~= nil))
print("require ffi: " .. tostring(pcall(function() return require("ffi") end)))
print("getgenv keys:")
local ok, g = pcall(getgenv)
if ok and g then
  local n = 0
  for k, v in pairs(g) do
    n = n + 1
    if n <= 40 then print("  " .. tostring(k) .. " = " .. type(v)) end
  end
  print("total: " .. n)
end

print("=== end ===")