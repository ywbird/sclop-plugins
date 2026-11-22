-- 0rwx-ai-x: put the AI:X logo block in a README.
--
--   require('plugins/0rwx-ai-x')
--
--   /0rwx [README path]
--
-- The command edits the file itself, no agent turn: copies the SVGs from
-- ./assets into docs/assets/ of the current project and inserts the official
-- AI:X block from 0rwx.com (CC0) before the title. Running it twice is a no-op.

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
	sclop.info('0rwx: added the AI:X block to ' .. path .. ', SVGs in docs/assets')
end, 'insert the AI:X logo block into README and copy its SVGs to docs/assets')

return { insert = insert, dir = dir }
