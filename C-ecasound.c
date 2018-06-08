/*
    C-ecasound.c -  ecasound-iam  bindings for Lua

   This Lua5 module is Copyright (c) 2013, Peter J Billam
                     www.pjb.com.au

 This module is free software; you can redistribute it and/or
       modify it under the same terms as Lua5 itself.
*/

#include <lua.h>
#include <lauxlib.h>
#include <stdlib.h>
/* #include <string.h>  strlen() & friends, including strerror */
/* #include <unistd.h>  isatty() */
/* --------------- from man ecasound-iam -------------------- */
#include <libecasoundc/ecasoundc.h>
#include <stdio.h>
/* see ~/lua/ecasound-0.0/cpan/Ecasound.xs */
/* lint with     splint C-ecasound.c -I/usr/local/include   */

/* Constructing and destructing */
static int c_eci_init(lua_State *L) {
	eci_init();
	if ( eci_error() > 0 ) {  /* it returns int, not boolean */
		const char *err = eci_last_error();
		fprintf( stderr, "init Error: %s\n", err );
		exit(EXIT_FAILURE);
	}
	return 1;
}
static int c_eci_ready(lua_State *L) {
	const int i = eci_ready();
	lua_pushinteger(L, i);
	return 1;
}
static int c_eci_cleanup(lua_State *L) {
	eci_cleanup();
	lua_pushnil(L);
	return 1;
}

/* The Do-Everything Workhorse function */
static int c_eci(lua_State *L) {
	size_t len;
	const char *cmd  = lua_tolstring(L, 1, &len);  /* Parse Error ? */
	if (lua_gettop(L) == 1)  {
		eci_command(cmd);
	} else {
		double num = lua_tonumber(L, 2);
		eci_command_float_arg(cmd, num);
	}
	const char *type = eci_last_type();
	char type1 = type[0];
	switch (type1) {  /* see "man ecasound-iam" for these types */
	case 's':
		lua_pushstring(L, eci_last_string());
		return 1;
	case 'S':
		/* you cannot declare variables as the first line inside of a switch
		statement's case statement! (which, at it's heart, is just a label);
		You can declare them _inside_ the case statement, they just cannot
		directly follow the label. */
		lua_newtable(L);  /* the result table is now top of stack */
		int n = eci_last_string_list_count();
		fprintf( stderr, "eci_last_string_list_count: %d\n", n );
		int i = 1;
		while (i<=n) {
			lua_pushnumber(L, i);
			lua_pushstring(L, eci_last_string_list_item(i));
			lua_settable(L, -3);  /* don't understand this */
			i = i+1;
		}
		return 1;  /* the table is already on top */
	case 'i':
	case 'l':
		lua_pushinteger(L, eci_last_integer());
		return 1;
	case 'f':
		lua_pushnumber(L, eci_last_float());
		return 1;
	case 'e':
		lua_pushnil(L);
		lua_pushstring(L, eci_last_error());
		return 2;
	case '-':   /* must not return nil, to avoid looking like an error */
		lua_pushstring(L, "");
		return 1;
	default:
		fprintf( stderr, "eci_last_type: %s\n", type );
		return 0;
	}
}
static int c_eci_command_float_arg(lua_State *L) {
	int is_on = lua_toboolean(L, 1);
	is_on +=1;
	return 1;
}

/* Events */
static int c_eci_events_available(lua_State *L) {
	int i_available = eci_events_available();
	lua_pushinteger(L, i_available);
	return 1;
}
static int c_eci_next_event(lua_State *L) {
	lua_pushnil(L);
	return 1;
}
static int c_eci_current_event(lua_State *L) {
	const char * str = eci_current_event();
	lua_pushstring(L, str);
	return 1;
}

static int c_eci_error(lua_State *L) { /* still needed ? */
	int is_on = lua_toboolean(L, 1);
	is_on +=1;
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
    {"eci_ready",                  c_eci_ready},
    {"eci_cleanup",                c_eci_cleanup},
    {"eci",                        c_eci},
    {"eci_command_float_arg",      c_eci_command_float_arg},
    {"eci_events_available",       c_eci_events_available},
    {"eci_next_event",             c_eci_next_event},
    {"eci_current_event",          c_eci_current_event},
    {"eci_error",                  c_eci_error},
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

