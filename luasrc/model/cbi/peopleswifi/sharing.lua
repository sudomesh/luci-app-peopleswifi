local sys = require("luci.sys")
uci = require("uci")
require "luci.http"

function getConfType(conf,type)
  local curs=uci.cursor()
  local ifce={}
  curs:foreach(conf,type,function(s) ifce[s[".index"]]=s end)
  return ifce
end

m = Map("tunneldigger", translate("Sharing"), translate("Choose how much bandwith to share")) -- We want to edit the uci config file /etc/config/batman-adv

s = m:section(NamedSection, "main", "broker", "Download and upload bandwidth", "How fast will you allow users of peoplesopen.net to download and upload using your connection?")
s.addremove = false

p = s:option(ListValue, "limit_bw_down", translate("Download bandwidth"))
p:value("1024kbit", translate("1 megabit per second"))
p:value("2048kbit", translate("2 megabit per second"))
p:value("3072kbit", translate("3 megabit per second"))
p:value("4096kbit", translate("4 megabit per second"))
p:value("6144kbit", translate("6 megabit per second"))
p:value("8192kbit", translate("8 megabit per second"))
p:value("10240kbit", translate("10 megabit per second"))
p:value("12288kbit", translate("12 megabit per second"))
p:value("16384kbit", translate("16 megabit per second"))
p:value("20480kbit", translate("20 megabit per second"))
p:value("24576kbit", translate("24 megabit per second"))
p:value("28672kbit", translate("28 megabit per second"))
p:value("32768kbit", translate("32 megabit per second"))
p:value("49152kbit", translate("48 megabit per second"))
p:value("65536kbit", translate("64 megabit per second"))
p:value("0", "No sharing")

p = s:option(ListValue, "limit_bw_up", translate("Upload bandwidth"))
p:value("512kbit", translate("0.5 megabit per second"))
p:value("1024kbit", translate("1 megabit per second"))
p:value("2048kbit", translate("2 megabit per second"))
p:value("3072kbit", translate("3 megabit per second"))
p:value("4096kbit", translate("4 megabit per second"))
p:value("6144kbit", translate("6 megabit per second"))
p:value("8192kbit", translate("8 megabit per second"))
p:value("10240kbit", translate("10 megabit per second"))
p:value("12288kbit", translate("12 megabit per second"))
p:value("16384kbit", translate("16 megabit per second"))
p:value("20480kbit", translate("20 megabit per second"))
p:value("24576kbit", translate("24 megabit per second"))
p:value("28672kbit", translate("28 megabit per second"))
p:value("32768kbit", translate("32 megabit per second"))
p:value("49152kbit", translate("48 megabit per second"))
p:value("65536kbit", translate("64 megabit per second"))
p:value("0", "No sharing")

function s.cfgsections()
	return { "_share" }
end

function m.on_commit(self, map)
  
  local batman_gw_mode = 'client'
  
  local formvalue = luci.http.formvaluetable('cbid')

  local up_val = formvalue['tunneldigger.main.limit_bw_up']
  local down_val = formvalue['tunneldigger.main.limit_bw_down']

  if(not string.find(up_val, "^%d+kbit$")) then
    up_val = '0'
  end

  if(not string.find(down_val, "^%d+kbit$")) then
    down_val = '0'
  end

  if not up_val or not down_val or (up_val == '') or (down_val == '') or (up_val == '0') or (down_val == '0') then
    up_val = '0'
    down_val = '0'
  else
    batman_gw_mode = "server "..down_val.."/"..up_val
  end


  local ucicursor = uci.cursor()
  ucicursor:set('batman-adv', 'bat0', 'gw_mode', batman_gw_mode)
  ucicursor:commit('batman-adv')

  m.message = "Settings changed. Sharing  " .. down_val .. " kbit/sec down and " .. up_val .. "kbit/sec up"
  sys.call("/usr/sbin/batctl gw_mode "..batman_gw_mode)
  sys.call("/etc/init.d/tunneldigger restart")
end

return m -- Returns the map
