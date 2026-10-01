-- Java settings for Neovim. The legacy Vimscript implementation remains in
-- ftplugin/java.vim for Vim and returns immediately under Neovim.

local api = vim.api

local function same_lines(first, second)
  if #first == 0 and #second == 1 and second[1] == "" then
    return true
  end
  if #second == 0 and #first == 1 and first[1] == "" then
    return true
  end
  return vim.deep_equal(first, second)
end

local function format_java(bufnr)
  bufnr = bufnr or 0
  if vim.bo[bufnr].buftype ~= "" then
    return
  end

  local filename = api.nvim_buf_get_name(bufnr)
  if filename == "" or filename:match("^jdt://") then
    return
  end

  local gradlew = vim.fs.find("gradlew", { path = vim.fs.dirname(filename), upward = true })[1]
  if not gradlew then
    vim.notify("spotlessApply skipped: no gradlew found", vim.log.levels.WARN)
    return
  end

  local root = vim.fs.dirname(gradlew)
  local ok, result = pcall(function()
    return vim.system({ gradlew, "spotlessApply", "-PspotlessIdeHook=" .. filename }, {
      cwd = root,
      text = true,
    }):wait()
  end)
  if not ok then
    vim.notify("spotlessApply could not start: " .. result, vim.log.levels.ERROR)
  elseif result.code ~= 0 then
    vim.notify("spotlessApply failed for " .. filename .. ": " .. (result.stderr or result.stdout or ""), vim.log.levels.ERROR)
  elseif api.nvim_buf_is_valid(bufnr) and api.nvim_buf_get_name(bufnr) == filename and not vim.bo[bufnr].modified then
    local read_ok, disk_lines = pcall(vim.fn.readfile, filename)
    local buffer_lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    if read_ok and not same_lines(disk_lines, buffer_lines) then
      local views = {}
      for _, winid in ipairs(api.nvim_list_wins()) do
        if api.nvim_win_get_buf(winid) == bufnr then
          views[winid] = api.nvim_win_call(winid, vim.fn.winsaveview)
        end
      end
      api.nvim_buf_set_lines(bufnr, 0, -1, false, disk_lines)
      vim.bo[bufnr].modified = false
      for winid, view in pairs(views) do
        if api.nvim_win_is_valid(winid) then
          api.nvim_win_call(winid, function()
            vim.fn.winrestview(view)
          end)
        end
      end
    end
  end
end

local function java_client_id()
  local configured = vim.g.jdt_uri_coc_client_id
  if type(configured) == "string" and configured ~= "" then
    return configured
  end

  local ok, services = pcall(vim.fn.CocAction, "services")
  if not ok or type(services) ~= "table" then
    return nil
  end

  local java_service
  for _, service in ipairs(services) do
    if vim.tbl_contains(service.languageIds or {}, "java") and service.id and service.id ~= "" then
      if service.state == "running"
        and (service.id:match("[Jj][Dd][Tt]") or service.id:match("[Jj]ava")) then
        return service.id
      end
      if not java_service or service.state == "running" then
        java_service = service.id
      end
    end
  end
  return java_service
end

local function jdt_uri(uri, bufnr)
  local client_id = java_client_id()
  if not client_id then
    vim.notify("[jdt://] no Java language-server client found", vim.log.levels.ERROR)
    return
  end

  local ok, content = pcall(vim.fn.CocRequest, client_id, "java/classFileContents", { uri = uri })
  if not ok then
    vim.notify("[jdt://] " .. content, vim.log.levels.ERROR)
    return
  end

  local lines = vim.split(content or "", "\n", { plain = true })
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].modifiable = true
  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
  vim.b[bufnr].jdt_uri = uri
  vim.bo[bufnr].filetype = "java"

  -- BufReadCmd bypasses Coc's normal BufReadPost handler. Coc's own content
  -- provider emits BufCreate after filling the buffer so it becomes an
  -- attached LSP document; do the same for this Vimscript-free provider.
  vim.schedule(function()
    if api.nvim_buf_is_valid(bufnr) and vim.fn.exists("*coc#rpc#notify") == 1 then
      vim.fn["coc#rpc#notify"]("CocAutocmd", { "BufCreate", bufnr })
    end
  end)
end

local function hover_lines(contents)
  if type(contents) == "string" then
    return vim.split(contents, "\n", { plain = true })
  end
  if type(contents) == "table" and contents.value then
    return vim.split(contents.value, "\n", { plain = true })
  end

  local lines = {}
  for _, item in ipairs(contents or {}) do
    if type(item) == "string" then
      vim.list_extend(lines, vim.split(item, "\n", { plain = true }))
    elseif item.value then
      if item.language and item.language ~= "markdown" then
        table.insert(lines, "```" .. item.language)
        vim.list_extend(lines, vim.split(item.value, "\n", { plain = true }))
        table.insert(lines, "```")
      else
        vim.list_extend(lines, vim.split(item.value, "\n", { plain = true }))
      end
    end
    table.insert(lines, "")
  end
  if lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

local function java_hover()
  local client_id = java_client_id()
  if not client_id then
    vim.cmd.normal({ args = { "K" }, bang = true })
    return
  end

  local cursor = api.nvim_win_get_cursor(0)
  local line = api.nvim_get_current_line()
  local character = select(2, vim.str_utfindex(line, cursor[2], true))
  local name = api.nvim_buf_get_name(0)
  local uri = name:match("^%a[%w+.-]*://") and name or vim.uri_from_fname(name)
  local ok, hover = pcall(vim.fn.CocRequest, client_id, "textDocument/hover", {
    textDocument = { uri = uri },
    position = { line = cursor[1] - 1, character = character },
  })
  if not ok or not hover or not hover.contents then
    vim.cmd.normal({ args = { "K" }, bang = true })
    return
  end

  local lines = hover_lines(hover.contents)
  if #lines > 0 then
    vim.lsp.util.open_floating_preview(lines, "markdown", { border = "rounded", focusable = false })
  end
end

if not vim.g.loaded_jdtls_jdt_uri_lua then
  vim.g.loaded_jdtls_jdt_uri_lua = true
  local group = api.nvim_create_augroup("jdtls_jdt_uri", { clear = true })
  api.nvim_create_autocmd({ "BufReadCmd", "FileReadCmd" }, {
    group = group,
    pattern = "jdt://*",
    callback = function(args)
      jdt_uri(args.match, args.buf)
    end,
  })
end

vim.keymap.set("n", "K", java_hover, { buffer = true, silent = true })
vim.keymap.set("n", "<Leader>=", format_java, { buffer = true, silent = true, desc = "Format Java file with Spotless" })

local format_group = api.nvim_create_augroup("JavaSpotlessApply", { clear = false })
api.nvim_clear_autocmds({ group = format_group, buffer = 0 })
api.nvim_create_autocmd("BufWritePost", {
  group = format_group,
  buffer = 0,
  callback = function(args)
    format_java(args.buf)
  end,
})
