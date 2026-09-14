-- vi, plus the parts of neovim worth having.
-- no plugin manager, no plugins. everything here ships with nvim >= 0.11.
-- preferences carried over from the 2021 ~/.vimrc.

vim.g.mapleader = ","
vim.g.maplocalleader = ","

local o = vim.opt
local map = vim.keymap.set

--------------------------------------------------------------------- options

-- indentation
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.autoindent = true

-- searching. gdefault means :s/x/y/ hits the whole line without the trailing /g
o.ignorecase = true
o.smartcase = true
o.gdefault = true
-- incsearch, hlsearch, showmatch, wildmenu, hidden are already nvim defaults

-- display. deliberately plain: no sign column, no tabline, no icons.
o.number = true
o.cursorline = true
o.colorcolumn = "100"
o.textwidth = 79
o.formatoptions = "qrn1"
o.scrolloff = 3
o.signcolumn = "no"
o.list = true
o.listchars = { tab = "  " }
o.lazyredraw = true

-- the 2021 statusline, unchanged: file (filetype) [modified] ... line,col
o.statusline = "%<%f (%{&ft}) %-4(%m%)%=%-19(%3l,%02c%03V%)"
o.laststatus = 2 -- per-window. set to 3 for a single global line instead.

-- persistent undo (nvim defaults undodir to ~/.local/state/nvim/undo)
o.undofile = true

-- :find <tab> across the whole tree, which is most of what a file picker does
o.path:append("**")
o.wildignore:append({ "*/.git/*", "*/node_modules/*", "*/vendor/*", "*/target/*" })

-- :grep uses ripgrep, results land in the quickfix list
if vim.fn.executable("rg") == 1 then
  o.grepprg = "rg --vimgrep --smart-case"
  o.grepformat = "%f:%l:%c:%m"
end

-- par isn't installed; gq falls back to nvim's internal formatter. install
-- par (brew install par) to get the old `gq` behaviour back.
if vim.fn.executable("par") == 1 then
  o.formatprg = "par -w72re"
end

-- manual completion only (<C-x><C-o>), no popup firing as you type
o.completeopt = { "menu", "menuone", "noselect", "popup" }
o.winborder = "single" -- delimits hover/diagnostic floats; "" for none

----------------------------------------------------------------- diagnostics

-- quiet: underline the problem, don't narrate it. ]d / [d to walk them,
-- <leader>e for the full text of the one under the cursor.
vim.diagnostic.config({
  virtual_text = false,
  signs = false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "single", source = true, header = "" },
})

------------------------------------------------------------------------- lsp

-- each server is declared here and enabled only if its binary is on $PATH,
-- so an uninstalled server is silently inert rather than an error on startup.
local servers = {
  gopls = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
  },
  basedpyright = {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
    settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
  },
  ruff = {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".git" },
  },
  rust_analyzer = {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", ".git" },
  },
  bashls = {
    cmd = { "bash-language-server", "start" },
    filetypes = { "sh", "bash" },
    root_markers = { ".git" },
  },
  yamlls = {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml" },
    root_markers = { ".git" },
  },
  taplo = {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
    root_markers = { ".git" },
  },
  jsonls = {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { ".git" },
  },
  marksman = {
    cmd = { "marksman", "server" },
    filetypes = { "markdown" },
    root_markers = { ".marksman.toml", ".git" },
  },
}

