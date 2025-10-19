#include "astracat.h"
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <kres/resolver.h>

static astracat_state_t app_state;

// Signal handler for graceful shutdown
void handle_signal(int signum) {
    if (signum == SIGINT || signum == SIGTERM) {
        printf("\nReceived signal %d, initiating shutdown...\n", signum);
        app_state.running = false;
        // Break the resolver's event loop
        if (app_state.resolver) {
            kr_resolver_break(app_state.resolver);
        }
    }
}

int main(int argc, char *argv[]) {
    // Initialize application state
    app_state.running = true;
    app_state.resolver = NULL;
    app_state.L = NULL;

    // Set up signal handlers
    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    printf("Starting ASTRACAT Recursive Resolver...\n");

    // Initialize components
    resolver_init(&app_state);
    cache_init(&app_state);
    hooks_init(&app_state);

    // Load the default or specified Lua script
    const char *lua_script = (argc > 1) ? argv[1] : "lua/example_filter.lua";
    hooks_load(&app_state, lua_script);

    // Start the resolver's main event loop
    // This function blocks until kr_resolver_break() is called or an error occurs.
    printf("Entering main event loop.\n");
    int ret = kr_resolver_run(app_state.resolver, NULL, NULL);
    if (ret != 0) {
        fprintf(stderr, "Resolver event loop failed with error: %d\n", ret);
    }

    // Clean up resources
    printf("Shutting down components...\n");
    resolver_shutdown(&app_state);
    hooks_close(&app_state);

    printf("ASTRACAT Recursive Resolver stopped.\n");
    return ret;
}
