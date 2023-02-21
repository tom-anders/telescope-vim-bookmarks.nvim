local transform_mod = require('telescope.actions.mt').transform_mod

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local function bookmark_save_file(file)
    if vim.g.bookmark_manage_per_buffer == 1 then
        return vim.fn['g:BMBufferFileLocation'](file) or vim.loop.cwd() .. '/.vim-bookmarks'
    elseif vim.g.bookmark_save_per_working_dir == 1 then
        return vim.fn['g:BMWorkDirFileLocation']() or vim.loop.cwd() .. '/.vim-bookmarks'
    end
    return vim.g.bookmark_auto_save_file
end

local function delete_bookmark(entry)
    vim.fn['bm_sign#del'](entry.filename, tonumber(entry.value.sign_idx))
    vim.fn['bm#del_bookmark_at_line'](entry.filename, tonumber(entry.lnum))
    vim.fn['BookmarkSave'](bookmark_save_file(vim.g.bm_current_file), 1)
end

local delete_at_cursor = function(prompt_bufnr)
    local selectedEntry = action_state.get_selected_entry()
    delete_bookmark(selectedEntry)
end

local delete_selected = function(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)

    for _, entry in ipairs(picker:get_multi_selection()) do
        delete_bookmark(entry)
    end

    -- Remove all multi selections.
    -- TODO There's probably an easier way to do this?
    --      Couldn't find any API for this
    for row = 0, picker.max_results - 1 do
        local entry = picker.manager:get_entry(picker:get_index(row))
        if entry then
            picker:remove_selection(row)
        end
    end

end


return transform_mod {
    delete_at_cursor = delete_at_cursor,

    delete_selected = delete_selected,

    delete_selected_or_at_cursor = function(prompt_bufnr)
        if #action_state.get_current_picker(prompt_bufnr):get_multi_selection() > 0 then
            delete_selected(prompt_bufnr)
        else
            delete_at_cursor(prompt_bufnr)
        end
    end,

    delete_all = function(prompt_bufnr)
        vim.cmd('BookmarkClearAll')
    end
}
