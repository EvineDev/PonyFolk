local fileout = love.filesystem.newFile("programwalkout.txt","w")

programwalk = {}
local toPrint = false


function programwalk.start(outputMode)
	if outputMode == "print" then
		toPrint = true
	end
	debug.sethook(lineDebugFunction , "l")
end


function programwalk.stop()
	debug.sethook()
	fileout:close()
end


local function write(...) -- Only 2 arguments
	if not toPrint then
		if select("#",...) == 1 then
			fileout:write(select(1,...).."\n")
		elseif select("#",...) == 2 then
			fileout:write(select(1,...).."\t"..select(2,...).."\n")
		else
			assert(false,"To many arguments in debug")
		end
	else
		print(...)
	end
end


function lineDebugFunction(stringLine,lineNumber)
	local skip = false
	local info = debug.getinfo(2,"S") -- Remove second argument to return all possible info

	-- Special case these files as it doesn't have any useful information for me.
	if info.source == "boot.lua" or
		info.source == "graphics.lua" or
		info.source == "@conf.lua" then
		skip = true
	end
	info.source = info.source:gsub("@","")

	if not skip then
		write("Source",info.source) -- Which Source file
		write("Current line",lineNumber) --Current line
		readLine(lineNumber , info.source ) -- TODO: parse info.source
		--write("----")
		--for k , v in pairs(info) do -- write everything in info table
		--  write(k, type(v) , v)
		--end

  		write("-----------------------------------------")
  	end
end


function readLine(lineNumber,fileName)
	local i = 1
	for line in love.filesystem.lines(fileName) do
		if i == lineNumber then
			write(line)
			break
		end
		i = i+1
	end
end
