---------------------------------------------------------------------
--     This Lua5 module is Copyright (c) 2017, Peter J Billam      --
--                       www.pjb.com.au                            --
--  This module is free software; you can redistribute it and/or   --
--         modify it under the same terms as Lua5 itself.          --
---------------------------------------------------------------------
-- Example usage:
-- local E = require 'ecasound'
-- E.eci(')

local M = {} -- public interface
M.Version = '0.2'
M.VersionDate = '28jan2017'

local P = require 'posix'

------------------------------ private ------------------------------
function warn(...)
    local a = {}
    for k,v in pairs{...} do table.insert(a, tostring(v)) end
    io.stderr:write(table.concat(a),'\n') ; io.stderr:flush()
end
function die(...) warn(...);  os.exit(1) end
function qw(s)  -- t = qw[[ foo  bar  baz ]]
    local t = {} ; for x in s:gmatch("%S+") do t[#t+1] = x end ; return t
end
local function split(s, pattern, maxNb) -- http://lua-users.org/wiki/SplitJoin
    if not s or string.len(s)<2 then return {s} end
    if not pattern then return {s} end
    if maxNb and maxNb <2 then return {s} end
    local result = { }
    local theStart = 1
    local theSplitStart,theSplitEnd = string.find(s,pattern,theStart)
    local nb = 1
    while theSplitStart do
        table.insert( result, string.sub(s,theStart,theSplitStart-1) )
        theStart = theSplitEnd + 1
        theSplitStart,theSplitEnd = string.find(s,pattern,theStart)
        nb = nb + 1
        if maxNb and nb >= maxNb then break end
    end
    table.insert( result, string.sub(s,theStart,-1) )
    return result
end
local function which(s)
    local f
    for i,d in ipairs(split(os.getenv('PATH'), ':')) do
        f=d..'/'..s; if P.access(f, 'x') then return f end
    end
end

----------------- from Lua Programming Gems p. 331 ----------------
local require, table = require, table -- save the used globals
local aux, prv = {}, {} -- auxiliary & private C function tables
local initialise = require 'C-ecasound'
initialise(aux, prv, M) -- initialise the C lib with aux,prv & module tables

------------------------------ public ------------------------------
local e = which("ecasound")
if not e then die ("can't find ecasound in your PATH") end
if not os.getenv("ECASOUND") then P.setenv("ECASOUND", e) end
-- print(os.getenv("ECASOUND"))

-- Constructing and destructing
function M.eci_init()
	prv.eci_init()
end
function M.eci_ready()
	prv.eci_ready()
end
function M.eci_cleanup()
	prv.eci_cleanup()
end

-- The Do-Everything Workhorse function
function M.eci(str, float)
	if type(str) ~= 'string' then
		die("M.eci: str was "..tostring(str))
	end
	if float and type(float) ~= 'number' then
		die("M.eci: 2nd arg was a "..type(float)..", should be a number")
	end
	return prv.eci(str, float)
end

-- Events
function M.events_available()
	return prv.events_available()
end
function M.next_event()
	return prv.next_event()
end
function M.current_event()
	return prv.current_event()
end

return M

--[=[
DOESNT WORK FOR ME...
In addition to the ECI commands as listed below,
commands can also be written in the form of their C<ecasound> command-line
arguments, for example
C<E.eci("-i:some_file.wav")>


=pod

=head2 NAME

ecasound.lua - Provides access to the ecasound interactive mode

=head2 SYNOPSIS

 local E = require 'ecasound'
 E.eci_init()
 E.eci("cs-add play_chainsetup")
 E.eci("c-add 1st_chain")
 E.eci("ai-add /tmp/t.wav")
 E.eci("ao-add /dev/dsp")
 E.eci("cop-add -efl:100")  -- add a chain operator
 E.eci("cop-select 1")
 E.eci("copp-select 1")  -- parameter 1 means the 100Hz
 print("aio-status = "..E.eci("aio-status"))
 E.eci("start")
 while (true) do
     os.execute("sleep 1")
     if E.eci("engine-status") ~= "running" then break end
     if E.eci("get-position") > 150 then break end
     E.eci("copp-set", 100+E.eci("copp-get"))   -- optional float argument
 end
 E.eci("stop")
 E.eci_cleanup()

=head2 DESCRIPTION

This module offers in Lua most of the functions defined in eg:
C</usr/include/libecasoundc/ecasoundc.h>, except
B<1)> instead of eci_command() it is abbreviated to eci(),
and
B<2)> those functions concerned with the return-types and return-values
are not offered, all this being handled internally by
C<eci("command string")>, which returns a Lua string,
or array of strings, or number, according to the command given.

Errors are reported by returning B<nil, 'error-string'>
as is needed by the Lua B<assert()> function.
Therefore, commands in the C library which really do return nothing,
here in C<ecasound.lua> return not C<nil>, but a zero-length string.

=head2 FUNCTIONS

=head3 Constructing and destructing

=over 3

=item I<eci_init()>

returns nothing

=item I<eci_ready()>

returns an integer

=item I<eci_cleanup()>

returns nothing

=back

=head3 The Do-Everything Workhorse function

=over 3

=item I<eci("commandstring")>

=item I<eci("commandstring", 987.654)>

There are about 200 available commands, see ECI COMMANDS below.

Some commands need a number as an argument,
and this should go as a second argument
as in the second example (eg: C<eci("copp-set", next_cutoff)>)

=back

=head3 Events

=over 3

=item I<eci_events_available()>

Returns an integer, the number of events available.

=item I<eci_next_event()>

Moves the I<ecasound> engine on to the next event; returns nothing.

=item I<eci_current_event()>

Returns a string.

=back

=head2 ECI COMMANDS

See C<man ecasound-iam>

This is a list of the ECI commands offered by my system (debian stable):

=over 3

C<ai-add
ai-attach
ai-describe
ai-forward
ai-get-format
ai-get-length
ai-get-length-samples
ai-get-position
ai-get-position-samples
ai-getpos
ai-index-select
ai-iselect
ai-list
ai-remove
ai-rewind
ai-select
ai-selected
ai-set-position
ai-set-position-samples
ai-setpos
ai-status
ai-wave-edit
aio-register
aio-status
ao-add
ao-add-default
ao-attach
ao-describe
ao-forward
ao-get-format
ao-get-length
ao-get-length-samples
ao-get-position
ao-get-position-samples
ao-getpos
ao-index-select
ao-iselect
ao-list
ao-remove
ao-rewind
ao-select
ao-selected
ao-set-position
ao-set-position-samples
ao-setpos
ao-status
ao-wave-edit>

C<c-add
c-bypass
c-clear
c-deselect
c-index-select
c-is-bypassed
c-is-muted
c-iselect
c-list
c-mute
c-muting
c-remove
c-rename
c-select
c-select-add
c-select-all
c-selected
c-status
cop-add
cop-bypass
cop-describe
cop-get
cop-index-select
cop-is-bypassed
cop-iselect
cop-list
cop-register
cop-remove
cop-select
cop-selected
cop-set
cop-status
copp-get
copp-index-select
copp-iselect
copp-list
copp-select
copp-selected
copp-set>

C<cs
cs-add
cs-connect
cs-connected
cs-disconnect
cs-edit
cs-forward
cs-get-length
cs-get-length-samples
cs-get-position
cs-get-position-samples
cs-getpos
cs-index-select
cs-is-valid
cs-iselect
cs-list
cs-load
cs-option
cs-remove
cs-rewind
cs-save
cs-save-as
cs-select
cs-selected
cs-set-audio-format
cs-set-length
cs-set-length-samples
cs-set-param
cs-set-position
cs-set-position-samples
cs-setpos
cs-status
cs-toggle-loop>

C<ctrl-add
ctrl-describe
ctrl-get-target
ctrl-index-select
ctrl-iselect
ctrl-list
ctrl-register
ctrl-remove
ctrl-select
ctrl-selected
ctrl-status
ctrlp-get
ctrlp-list
ctrlp-select
ctrlp-selected
ctrlp-set
debug
dump-ai-length
dump-ai-open-state
dump-ai-position
dump-ai-selected
dump-ao-length
dump-ao-open-state
dump-ao-position
dump-ao-selected
dump-c-selected
dump-cop-value
dump-cs-status
dump-length
dump-position
dump-status
dump-target
engine-halt
engine-launch
engine-status
es
forward
fs
fw
get-length
get-position
getpos
h
help
int-cmd-list
int-log-history
int-output-mode-wellformed
int-set-float-to-string-precision
int-set-log-history-length
int-version-lib-age
int-version-lib-current
int-version-lib-revision
int-version-string
jack-connect
jack-disconnect
jack-list-connections
ladspa-register
lv2-register
map-cop-list
map-ctrl-list
map-ladspa-id-list
map-ladspa-list
map-lv2-list
map-preset-list
preset-register
q
quit
resource-file
rewind
run
rw
s
set-position
setpos
st
start
status
stop
stop-sync
t>

=back

=head2 DOWNLOAD

This module is available on
https://luarocks.org/
so you should be able to install it with

C<luarocks install ecasound>

or:

C<luarocks install http://www.pjb.com.au/comp/lua/ecasound-0.2-0.rockspec>

If this results in an error message such as:

  Error: Could not find expected file libecasound.a, or libecasound.so,
  or libecasound.so.* for ecasound -- you may have to install ecasound in
  your system and/or pass ECAS_DIR or ECAS_LIBDIR to the luarocks command.
  Example: luarocks install ecasound ECAS_DIR=/usr/local

then you need to find the appropriate directory with:

  find /usr/lib -name 'libecasound.*' -print
  find /usr/local/lib -name 'libecasound.*' -print

and then invoke:

  luarocks install \
  http://www.pjb.com.au/comp/lua/ecasound-0.2-0.rockspec \
  ECAS_LIBDIR=/usr/lib/i386-linux-gnu/ # or wherever

accordingly. 

=head2 AUTHOR

Peter J Billam, http://www.pjb.com.au/comp/contact.html

=head2 SEE ALSO

 apt-get install ecasound-doc libecasoundc-dev
 man ecasound-iam
 https://sourceforge.net/p/ecasound/mailman/
 http://search.cpan.org/perldoc?Audio::Ecasound
 http://www.eca.cx/ecasound/
 http://www.pjb.com.au/comp/lua/ecasound.html
 https://luarocks.org/modules/peterbillam
 https://luarocks.org/
 http://www.pjb.com.au/


=cut

]=]

