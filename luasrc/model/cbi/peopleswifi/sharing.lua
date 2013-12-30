local sys = require("luci.sys")
uci = require("uci")
require "luci.http"

function getConfType(conf,type)
  local curs=uci.cursor()
  local ifce={}
  curs:foreach(conf,type,function(s) ifce[s[".index"]]=s end)
  return ifce
end

m = Map("batman-adv", translate("Sharing"), translate("Choose how much bandwith to share")) -- We want to edit the uci config file /etc/config/batman-adv

s = m:section(NamedSection, "bat0", "mesh", "")
s.addremove = false

p = s:option(ListValue, "gw_mode", translate("Amount")) -- Creates an element list (select box)
p:value("server 1mbit/256kbit", translate("1mbit down - 256kbit up")) -- Key and value pairs
p:value("server 5mbit/1mbit", translate("5mbit down - 1mbit up")) -- Key and value pairs
p:value("server 10mbit/5mbit", translate("10mbit down - 5mbit up"))
p:value("client", "No Sharing")

p.default = "server 1mbit/256kbit"

function s.cfgsections()
	return { "_share" }
end

function split(pString, pPattern)                                  
  local Table = {}                                
  local fpat = "(.-)" .. pPattern                 
  local last_end = 1                              
  local s, e, cap = pString:find(fpat, 1)         
  while s do                             
    if s ~= 1 or cap ~= "" then                           
      table.insert(Table,cap)         
    end                                     
    last_end = e+1                          
    s, e, cap = pString:find(fpat, last_end)
  end                                
  if last_end <= #pString then       
    cap = pString:sub(last_end)
    table.insert(Table, cap)
  end                                           
  return Table                            
end 

function m.on_commit(self, map)
  
  local up = 0
  local upUnits = ""
  local down = 0
  local downUnits = ""
  
  local formvalue = luci.http.formvaluetable('cbid')
  local raw_val = formvalue['batman-adv.bat0.gw_mode']

  if (raw_val == "client") then
  -- Nothing to do I think
  else
    local split_val = split(raw_val, "%/")

    up = split_val[2]
    down = split_val[1]

    upUnits = string.gsub(up, "%d", "")
    downUnits = string.gsub(string.gsub(down, "%d", ""), "server ", "")

    up = string.gsub(up, "%a", "")
    down = string.gsub(down, "%a", "")

    if (upUnits == "kbit") then 
      up = up 
    elseif (upUnits == "mbit") then
      up = up * 1024
    elseif (upUnits == "gbit") then
      up = up * 1024 * 1024
    end

    if (downUnits == "kbit") then 
      down = down 
    elseif (upUnits == "mbit") then
      down = down * 1024
    elseif (upUnits == "gbit") then
      down = down * 1024 * 1024
    end
  end
  
  local ucibrokername = getConfType("tunneldigger", "broker")[0]['.name']

  local ucicursor = uci.cursor()

  ucicursor:set('tunneldigger', ucibrokername, 'limit_bw_down', down)
  ucicursor:set('tunneldigger', ucibrokername, 'limit_bw_up', up)
  ucicursor:commit('tunneldigger')

  m.message = "Settings changed. Sharing  " .. down .. "kbit down and " .. up .. "kbit up"
  sys.call("/etc/init.d/tunneldigger restart")
end

return m -- Returns the map
