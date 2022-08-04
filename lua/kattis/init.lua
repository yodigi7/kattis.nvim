-- TODO: Update to use general non-linux specific commands and file paths
-- :lua require('kattis')._get_problem()
local default_config = {
    langs_to_generate = {'python', 'go'},
    python = {
        default_text = [[
if __name__ == '__main__':
    ...
        ]],
        file_ending = '.py',
    },
    go = {
        default_text = [[
package main

import (
    "fmt"
)

func main() {
}
        ]],
        file_ending = '.go',
    },
}

local kattis = {}

kattis.config = default_config

function kattis.setup(opts)
    kattis.config = opts or default_config
end

function kattis.add_problem()
    local problem_name = kattis._get_problem()
    local goal_dir
    if vim.g.kattis_default_path == nil then
        goal_dir = vim.fn.getcwd() .. '/' .. problem_name
    else
        goal_dir = vim.g.kattis_default_path .. '/' .. problem_name
    end
    os.execute('mkdir ' .. problem_name)
    os.execute('cd ' .. problem_name)
    kattis.download_samples(problem_name, goal_dir)
    kattis.generate_files(goal_dir, problem_name)
end

function kattis.test_problem()
    -- TODO
end

function kattis._get_problem()
    -- TODO: filter out potential slashes and everything else
    -- Potentially allow full http url copy paste
    local kattis_problem
    vim.ui.input({prompt = 'What is the problem you are looking for? https://open.kattis.com/problems/'}, function (input)
        kattis_problem = input
    end)
    return kattis_problem
end

function kattis.generate_files(folder_path, problem_name)
    if kattis.config.default_folder_path ~= nil and folder_path == nil then
        folder_path = kattis.config.default_folder_path
    end
    for _, val in pairs(kattis.config.langs_to_generate) do
        kattis._create_file(folder_path .. '/' .. problem_name .. kattis.config[val].file_ending, kattis.config[val].default_text)
    end
end

-- TODO: get out the problem body from the kattis website
-- Issue with the italicized parameters such as `n` statues
-- https://open.kattis.com/problems/3dprinter
-- lua print(vim.inspect(require('kattis')._curl_problem("3dprinter")))
function kattis._curl_problem(problem_name)
    return require('plenary.curl').get('https://open.kattis.com/problems/' .. problem_name)
end

-- lua require('kattis').download_samples("3dprinter", '/root/kattis_problem/lua')
function kattis.download_samples(problem_name, goal_dir)
    local output_path = goal_dir .. '/samples.zip'
    require('plenary.curl').get('https://open.kattis.com/problems/' .. problem_name .. '/file/statement/samples.zip', {output=output_path})
    -- TODO: figure out if there is a cleaner way to do this
    -- unzip zip file
    os.execute('unzip ' .. output_path .. ' -d ' .. goal_dir)
    -- remove zip file
    os.execute('rm ' .. output_path)
end

function kattis._create_file(file_path, input_text)
    -- TODO: is there a way to do use `with` like python
    local file = io.open(file_path, 'w')
    pcall(function() file:write(input_text) end)
    -- TODO: Make sure this closes no matter what
    file:close()
end

return kattis
