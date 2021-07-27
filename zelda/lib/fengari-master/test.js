const fengari = require("./fengari");

const luaconf  = fengari.luaconf;
const lua      = fengari.lua;
const lauxlib  = fengari.lauxlib;
const lualib   = fengari.lualib;

const L = lauxlib.luaL_newstate();

lualib.luaL_openlibs(L);

lauxlib.luaL_dofile(L, "main.lua");
lua.lua_getglobal(L, "foo");
lua.lua_pushliteral(L, "y");
lua.lua_pcall(L, 1, 0, 0);
var result = lua.lua_tostring(L, -1);
console.log(result);

