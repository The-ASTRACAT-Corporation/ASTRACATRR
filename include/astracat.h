#ifndef ASTRACAT_H
#define ASTRACAT_H

#include <stdbool.h>
#include <kres/resolver.h>
#include <lua.h>

// Main application state
typedef struct {
    kr_resolver_t *resolver;
    lua_State *L;
    bool running;
} astracat_state_t;

// Function prototypes
void resolver_init(astracat_state_t *state);
void resolver_shutdown(astracat_state_t *state);
void cache_init(astracat_state_t *state);
void cache_flush(astracat_state_t *state);
void hooks_init(astracat_state_t *state);
void hooks_load(astracat_state_t *state, const char *script_path);
void hooks_close(astracat_state_t *state);

#endif // ASTRACAT_H
