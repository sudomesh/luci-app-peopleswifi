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

module("luci.controller.peopleswifi.system", package.seeall)

function index()
	entry({"peopleswifi", "system"}, alias("peopleswifi", "system", "index"), _("System"), 40).index = true
	entry({"peopleswifi", "system", "passwd"}, form("peopleswifi/passwd"), _("Admin Password"), 10)
	entry({"peopleswifi", "system", "reboot"}, call("action_reboot"), _("Reboot"), 100)
end

function action_reboot()
	local reboot = luci.http.formvalue("reboot")
	luci.template.render("peopleswifi/reboot", {reboot=reboot})
	if reboot then
		luci.sys.reboot()
	end
end


