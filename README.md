# Self-Hosting Lua Parser

A lua parser written in lua. My goal is to make it parse something more fancy than lua and convert it.

### Usage
```sh
# Run all tests and listen for changes (requires watchexec to be installed)
./watchexec.sh

# Run all tests non-verbosely
lua main.lua 

# Run all tests and print their names
lua main.lua ""

# Run a group
lua main.lua "1"

# Run a group and print names of its members
lua main.lua "1."

# Run a certain test
lua main.lua "1.1"
```

Most tests generate long, complicated syntax trees for output. Instead of storing these in the test files themselves, I made it so that they go in `autotest-maps.lua`. If a test has `autotest = true` but `autotest-maps.lua` lacks an entry for it, it will only fail of parsing fails (it will pass even if it generated something weird and bad). Use these commands to manipulate autotests:

```sh
# Rebuild autotest maps completely. Does nothing if any test is failing.
lua main.lua "at:save"

# Add tests which are passing but do not have an autotest defined yet.
lua main.lua "at:append"

# Removes a test's map. Use this if the expected result changed.
lua main.lua "at:evict" "1.1"
```

If you want to demonstrate its ability to parse stuff, use these commands:

```sh
# Outputs result of testing that file.lua successfully parses
lua main.lua "custom" path/to/file.lua

# Same as above, but compile stdin (which is the string after <<<).
lua main.lua "custom" - <<< 'print("Hello, World!")'

# Same as above, but also writes a json file of the AST
SAVE_TREE=/tmp/tree.json lua main.lua "custom" path/to/file.lua

# Same as the first, but also writes a lua file to test codegen
SAVE_CODE=/tmp/code.lua lua main.lua "custom" path/to/file.lua

# (of course you can use both variables at once to write the AST and the generated code)
```

(Codegen is currently rather dense and minified)
