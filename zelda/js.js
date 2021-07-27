const fengari = require("./lib/fengari-master/fengari");

const luaconf  = fengari.luaconf;
const lua      = fengari.lua;
const lauxlib  = fengari.lauxlib;
const lualib   = fengari.lualib;

function fooer() {
    const L = lauxlib.luaL_newstate();
    lualib.luaL_openlibs(L);
    lauxlib.luaL_dofile(L, "helper.lua");
    lua.lua_getglobal(L, "foo");
    lua.lua_pcall(L, 0, 0, 0);
}

