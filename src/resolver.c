#include "astracat.h"
#include <stdio.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <kres/resolver.h>
#include <lauxlib.h>

// Forward declaration
static int query_callback(kr_request_t *req, kr_response_t *resp, void *arg);

void resolver_init(astracat_state_t *state) {
    state->resolver = kr_resolver_create();
    if (!state->resolver) {
        fprintf(stderr, "Failed to create resolver context.\n");
        exit(1);
    }

    // Configure the resolver to listen on UDP port 53
    int port = 53;
    if (kr_resolver_listen(state->resolver, port, state, query_callback) != 0) {
        fprintf(stderr, "Failed to listen on UDP port %d.\n", port);
        kr_resolver_destroy(state->resolver);
        exit(1);
    }

    printf("Resolver initialized and listening on UDP port %d.\n", port);
}

void resolver_shutdown(astracat_state_t *state) {
    if (state->resolver) {
        kr_resolver_destroy(state->resolver);
    }
    printf("Resolver shut down.\n");
}

static int query_callback(kr_request_t *req, kr_response_t *resp, void *arg) {
    astracat_state_t *state = (astracat_state_t *)arg;
    const char *qname = kr_request_qname(req);

#ifdef ENABLE_LUA
    // Call on_pre_query hook
    lua_getglobal(state->L, "on_pre_query");
    lua_pushstring(state->L, qname);
    if (lua_pcall(state->L, 1, 1, 0) != LUA_OK) {
        fprintf(stderr, "Error running on_pre_query: %s\n", lua_tostring(state->L, -1));
    } else {
        // Check the return value; if it's false, block the query
        if (lua_isboolean(state->L, -1) && !lua_toboolean(state->L, -1)) {
            printf("Query for %s blocked by Lua script.\n", qname);
            return KR_VIEW_DENY;
        }
    }
    lua_pop(state->L, 1); // Pop the return value
#endif

    // The resolver will handle the query asynchronously
    (void)resp; // Suppress unused parameter warning

#ifdef ENABLE_LUA
    // Call on_post_query hook (in a real implementation, this would be in a separate callback)
    lua_getglobal(state->L, "on_post_query");
    lua_pushstring(state->L, qname);
    lua_pushstring(state->L, "dummy_answer"); // Placeholder for the actual answer
    if (lua_pcall(state->L, 2, 0, 0) != LUA_OK) {
        fprintf(stderr, "Error running on_post_query: %s\n", lua_tostring(state->L, -1));
    }
#endif
    return KR_VIEW_CONTINUE;
}
