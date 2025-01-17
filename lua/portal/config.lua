local types = require("portal.types")

--- @type Portal.Config
local M = {}

--- @class Portal.Config
local DEFAULT_CONFIG = {
	--- todo(cbochs): implement
	log_level = vim.log.levels.WARN,

	jump = {
		--- The default queries used when searching the jumplist. An entry can
		--- be a name of a registered query item, an anonymous predicate, or
		--- a well-formed query item. See Queries section for more information.
		--- @type Portal.QueryLike[]
		query = { "tagged", "modified", "different", "valid" },

		labels = {
			--- An ordered list of keys that will be used for labelling
			--- available jumps. Labels will be applied in same order as
			--- `jump.query`
			select = { "j", "k", "h", "l" },

			--- Keys that will exit portal selection
			escape = {
				["<esc>"] = true,
			},
		},

		--- Keys used for jumping forward and backward
		keys = {
			forward = "<c-i>",
			backward = "<c-o>",
		},
	},

	tag = {
		--- The default scope in which tags will be saved to
		--- Only "global" and "none" has been implemented for now
		--- @type Portal.Scope
		scope = types.Scope.GLOBAL,

		---
		save_path = vim.fn.stdpath("data") .. "/" .. "portal.json",

		--- Tags will be scoped to a specific git commit
		--- todo(cbochs): implement
		git = false,
	},

	preview = {
		title = {
			--- When a portal is empty, render an default portal title
			render_empty = true,

			--- The raw window options used for the title window
			options = {
				relative = "cursor",
				width = 80, -- implement as "min/mas width",
				height = 1,
				col = 2,
				style = "minimal",
				focusable = false,
				border = "single",
				noautocmd = true,
				zindex = 98,
			},
		},

		portal = {
			-- When a portal is empty, render an empty buffer body
			render_empty = false,

			--- The raw window options used for the portal window
			options = {
				relative = "cursor",
				width = 80, -- implement as "min/mas width",
				height = 3, -- implement as "context lines"
				col = 2, -- implement as "offset"
				focusable = false,
				border = "single",
				noautocmd = true,
				zindex = 99,
			},
		},
	},
}

--- @type Portal.Config
local _config = DEFAULT_CONFIG

local function resolve_key(key)
	return vim.api.nvim_replace_termcodes(key, true, false, true)
end

--- @param keys table
local function resolve_keys(keys)
	local resolved_keys = {}

	for key_or_index, key_or_flag in pairs(keys) do
		-- Table style: { "a", "b", "c" }. In this case, key_or_flag is the key
		if type(key_or_index) == "number" then
			table.insert(resolved_keys, resolve_key(key_or_flag))
			goto continue
		end

		-- Table style: { ["<esc>"] = true }. In this case, key_or_index is the key
		if type(key_or_index) == "string" and key_or_flag == true then
			table.insert(resolved_keys, resolve_key(key_or_index))
			goto continue
		end

		::continue::
	end

	return resolved_keys
end

--- @param opts Portal.Config
function M.load(opts)
	opts = opts or {}

	--- @type Portal.Config
	_config = vim.tbl_deep_extend("force", DEFAULT_CONFIG, opts)

	-- Resolve label keycodes
	_config.jump.labels.select = resolve_keys(_config.jump.labels.select)
	_config.jump.labels.escape = resolve_keys(_config.jump.labels.escape)
	_config.jump.keys.backward = resolve_key(_config.jump.keys.backward)
	_config.jump.keys.forward = resolve_key(_config.jump.keys.forward)
end

setmetatable(M, {
	__index = function(_, index)
		return _config[index]
	end,
})

return M
