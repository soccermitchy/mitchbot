#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <pthread.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>

static int memlimit = 0;
static int memwatching = 0;
static int memused = 0;

void *alloc(void *ud, void *ptr, size_t osize, size_t nsize)
{
	if(nsize)
	{
		if(memwatching)
		{
			if(memused + nsize - osize> memlimit)
				return NULL;
			memused += nsize - osize;
		}
		return realloc(ptr, nsize);
	}
	else
	{
		if(memwatching)
			memused -= osize;
		free(ptr);
		return NULL;
	}
}

static int panic(lua_State *l)
{
  (void)l;
  printf("PANIC: unprotected error in call to Lua API (%s)\n", lua_tostring(l, -1));
  return 0;
}

int luaL_tostring (lua_State *L, int n)
{
	luaL_checkany(L, n);
	switch (lua_type(L, n)) {
		case LUA_TNUMBER:
			lua_pushstring(L, lua_tostring(L, n));
			break;
		case LUA_TSTRING:
			lua_pushvalue(L, n);
			break;
		case LUA_TBOOLEAN:
			lua_pushstring(L, (lua_toboolean(L, n) ? "true" : "false"));
			break;
		case LUA_TNIL:
			lua_pushliteral(L, "nil");
			break;
		default:
			lua_pushfstring(L, "%s: %p", lua_typename(L, lua_type(L, n)), lua_topointer(L, n));
			break;
	}
	return 1;
}

static lua_State *guestL;

void *thread(void *n)
{
	int p = lua_gettop(guestL);
	if(lua_pcall(guestL, 0, LUA_MULTRET, 0))
	{
		luaL_tostring(guestL, -1);
		printf("runtime error: %s\n", lua_tostring(guestL, -1));
		lua_pop(guestL, 1);
	}
	else
	{
		int c = lua_gettop(guestL);
		for(;c >= p;p++)
		{
			luaL_tostring(guestL, p);
			printf("%s\n", lua_tostring(guestL, -1));
			lua_pop(guestL, 1);
		}
	}
}

int sandbox(lua_State *hostL)
{
	const char *init = luaL_optstring(hostL, 1, "");
	const char *code = luaL_optstring(hostL, 2, "");
	memlimit = luaL_optint(hostL, 3, 5000000);
	memwatching = 0;
	int timelimit = luaL_optint(hostL, 4, 500);

	guestL = lua_newstate(&alloc, NULL);
	lua_atpanic(guestL, &panic);
	luaL_openlibs(guestL);
	luaL_dostring(guestL, init);
	if (luaL_loadbuffer(guestL, code, strlen(code), "@sandbox"))
	{
		printf("syntax error: %s\n", lua_tostring(guestL, -1));
		return 0;
	}

	memused = 0;
	memwatching = 1;
	int oldout = dup(1);
	int out[2];
	pipe2(&out, O_NONBLOCK);
	dup2(out[1], 1);

	pthread_t th;
	pthread_create(&th, NULL, &thread, NULL);
	struct timespec ts;
	clock_gettime(CLOCK_REALTIME, &ts);
	ts.tv_nsec += (timelimit%1000)*1000000;
	ts.tv_sec += timelimit/1000 + ts.tv_nsec/1000000000;
	ts.tv_nsec = ts.tv_nsec % 1000000000;
	if(pthread_timedjoin_np(th, NULL, &ts))
	{
		pthread_cancel(th);
		printf("time limit exceeded\n");
	}

	dup2(oldout, 1);
	close(out[1]);
	char *result = NULL;
	char buffer[256];
	int sz, size = 0;
	while(0 < (sz = read(out[0], buffer, 256)))
	{
		size += sz;
		result = realloc(result, size);
		int i;
		for(i = 0;i < sz;i++)
			result[size-sz+i] = buffer[i];
	}
	close(out[0]);
	lua_pushlstring(hostL, result, size);
	return 1;
}

int luaopen_luasandbox(lua_State *hostL)
{
	lua_pushcfunction(hostL, sandbox);
	return 1;
}
