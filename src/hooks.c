#include "astracat.h"
#include <stdio.h>
#include <lualib.h>
#include <lauxlib.h>

void hooks_init(astracat_state_t *state) {
#ifdef ENABLE_LUA
    state->L = luaL_newstate();
    if (!state->L) {
        fprintf(stderr, "Failed to create Lua state.\n");
        exit(1);
    }
    luaL_openlibs(state->L);
    printf("Lua hooks initialized.\n");
#else
    state->L = NULL;
#endif
}

void hooks_load(astracat_state_t *state, const char *script_path) {
#ifdef ENABLE_LUA
    if (state->L && luaL_dofile(state->L, script_path)) {
        fprintf(stderr, "Failed to load Lua script: %s\n", lua_tostring(state->L, -1));
    } else {
        printf("Lua script '%s' loaded.\n", script_path);
    }
#else
    // Suppress unused parameter warnings
    (void)state;
    (void)script_path;
#endif
}

void hooks_close(astracat_state_t *state) {
#ifdef ENABLE_LUA
    if (state->L) {
        lua_close(state->L);
    }
    printf("Lua hooks closed.\n");
#else
    // Suppress unused parameter warning
    (void)state;
#endif
}
