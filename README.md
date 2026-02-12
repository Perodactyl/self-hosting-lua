# Self-Hosting Lua Parser

A lua parser written in lua. My goal is to make it parse something more fancy than lua and convert it. Currently working on LSP support instead tho.

## Notice
This project has moved to my friend's gitea because I *don't appreciate* what microslop is doing with this website. See [this link](https://gitea.chatapp.one/perodactyl/lua-lua) or [this one](https://gitea.luathenerd.dev/perodactyl/lua-lua) if the first link doesn't work.

### Usage
```sh
# Run all tests and listen for changes (requires watchexec to be installed)
./watchexec.sh

# Run all tests non-verbosely
lua src/main.lua 

# Run all tests and print their names
lua src/main.lua ""

# Run a group
lua src/main.lua "1"

# Run a group and print names of its members
lua src/main.lua "1."

# Run a certain test
lua src/main.lua "1.1"
```

Most tests generate long, complicated syntax trees for output. Instead of storing these in the test files themselves, I made it so that they go in `autotest-maps.lua`. If a test has `autotest = true` but `autotest-maps.lua` lacks an entry for it, it will only fail if parsing fails (it will pass even if it generated something weird and bad). Use these commands to manipulate autotests:

```sh
# Rebuild autotest maps completely. Does nothing if any test is failing.
lua src/main.lua "at:save"

# Add tests which are passing but do not have an autotest defined yet.
lua src/main.lua "at:append"

# Removes a test's map. Use this if the expected result changed.
lua src/main.lua "at:evict" "1.1"
```

If you want to demonstrate its ability to parse stuff, use these commands:

```sh
# Outputs result of testing that file.lua successfully parses
lua src/main.lua "custom" path/to/file.lua

# Same as above, but compile stdin (which is the string after <<<).
lua src/main.lua "custom" - <<< 'print("Hello, World!")'

# Same as above, but also writes a json file of the AST
SAVE_TREE=/tmp/tree.json lua src/main.lua "custom" path/to/file.lua

# Same as the first, but also writes a lua file to test codegen
SAVE_CODE=/tmp/code.lua lua src/main.lua "custom" path/to/file.lua

# (of course you can use both variables at once to write the AST and the generated code)
```

### LSP Server
Of the many things I'm working on with this project, I'm trying to write a Language Server.

Feature progress checklist:
- [ ] Diagnostics
	- [x] Show an error
	- [ ] Put it in the right spot, with the right message
	- [ ] Recover and find other errors / continue parsing
- [ ] Semantic Tokens (syntax highlight)
	- [x] Token-based
	- [ ] Tree-based (still some issues with functions and several types of tree branch don't fully specify their tokens)
- [ ] Stability

To test, enter the lspTesting directory and run:
```sh
./start-nvim.sh
```
Feel free to contribute more stuff for other code editors.
