#!/usr/local/bin/lua
---------------------------------------------------------------------
--     This Lua5 script is Copyright (c) 2017, Peter J Billam      --
--                       www.pjb.com.au                            --
--  This script is free software; you can redistribute it and/or   --
--         modify it under the same terms as Lua5 itself.          --
---------------------------------------------------------------------
local Version = '1.0  for Lua5'
local VersionDate  = '23jan2017';
local Synopsis = [[
test_ecasound [options] [filenames]
]]
local iarg=1; while arg[iarg] ~= nil do
	if not string.find(arg[iarg], '^-[a-z]') then break end
	local first_letter = string.sub(arg[iarg],2,2)
	if first_letter == 'v' then
		local n = string.gsub(arg[0],"^.*/","",1)
		print(n.." version "..Version.."  "..VersionDate)
		os.exit(0)
	elseif first_letter == 'c' then
		whatever()
	else
		local n = string.gsub(arg[0],"^.*/","",1)
		print(n.." version "..Version.."  "..VersionDate.."\n\n"..Synopsis)
		os.exit(0)
	end
	iarg = iarg+1
end

local E = require("ecasound")
E.eci_init()
--  for k,v in pairs(E) do print(k) end

print('about to int_cmd_list')
local cmd_list = E.eci("int-cmd-list")
-- for i,v in ipairs(cmd_list) do print(v) end
-- os.execute('sleep 1')
print('about to cs-add play_chainsetup and cs-select play_chainsetup')
E.eci("cs-add play_chainsetup") 
E.eci("cs-select play_chainsetup") 
print('about to c-add and c-select')
E.eci("c-add 1st_chain")
E.eci("c-select 1st_chain")

--  print('about to -i')
--  assert(E.eci("-i:/tmp/t.wav"))
--  ERROR: Audio object "/tmp/t.wav 0.00000000000000" does not match any of
--  the known audio device types or file formats. You can check the list
--  of supported audio object types by issuing the command 'aio-register'
--  in ecasound's interactive mode.
--  print('about to -o')
--  assert(E.eci("-o:/tmp/u.wav"))
-- pjb: so where does the 0.00000000000000 come from ?
print('about to ai-add and ai-select')
E.eci("ai-add /tmp/t.wav")
E.eci("ai-select 1")
print('about to ao-add and ao-select')
E.eci("ao-add alsa,0,3,1")   --  Device busy :-(
-- E.eci("ao-add jack,system,out")
-- E.eci("ao-add /dev/dsp")
E.eci("ao-select 1")

-- E.eci("cop-add -efl:100")
-- E.eci("cop-select 1")
--   local cops = E.eci("cop-list")
--   for i,v in ipairs(cops) do print(v) end
-- local num_selected = E.eci("cop-selected")
-- print("num_selected = ", num_selected)
E.eci("copp-select 1")
print("copp_selected = ", E.eci("copp-selected"))
print("engine_status = ", E.eci("engine-status"))
-- https://sourceforge.net/p/ecasound/mailman/ecasound-list/thread/515B8B7B.70302%40netscape.net/#msg30674653
-- if you ask cs-is-valid, and Ecasound returns 0,
-- then it means that cs-connect will *not* work.
print("ai-list = ") ; for i,v in ipairs(E.eci("ai-list")) do print(v) end
print("ao-list = ") ; for i,v in ipairs(E.eci("ao-list")) do print(v) end
print("aio-status = "..E.eci("aio-status"))
--print("ao-status = "..E.eci("ao-status"))
print("c-list = ") ; for i,v in ipairs(E.eci("c-list")) do print(v) end
print("cs-is-valid = "..E.eci("cs-is-valid"))
print("cs-status = "..E.eci("cs-status"))
E.eci("cs-connect")

if E.eci("cs-is-valid") > 0.5 then
	print('about to start')
	assert(E.eci('start'))
	-- assert(E.eci("engine-launch"))
	print("engine_status = ", E.eci("engine-status"))  -- stopped? WHY?
	print("get-position = "..E.eci("get-position"))
	local cutoff_inc = 5000.0
	while (true) do
		print("engine_status = ", E.eci("engine-status"))
		os.execute('sleep 10')
		print("get-position = "..E.eci("get-position"))
		if E.eci("engine-status") ~= "running" then break end
	end
end
print("engine_status = ", E.eci("engine-status"))
print('about to eci_cleanup')
E.eci_cleanup()

--[=[

=pod

=head1 NAME

test_ecasound - Tests ecasound.lua, an interface to ecasound-iam

=head1 SYNOPSIS

 test_ecasound

=head1 DESCRIPTION

This script

=head1 ARGUMENTS

=over 3

=item I<-v>

Print the Version

=back

=head1 DOWNLOAD

This at is available at

=head1 AUTHOR

Peter J Billam, http://www.pjb.com.au/comp/contact.html

=head1 SEE ALSO

 http://www.pjb.com.au/

=cut

]=]
