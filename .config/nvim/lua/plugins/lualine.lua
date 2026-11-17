-- Statusline indicator for the <F3> symbol layer (see lua/config/keymaps.lua)
-- 同时把状态栏做成透明的（配合 lua/plugins/theme.lua 的透明背景）
return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- 背景用 "NONE"，lualine 会自动切到透明的 statusline 高亮组
    local function mode(accent)
      local fg = Snacks.util.color("Normal") or "#c0caf5"
      -- a 段是实心色块，需要一个深色前景保证可读
      local dark = Snacks.util.color("Normal", "bg") or Snacks.util.color("Pmenu", "bg") or "#1b1d2b"
      return {
        a = { bg = accent, fg = dark, gui = "bold" },
        b = { bg = "NONE", fg = accent },
        c = { bg = "NONE", fg = fg },
      }
    end

    local accents = {
      normal = Snacks.util.color("Function") or "#7aa2f7",
      insert = Snacks.util.color("String") or "#9ece6a",
      replace = Snacks.util.color("Number") or "#ff9e64",
      visual = Snacks.util.color("Special") or "#bb9af7",
      command = Snacks.util.color("Identifier") or "#7dcfff",
    }

    opts.options.theme = {
      normal = mode(accents.normal),
      insert = mode(accents.insert),
      replace = mode(accents.replace),
      visual = mode(accents.visual),
      command = mode(accents.command),
      terminal = mode(accents.command),
      inactive = {
        a = { bg = "NONE", fg = Snacks.util.color("Comment") or "#565f89", gui = "bold" },
        b = { bg = "NONE", fg = Snacks.util.color("Comment") or "#565f89" },
        c = { bg = "NONE", fg = Snacks.util.color("Comment") or "#565f89" },
      },
    }

    table.insert(opts.sections.lualine_x, 1, {
      function()
        return "SYM"
      end,
      cond = function()
        return vim.g.symbol_layer == true
      end,
      color = function()
        return { fg = Snacks.util.color("Constant"), gui = "bold" }
      end,
      padding = { left = 1, right = 1 },
    })

    -- 电量标签：读 /sys/class/power_supply/BAT0，5 秒缓存（lualine 每秒刷新一次）
    -- 没有 BAT0（台式机 / 容器）时返回空串，lualine 不会留空位
    local bat_dir = "/sys/class/power_supply/BAT0/"
    local nf = vim.fn.nr2char -- nf-md-battery* 系列字形码点

    local function read_sysfs(name)
      local f = io.open(bat_dir .. name, "r")
      if not f then return nil end
      local value = f:read("*l")
      f:close()
      return value
    end

    local battery, battery_at = nil, 0
    local function battery_state()
      local now = vim.uv.hrtime()
      if battery == nil or now - battery_at > 5e9 then
        battery_at = now
        local capacity = tonumber(read_sysfs("capacity"))
        local status = read_sysfs("status")
        -- false 表示这台机器没电池，避免每次刷新都重复探测
        battery = capacity and { capacity = capacity, charging = status == "Charging" } or false
      end
      return battery or nil
    end

    local function battery_icon(b) -- 0xF007A..0xF0082 = nf-md-battery-10..90，0xF0079 = 满
      if b.charging then return nf(0xF0084) end
      if b.capacity >= 95 then return nf(0xF0079) end
      return nf(0xF0079 + math.max(1, math.min(9, math.floor(b.capacity / 10))))
    end

    table.insert(opts.sections.lualine_z, 1, {
      function()
        local b = battery_state()
        if not b then return "" end
        -- 自定义组件不会自动 escape：裸的 % 会被 statusline 当成格式符，
        -- 导致整条状态栏解析失败（E539: Illegal character），必须转义成 %%
        return require("lualine.utils.utils").stl_escape(battery_icon(b) .. " " .. b.capacity .. "%")
      end,
      padding = { left = 1, right = 1 },
      color = function()
        local b = battery_state()
        if not b then return nil end
        -- 充电时恒为绿；放电到 20% / 10% 以下依次变橙、变红加粗
        if b.charging then return { fg = Snacks.util.color("String") } end
        if b.capacity <= 10 then
          return { fg = Snacks.util.color("Error"), gui = "bold" }
        elseif b.capacity <= 20 then
          return { fg = Snacks.util.color("Number") }
        end
        return { fg = Snacks.util.color("String") }
      end,
    })
  end,
}
