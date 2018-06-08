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
M.Version = '1.0'
M.VersionDate = '23jan2017'

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
print(os.getenv("ECASOUND"))

function M.eci_init()
	prv.eci_init()
end

function M.eci_cleanup()
	prv.eci_cleanup()
end

function M.eci_command()
	prv.eci_command()
	return prv.eci_last_string();
end

function M.cs_status()
	return prv.cs_status()
end

return M

--[=[

=pod

=head1 NAME

ecasound.lua - does whatever

=head1 SYNOPSIS

 local E = require 'ecasound'
 a = { 6,8,7,9,8 }
 b = { 4,7,5,4,5,6,4 }
 local probability_of_hypothesis_being_wrong = E.ttest(a,b,'b>a')

=head1 DESCRIPTION

This module does whatever

=head1 FUNCTIONS

=over 3

=item I<ttest(a,b, hypothesis)>

The arguments I<a> and I<b> are arrays of numbers

The I<hypothesis> can be one of 'a>b', 'a<b', 'b>a', 'b<a',
'a~=b' or 'a<b'.

I<ttest> returns the probability of your hypothesis being wrong.

=back

=head1 DOWNLOAD

This module is available at
http://www.pjb.com.au/comp/lua/ecasound.html

or:
  # luarocks install http://www.pjb.com.au/comp/lua/ecasound-0.1-0.rockspec

If this results in an error message such as:

  Error: Could not find expected file libecasound.a, or libecasound.so,
  or libecasound.so.* for ecasound -- you may have to install ecasound in
  your system and/or pass ECAS_DIR or ECAS_LIBDIR to the luarocks command.
  Example: luarocks install ecasound ECAS_DIR=/usr/local

then you need to find the appropriate directory with:

  find /usr/lib -name 'libecasound.*' -print

and then invoke:

  luarocks install \
  http://www.pjb.com.au/comp/lua/ecasound-0.1-0.rockspec \
  ECAS_LIBDIR=/usr/lib/i386-linux-gnu/ # or wherever

accordingly. 

=head1 AUTHOR

Peter J Billam, http://www.pjb.com.au/comp/contact.html

=head1 SEE ALSO

 apg-get install ecasound-doc libecasoundc-dev
 man ecasound-iam
 http://www.pjb.com.au/


=cut

]=]

