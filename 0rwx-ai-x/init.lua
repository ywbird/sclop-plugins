-- 0rwx-ai-x: put the AI:X logo block in a README.
--
--   require('plugins/0rwx-ai-x').setup{ commit = true }
--
--   /0rwx [README path]
--
-- The command edits the file itself, no agent turn: copies the SVGs from
-- ./assets into docs/assets/ of the current project and inserts the official
-- AI:X block from 0rwx.com (CC0) before the title. Running it twice is a no-op.
--
-- commit is off by default. With commit = true the README and the two SVGs are
-- also staged and committed; without git, outside a work tree, or for a README
-- outside the project the commit step is skipped and the info line says why.

local util = require('sclop.util')

local SNIPPET = [[
<!-- Official 0rwx logos from https://0rwx.com/ (CC0 / public domain). -->
<p>
  <a href="https://0rwx.com/">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="docs/assets/AI-X-dark.svg">
      <source media="(prefers-color-scheme: light)" srcset="docs/assets/AI-X-light.svg">
      <img src="docs/assets/AI-X-light.svg" alt="AI:X — AI가 만든 프로젝트 (0rwx)" width="64" height="64" align="right">
    </picture>
  </a>
</p>]]

local MARK = '<!-- Official 0rwx logos from https://0rwx.com/'
local ASSETS = { 'AI-X-dark.svg', 'AI-X-light.svg' }
local COMMIT_MSG = 'docs: add the AI:X logo block'

local M = {}

-- off unless setup{ commit = true }; the command works either way
local options = { commit = false }

function M.setup(opts)
	opts = opts or {}
	if opts.commit ~= nil then
		options.commit = opts.commit == true
	end
	return M
end

local function dir()
	local src = debug.getinfo(1, 'S').source:gsub('^@', '')
	return src:match('^(.*)/[^/]+$') or '.'
end

local function read(path)
	local f = io.open(path, 'rb')
	if not f then
		return nil
	end
	local text = f:read('*a')
	f:close()
	return text
end

local function write(path, text)
	local f, err = io.open(path, 'wb')
	if not f then
		return nil, err
	end
	local ok, werr = f:write(text)
	f:close()
	return ok, werr
end

-- run one shell command, return its output (no exit marker) and exit code
local function run(cmd)
	local p = io.popen('(' .. cmd .. ') 2>&1; echo "__exit__$?"')
	if not p then
		return '', -1
	end
	local out = p:read('*a') or ''
	p:close()
	local code = tonumber(out:match('__exit__(%d+)%s*$')) or -1
	return (out:gsub('\n?__exit__%d+%s*$', '')), code
end

local function git(argv)
	local parts = { 'git', '-C', util.quote(sclop.cwd) }
	for _, a in ipairs(argv) do
		parts[#parts + 1] = util.quote(a)
	end
	return run(table.concat(parts, ' '))
end

-- commit the block and the SVGs; returns a suffix for the info line
local function commit(path)
	if not options.commit then
		return ''
	end
	if not util.has('git') then
		return ', git not found, not committed'
	end
	local tree, code = git{ 'rev-parse', '--is-inside-work-tree' }
	if code ~= 0 or tree:match('^true') == nil then
		return ', not a git work tree, not committed'
	end
	if path:sub(1, #sclop.cwd + 1) ~= sclop.cwd .. '/' then
		return ', ' .. path .. ' is outside ' .. sclop.cwd .. ', not committed'
	end
	local files = { path }
	for _, name in ipairs(ASSETS) do
		files[#files + 1] = sclop.cwd .. '/docs/assets/' .. name
	end
	local out
	out, code = git{ 'add', '--', unpack(files) }
	if code ~= 0 then
		return ', git add failed: ' .. (out:match('([^\n]+)') or 'exit ' .. code)
	end
	out, code = git{ 'commit', '-q', '-m', COMMIT_MSG, '--', unpack(files) }
	if code ~= 0 then
		return ', git commit failed: ' .. (out:match('([^\n]+)') or 'exit ' .. code)
	end
	local sha, scode = git{ 'rev-parse', '--short', 'HEAD' }
	if scode ~= 0 then
		return ', committed'
	end
	return ', committed ' .. (sha:match('(%x+)') or 'HEAD')
end

-- insert the block before the first title line, or at the top
local function insert(text)
	if text:find(MARK, 1, true) then
		return nil, 'already has the AI:X block'
	end
	local body = SNIPPET .. '\n\n'
	local at = 1
	if not text:match('^#%s') then
		local s = text:find('\n#%s')
		at = s and s + 1 or 1
	end
	return text:sub(1, at - 1) .. body .. text:sub(at)
end

sclop:command_register('0rwx', function(args)
	if sclop.agent.busy then
		return sclop.info('0rwx: wait for the current turn to finish')
	end
	args = args:match('^%s*(.-)%s*$') or ''
	local path = util.expand(args ~= '' and args or sclop.cwd .. '/README.md')
	if path:sub(1, 1) ~= '/' then
		path = sclop.cwd .. '/' .. path
	end
	local text = read(path)
	if not text then
		return sclop.error('0rwx: cannot read ' .. path)
	end

	for _, name in ipairs(ASSETS) do
		local svg = read(dir() .. '/assets/' .. name)
		if not svg then
			return sclop.error('0rwx: missing asset ' .. dir() .. '/assets/' .. name)
		end
		local dest = sclop.cwd .. '/docs/assets/' .. name
		os.execute('mkdir -p ' .. util.quote(sclop.cwd .. '/docs/assets'))
		local ok, err = write(dest, svg)
		if not ok then
			return sclop.error('0rwx: ' .. tostring(err))
		end
	end

	local updated, err = insert(text)
	if not updated then
		return sclop.info('0rwx: ' .. path .. ' ' .. err)
	end
	local ok, werr = write(path, updated)
	if not ok then
		return sclop.error('0rwx: ' .. tostring(werr))
	end
	sclop.info('0rwx: added the AI:X block to ' .. path .. ', SVGs in docs/assets' .. commit(path))
end, 'insert the AI:X logo block into README and copy its SVGs to docs/assets')

M.insert, M.dir, M.commit = insert, dir, commit

return M
