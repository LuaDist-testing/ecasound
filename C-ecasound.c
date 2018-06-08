/*
    C-ecasound.c -  ecasound-iam  bindings for Lua

   This Lua5 module is Copyright (c) 2013, Peter J Billam
                     www.pjb.com.au

 This module is free software; you can redistribute it and/or
       modify it under the same terms as Lua5 itself.
*/

#include <lua.h>
#include <lauxlib.h>
/* #include <string.h>  strlen() & friends, including strerror */
/* #include <unistd.h>  isatty() */

/* --------------- from man ecasound-iam -------------------- */
#include <libecasoundc/ecasoundc.h>
#include <stdio.h>
/* see ~/lua/ecasound-0.0/cpan/Ecasound.xs */
/* lint with     splint C-ecasound.c -I/usr/local/include   */

static int c_eci_init(lua_State *L) {
	int is_on = lua_toboolean(L, 1);
	is_on +=1;
	return 1;
}
static int c_eci_cleanup(lua_State *L) {
	int is_on = lua_toboolean(L, 1);
	is_on +=1;
	return 1;
}
static int c_eci_command(lua_State *L) {
	size_t * len;
	const char *cmd = lua_tolstring(L, 1, len);
	eci_command(cmd);  /* if error, it should return a string */
	/* lua_pushstring(L, eci_last_string(cmd)); */
	return 0;
}
static int c_eci_command_float_arg(lua_State *L) {
	int is_on = lua_toboolean(L, 1);
	is_on +=1;
	return 1;
}
static int c_eci_last_float(lua_State *L) {
	int is_on = lua_toboolean(L, 1);
	is_on +=1;
	return 1;
}
static int c_eci_last_integer(lua_State *L) {
	int is_on = lua_toboolean(L, 1);
	is_on +=1;
	return 1;
}
static int c_eci_last_long_integer(lua_State *L) {
	int is_on = lua_toboolean(L, 1);
	is_on +=1;
	return 1;
}
static int c_eci_last_string(lua_State *L) {
	int is_on = lua_toboolean(L, 1); is_on +=1;
	lua_pushstring(L, eci_last_string());
	return 1;
}
static int c_eci_last_string_list_count(lua_State *L) {
	int is_on = lua_toboolean(L, 1);
	is_on +=1;
	return 1;
}
static int c_eci_last_string_list_item(lua_State *L) {
	int is_on = lua_toboolean(L, 1);
	is_on +=1;
	return 1;
}
static int c_eci_last_type(lua_State *L) {
	int is_on = lua_toboolean(L, 1);
	is_on +=1;
	return 1;
}
static int c_eci_error(lua_State *L) {
	int is_on = lua_toboolean(L, 1);
	is_on +=1;
	return 1;
}
static int c_cs_status(lua_State *L) {
	int is_on = lua_toboolean(L, 1);  is_on +=1;
	eci_command("cs-status");  /* ' does not work, see K&R p.17 */
	lua_pushstring(L, eci_last_string());
	return 1;
}
static int c_engine_status(lua_State *L) {
	int is_on = lua_toboolean(L, 1);  is_on +=1;
	eci_command("engine-status");
	lua_pushstring(L, eci_last_string());    /* no; must be different */
	return 1;
}

/* ----------------- evolved from C-midialsa.c ---------------- */
struct constant {  /* Gems p. 334 */
    const char * name;
    int value;
};
static const struct constant constants[] = {
    /* {"Version", Version}, */
    {NULL, 0}
};

static const luaL_Reg prv[] = {  /* private functions */
    {"eci_init",                   c_eci_init},
    {"eci_cleanup",                c_eci_cleanup},
    {"eci_command",                c_eci_command},
    {"eci_command_float_arg",      c_eci_command_float_arg},
    {"eci_last_float",             c_eci_last_float},
    {"eci_last_integer",           c_eci_last_integer},
    {"eci_last_long_integer",      c_eci_last_long_integer},
    {"eci_last_string",            c_eci_last_string},
    {"eci_last_string_list_count", c_eci_last_string_list_count},
    {"eci_last_string_list_item",  c_eci_last_string_list_item},
    {"eci_last_type",              c_eci_last_type},
    {"eci_error",                  c_eci_error},
    {"cs_status",                  c_cs_status},
    {"engine_status",              c_engine_status},
    {NULL, NULL}
};

static int initialise(lua_State *L) {  /* Lua Programming Gems p. 335 */
    /* Lua stack: aux table, prv table, dat table */
    int index;  /* define constants in module namespace */
    for (index = 0; constants[index].name != NULL; ++index) {
        lua_pushinteger(L, constants[index].value);
        lua_setfield(L, 3, constants[index].name);
    }
    /* lua_pushvalue(L, 1);   * set the aux table as environment */
    /* lua_replace(L, LUA_ENVIRONINDEX);
       unnecessary here, fortunately, because it fails in 5.2 */
    lua_pushvalue(L, 2); /* register the private functions */
#if LUA_VERSION_NUM >= 502
    luaL_setfuncs(L, prv, 0);    /* 5.2 */
    return 0;
#else
    luaL_register(L, NULL, prv); /* 5.1 */
    return 0;
#endif
}

int luaopen_ecasound(lua_State *L) {
    lua_pushcfunction(L, initialise);
    return 1;
}

