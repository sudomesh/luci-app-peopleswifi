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

module("luci.controller.peopleswifi.network", package.seeall)

function index()
	entry({"peopleswifi", "network"}, alias("peopleswifi", "network", "index"), _("Network"), 20).index = true
	entry({"peopleswifi", "network", "wifi"}, cbi("peopleswifi/wifi", {autoapply=true}), _("Wifi Settings"), 10)
end
