-- ~/.config/sclop/opencode-session-header.lua
-- stable session id for opencode Go: x-opencode-session
-- https://opencode.ai/docs/console/go/#where-can-i-use-it
local M = {}
local http = sclop.http
local fallback = 'sclop-' .. os.time() .. '-' .. math.random(100000, 999999)

local function session_id()
	local path = sclop.session.path
	return path and path:match('([^/]+)%.jsonl$') or fallback
end

local function is_provider_url(url)
	local p = sclop.providers[sclop.provider]
	return p and p.base_url and url and url:sub(1, #p.base_url) == p.base_url
end

function M.setup()
	sclop.http = function(opts)
		if is_provider_url(opts.url) then
			opts.headers = opts.headers or {}
			opts.headers['x-opencode-session'] = session_id()
		end
		return http(opts)
	end
end

return M
