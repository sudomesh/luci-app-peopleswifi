m = Map("wireless", "Wireless") -- We want to edit the uci config file /etc/config/network

s = m:section(TypedSection, "wifi-iface", "Wireless Interface") 
s.addremove = false 

s:depends("ifname", "priv0")
p = s:option(ListValue, "encryption", "Encryption") -- Creates an element list (select box)
p:value("none", "none") -- Key and value pairs
p:value("psk2", "psk2")
p.default = "psk2"

s:option(Value, "key", "key", "Your Wifi Password")

s:option(Value, "ssid", "ssid", "Your Wifi Name")

return m -- Returns the map
