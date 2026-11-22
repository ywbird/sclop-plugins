-- interview: start a project interview with the interview-me skill.
--
--   /interview
--
--   [project goal]
--
-- The goal is everything after the command, including newlines. Paste the block
-- or use Alt+Enter for the blank line.

local RULES = [[
Behavior:
- Ask when something is ambiguous.
  - Skip questions for typo fixes, simple lookups, and clear instructions; do those directly.
  - If any of Why, Who, Success, or Constraint is missing and the answer could change direction, follow `interview-me` before planning or writing code.
  - Ask one question at a time. Attach HYPOTHESIS, CONFIDENCE, and GUESS to each question. Do not batch questions.
- Before the interview, read TODO.md in the project root if it exists.
- When the intent is confirmed:
  - First restate the intent in 5-8 lines and get an explicit yes from the user. "Do whatever you think" and "sounds good" are not yes.
  - Only after yes, update TODO.md. Preserve existing content and use edit. Use write only when the file does not exist.
  - Write new or updated TODO.md content in English. Do not translate existing content.
  - Add or update `## Project Intent` in TODO.md: Goal (Why), User (Who), Success, Constraint, Out of scope. Out of scope is mandatory.
  - Add `## Feedback` if it is missing. User feedback is a `- [ ]` checkbox list.
  - Add or update `## Implementation Rules`: when feedback work is ambiguous, indent under that item and list the points to confirm. Commit after every change.
  - After updating TODO.md, reply with one confirmation line and stop the turn immediately. Do not start planning, task lists, or code.
  - Saving TODO.md overrides `interview-me`'s "no tool calls, stop immediately" rule. Always stop after saving.
- During implementation:
  - Keep the feedback checkbox list in TODO.md.
  - When feedback is ambiguous, indent under that item and list the points to confirm.
  - Commit after every change.
]]

local function prompt(goal)
	return 'Start a project interview. First load the `interview-me` skill with the skill tool and follow it.\n\n'
		.. 'Project goal:\n' .. goal .. '\n\n' .. RULES
end

local function find_skill(name)
	for _, dir in ipairs(sclop.skills or {}) do
		local path = sclop.util.expand(dir) .. '/' .. name .. '/SKILL.md'
		local f = io.open(path)
		if f then
			f:close()
			return path
		end
	end
end

sclop:command_register('interview', function(args)
	if sclop.agent.busy then
		return sclop.info('interview: wait for the current turn to finish')
	end
	args = args:match('^%s*(.-)%s*$') or ''
	if args == '' then
		return sclop.info('usage:\n/interview\n\n[project goal]')
	end
	if not find_skill('interview-me') then
		return sclop.error('interview-me skill not found.\n'
			.. 'Install: npx skills add addyosmani/agent-skills --skill interview-me\n'
			.. 'Expected: ~/.agents/skills/interview-me/SKILL.md')
	end
	require('sclop.tools.skill').reload()
	sclop.agent.submit(prompt(args))
end, 'start a project interview with interview-me')

return { prompt = prompt, find_skill = find_skill }
