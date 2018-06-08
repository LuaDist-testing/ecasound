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

local Test = 31 ; local i_test = 0; local Failed = 0;
function ok(b,s)
	i_test = i_test + 1
	if b then
		io.write('ok '..i_test..' - '..s.."\n")
	else
		io.write('not ok '..i_test..' - '..s.."\n")
		Failed = Failed + 1
	end
	return b
end


local E = require("ecasound")
local rv = E.eci_init()
ok(rv == '', "eci('ai-init') returned the empty string")
--  print(type(rv)) ; print('rv =',rv)

local cmd_list = E.eci("int-cmd-list")
-- for i,v in ipairs(cmd_list) do print(v) end
ok(#cmd_list > 190, 'E.eci("int-cmd-list") returns more than 190 commands')
rv = E.eci("cs-add play_chainsetup") 
ok(rv == '', 'eci("cs-add play_chainsetup") returned the empty string')
rv = E.eci("cs-select play_chainsetup") 
ok(rv == '', 'eci("cs-select play_chainsetup") returned the empty string')
rv = E.eci("c-add 1st_chain")
ok(rv == '', 'eci("cs-add 1st_chain") returned the empty string')
-- rv = E.eci("c-add 2nd_chain")
rv = E.eci("c-select 1st_chain")
ok(rv == '', 'eci("cs-select 1st_chain") returned the empty string')

--  print('about to -i')
--  assert(E.eci("-i:/tmp/t.wav"))
--  ERROR: Audio object "/tmp/t.wav 0.00000000000000" does not match any of
--  the known audio device types or file formats. You can check the list
--  of supported audio object types by issuing the command 'aio-register'
--  in ecasound's interactive mode.
--  print('about to -o')
--  assert(E.eci("-o:/tmp/u.wav"))
-- pjb: so where does the 0.00000000000000 come from ?
rv,es = io.open('/tmp/t.wav', 'r')
if not rv then
	print(es)
	print('You need to copy some .wav file (>4sec) to /tmp/t.wav')
	os.exit(1)
end
rv = E.eci("ai-add /tmp/t.wav")
ok(rv == '', "eci('ai-add /tmp/t.wav') returned the empty string")
rv = E.eci("ai-select 1")
ok(rv == '', 'eci("ai-select 1") returned the empty string')
-- E.eci("ao-add alsa,0,3,1")   --  Device busy :-(
-- E.eci("ao-add jack,system,out")
rv = E.eci("ao-add /dev/dsp")
ok(rv == '', "eci('ao-add /dev/dsp') returned the empty string")
rv = E.eci("ao-select 1")
ok(rv == '', 'eci("ao-select /dev/dsp") returned the empty string')

rv = E.eci("cop-add -efl:100")
ok(rv == '', "eci('cop-add -efl:100') returned the empty string")
rv = E.eci("cop-select 1")
ok(rv == '', 'eci("cop-select 1") returned the empty string')
--   for i,v in ipairs(E.eci("cop-list")) do print(v) end
local num_selected = E.eci("cop-selected")
ok(num_selected == 1, 'num_selected was 1')
rv = E.eci("copp-select 1")
ok(rv == '', 'eci("copp-select 1") returned the empty string')
rv = E.eci("copp-selected")
ok(rv == 1, 'copp-selected was 1')
rv = E.eci("engine-status")
ok(rv == 'not started', 'engine-status was '..tostring(rv))
-- https://sourceforge.net/p/ecasound/mailman/ecasound-list/thread/515B8B7B.70302%40netscape.net/#msg30674653
rv = E.eci("aio-status")
print("aio-status = "..rv)
rv = E.eci("c-list")
ok(#rv == 1, "c-list contains just one chain") ;
ok(rv[1] == '1st_chain', "1st item in c-list is '1st_chain'") ;
-- for i,v in ipairs(rv) do print(i, v) end

print("cs-status = "..E.eci("cs-status"))
rv = E.eci("cs-is-valid")
ok(rv == true, 'eci("cs-is-valid") returned true')
rv,es = E.eci("cs-connect")
ok(rv == '', 'eci("connect") returned the empty string')

rv,es = (E.eci("start"))
ok(rv == '', 'eci("start") returned the empty string')
-- assert(E.eci("engine-launch"))
-- print("engine_status = ", E.eci("engine-status")) -- stopped? WHY? too soon?
rv = E.eci("get-position")
ok(rv < 0.5, 'eci("get-position") returned zero')
local freq_ratio = 1.2
while (true) do
	os.execute("sleep 1")
	rv = E.eci("engine-status")
	ok(rv == 'running', 'eci("engine-status") returned "running"')
	if rv ~= "running" then break end
	if E.eci("get-position") > 3.5 then break end
	local freq = E.eci("copp-get")
	if freq < 80 then break end
	if freq > 10000 then freq_ratio = 0.8333 end
	rv = E.eci("copp-set", freq_ratio*freq)   -- optional float argument
	ok(rv == '', 'eci("copp-set") returned the empty string')
end
rv = E.eci("stop")
ok(rv == '', 'eci("stop") returned the empty string')
rv = E.eci_cleanup()
ok(rv == '', 'eci_cleanup() returned the empty string')
if Failed > 0.5 then print('Failed '..tostring(Failed)..' tests') end

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