for name, cfg in pairs(servers) do
  vim.lsp.config(name, cfg)
  if vim.fn.executable(cfg.cmd[1]) == 1 then
    vim.lsp.enable(name)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "lsp keymaps and manual omni-completion",
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local buf = args.buf

    -- sets omnifunc, so completion is <C-x><C-o> and nothing else.
    -- pass { autotrigger = true } if you ever want it to fire on its own.
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = false })
    end

    local function m(lhs, rhs, desc)
      map("n", lhs, rhs, { buffer = buf, desc = desc })
    end
    -- nvim 0.11 already gives you K (hover), grn (rename), gra (code action),
    -- grr (references), gri (implementation), gO (symbols), ]d / [d.
    m("gd", vim.lsp.buf.definition, "go to definition")
    m("gr", vim.lsp.buf.references, "references")
    m("gD", vim.lsp.buf.declaration, "declaration")
    m("<leader>rn", vim.lsp.buf.rename, "rename")
    m("<leader>ca", vim.lsp.buf.code_action, "code action")
    m("<leader>F", function() vim.lsp.buf.format({ async = false }) end, "format buffer")
  end,
})

--------------------------------------------------------------------- keymaps

-- edit / source this file ("edit vimrc", "source vimrc")
map("n", "<leader>ev", ":e $MYVIMRC<cr>", { silent = true, desc = "edit config" })
map("n", "<leader>sv", ":source $MYVIMRC<cr>", { silent = true, desc = "source config" })

map("n", "<leader><space>", ":nohlsearch<cr>", { silent = true, desc = "clear search" })
map("n", "<Space>", "za", { desc = "toggle fold" })

-- <Tab> jumps between matching pairs. note: in most terminals <Tab> and <C-i>
-- are the same byte, so this costs you <C-i> (forward in the jumplist).
map({ "n", "v" }, "<Tab>", "%", { desc = "matching pair" })

map("n", "<leader>W", [[:%s/\s\+$//<cr>:let @/=''<cr>]], { desc = "strip trailing whitespace" })

-- comment / uncomment from mark 'a to mark 'b with a #MP# marker
map("n", "<leader>#", [[:'a,'bs/^/#MP#/<cr>]], { desc = "mark block commented" })
map("n", "<leader>3", [[:'a,'bs/#MP#//<cr>]], { desc = "unmark block" })

-- splits
map("n", "<leader>w", "<C-w>v<C-w>l", { desc = "vsplit and move into it" })
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- no arrow keys. learn the home row.
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  map({ "n", "i", "v" }, key, "<Nop>")
end

-- navigation without a picker: :find walks 'path', :grep fills the quickfix
map("n", "<leader>f", ":find ", { desc = ":find (tab-completes across the tree)" })
map("n", "<leader>g", ":grep ", { desc = ":grep into quickfix" })
map("n", "<leader>b", ":buffer ", { desc = ":buffer by name" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "diagnostic under cursor" })

-------------------------------------------------------------------- autocmds

local aug = vim.api.nvim_create_augroup("mikepea", { clear = true })

-- highlight trailing whitespace (the old :match ExtraWhitespace trick,
-- as a matchadd so it survives window splits)
vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "#556b2f" })
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinNew" }, {
  group = aug,
  desc = "highlight trailing whitespace",
  callback = function()
    if vim.w.extra_whitespace_match == nil then
      vim.w.extra_whitespace_match = vim.fn.matchadd("ExtraWhitespace", [[\s\+$]])
    end
  end,
})

-- brief flash on yank, so you can see what you just grabbed
vim.api.nvim_create_autocmd("TextYankPost", {
  group = aug,
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- ignore whitespace-only changes in diff mode
if vim.opt.diff:get() then
  o.diffopt:append("iwhite")
end

-- go: organise imports, then format, on write (replaces vim-go's :Fmt)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = aug,
  pattern = "*.go",
  desc = "gopls organise imports + format",
  callback = function(args)
    local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "gopls" })
    if #clients == 0 then return end
    local enc = clients[1].offset_encoding or "utf-16"

    local params = vim.lsp.util.make_range_params(0, enc)
    params.context = { only = { "source.organizeImports" }, diagnostics = {} }
    local result = vim.lsp.buf_request_sync(args.buf, "textDocument/codeAction", params, 1000)
    for _, res in pairs(result or {}) do
      for _, action in pairs(res.result or {}) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, enc)
        end
      end
    end

    vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 2000 })
  end,
})
