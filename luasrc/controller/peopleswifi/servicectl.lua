--[[
sudomesh LuCI extension

Copyright 2010 Jo-Philipp Wich <xm@subsignal.org>
Copyright 2013-2014 Max B <maxb.personal@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id: servicectl.lua 9558 2012-12-18 13:58:22Z jow $
]]--

module("luci.controller.peopleswifi.servicectl", package.seeall)

function index()
	entry({"servicectl"}, alias("servicectl", "status")).sysauth = "admin"
	entry({"servicectl", "status"}, call("action_status")).leaf = true
	entry({"servicectl", "restart"}, call("action_restart")).leaf = true
end

function action_status()
	local data = nixio.fs.readfile("/var/run/luci-reload-status")
	if data then
		luci.http.write("/etc/config/")
		luci.http.write(data)
	else
		luci.http.write("finish")
	end
end

function action_restart(args)
	local uci = require "luci.model.uci".cursor()
	if args then
		local service
		local services = { }

		for service in args:gmatch("[%w_-]+") do
			services[#services+1] = service
		end

		local command = uci:apply(services, true)
		if nixio.fork() == 0 then
			local i = nixio.open("/dev/null", "r")
			local o = nixio.open("/dev/null", "w")

			nixio.dup(i, nixio.stdin)
			nixio.dup(o, nixio.stdout)

			i:close()
			o:close()

			nixio.exec("/bin/sh", unpack(command))
		else
			luci.http.write("OK")
			os.exit(0)
		end
	end
end
