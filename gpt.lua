local luarocks = require "luarocks.loader"
local http = require("resty.http")

local function generate_text(prompt)
  -- Get the current buffer's contents as context.
  local context = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local API_KEY = os.getenv("OPENAI_API")

  -- Set up the HTTP request to the GPT-3 API.
  local httpc = http.new()
  local res, err = httpc:request_uri("https://api.openai.com/v1/engines/davinci-codex/completions", {
    method = "POST",
    headers = {
      ["Content-Type"] = "application/json",
      ["Authorization"] = "Bearer " .. API_KEY
    },
    body = '{"prompt": "' .. prompt .. '", "max_tokens": 2048, "temperature": 0.5, "context": "' .. context .. '"}'
  })

  -- Check for errors in the HTTP request.
  if not res then
    error("failed to request API: " .. err)
  end

  -- Parse the response from the API and extract the generated text.
  local response = vim.fn.json_decode(res.body)
  local generated_text = response.choices[1].text

  -- Insert the generated text into the current buffer.
  vim.api.nvim_put({generated_text}, "c", true, true)
end

vim.cmd([[
  command! -nargs=1 GPT3 lua generate_text(<f-args>)
]])

