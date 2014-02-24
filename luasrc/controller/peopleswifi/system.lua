--[[
sudomesh LuCI extension

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>
Copyright 2013-2014 Max B <maxb.personal@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.peopleswifi.system", package.seeall)

function index()
	entry({"peopleswifi", "system"}, alias("peopleswifi", "system", "index"), _("System"), 40).index = true
	entry({"peopleswifi", "system", "reboot"}, call("action_reboot"), _("Reboot"), 100)
	entry({"peopleswifi", "system", "admin"}, cbi("peopleswifi/system"), _("Admin Password"), 2)
end

function action_reboot()
	local reboot = luci.http.formvalue("reboot")
	luci.template.render("peopleswifi/reboot", {reboot=reboot})
	if reboot then
		luci.sys.reboot()
	end
end

function action_passwd()
	local p1 = luci.http.formvalue("pwd1")                  
        local p2 = luci.http.formvalue("pwd2")                  
        local stat = nil
                                                                        
        if p1 or p2 then                                         
             if p1 == p2 then                                                  
                 stat = luci.sys.user.setpasswd("admin", p1)
             else
	                stat = 10                             
             end                                                            
        end

	luci.template.render("admin_system/passwd", {stat=stat})
end
