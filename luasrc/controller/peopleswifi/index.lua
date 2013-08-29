--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.peopleswifi.index", package.seeall)

function index()
	local root = node()
	if not root.lock then
		root.target = alias("peopleswifi")
		root.index = true
	end
  
  hostname = "Peoples Wifi"

	entry({"about"}, template("about"))
	
	local page = entry({"peopleswifi"}, alias("peopleswifi", "index"), _("Peoples Wifi"), 10)

  page.sysauth = "root"
  page.sysauth_authenticator = function()                            
    local password = tostring(luci.sys.exec('less /usr/lib/lua/luci/peopleswifi/passwd'))

    local auth = luci.http.getenv("HTTP_AUTHORIZATION")        
    auth = auth and auth:match("[^ ]+[ ]+([%w+/=]+)")            
    auth = auth and nixio.bin.b64decode(auth)                  
                                                                       
    if not auth or tostring(auth) ~= password then                  
       
      -- need auth info                                  
      luci.http.status(401, "Unauthorized")              
      luci.http.header("WWW-Authenticate", 'Basic realm="Secure Area"')
      luci.http.header("Content-Type", "text/plain")     
      luci.http.write("Login Required!")                 
      return false                                       
    else                                                               
        -- user/pass ok                                             
        return page.sysauth                                              
    end         
  end
	
	page.index = true
	
	entry({"peopleswifi", "index"}, form("peopleswifi/index"), _("General"), 1).ignoreindex = true
	entry({"peopleswifi", "index", "logout"}, call("action_logout"), _("Logout"))
end

function action_logout()
	local dsp = require "luci.dispatcher"
	local sauth = require "luci.sauth"
	if dsp.context.authsession then
		sauth.kill(dsp.context.authsession)
		dsp.context.urltoken.stok = nil
	end

	luci.http.header("Set-Cookie", "sysauth=; path=" .. dsp.build_url())
	luci.http.redirect(luci.dispatcher.build_url())
end
