-- lua/example_filter.lua
-- Example Lua plugin for ASTRACAT Recursive Resolver

-- This function is called before a query is processed.
-- It can be used to filter or log queries.
function on_pre_query(query)
    print("Lua: on_pre_query called for: " .. query)
    -- To block a query, return false
    -- return false
end

-- This function is called after a query has been resolved.
-- It can be used to inspect the answer or log the result.
function on_post_query(query, answer)
    print("Lua: on_post_query called for: " .. query)
    -- The answer is a placeholder in this example.
    -- A real implementation would pass the DNS response.
end
