#! /bin/lua

local func_table = {}

func_table.post = function(name)
	if name == nil then
		print("Error: require file name")
		return
	end
	os.execute("hugo new posts/" .. name .. ".md")
end

func_table.rmpost = function(name)
	if name == nil then
		print("Error: require file name")
		return
	end
	if os.execute("rm content/posts/" .. name .. ".md") then
		print("remove content/posts/" .. name .. ".md")
	end
end

func_table.push = function(commit)
	if commit == nil then
		print("Error: require commit")
		return
	end
	os.execute("git add .")
	os.execute('git commit -m "' .. commit .. '"')
	os.execute("git push")
end

if arg[1] == "post" then
	func_table.post(arg[2])
elseif arg[1] == "rmpost" then
	func_table.rmpost(arg[2])
elseif arg[1] == "push" then
	func_table.push(arg[2])
end
