shader = shader or {}
shader._Loaded = true
shader.shaderFunctions = love.filesystem.read("shaderfunctions.glsl")
shader.shaderFunctionsDate = love.filesystem.getLastModified("shaderfunctions.glsl")
shader.file = shader.file or {}
shader.name = shader.name or {} -- This does not handle removed or renamed files
shader.date = shader.date or {}
shader.err = shader.err or {}
for i = 1, #shader.file do
	if shader.err[i] then
		print(shader.name[i])
		print(shader.err[i])
	end
end

local function loadShader( fileName , index )
	local fileTemp, err = love.filesystem.read(fileName)
	assert(fileTemp ~= nil, "Shader must be in a seperate file\n"..err.."\n")
	
	local _OK_ , _ShaderOrError_ = pcall(love.graphics.newShader ,shader.shaderFunctions..fileTemp)
	if _OK_ then
		shader.file[index] = _ShaderOrError_
		shader.err[index] = nil --No error
	else
		shader.file[index] = false -- No shader
		shader.err[index] = _ShaderOrError_
	end

	shader.name[index] = fileName
	shader.date[index] = love.filesystem.getLastModified(fileName)
end



function shader.new(fileName)
	local indexInTable = #shader.file+1
	for i = 1 , #shader.file do
		if fileName == shader.name[i] then
			indexInTable = i
			break
		end
	end

	loadShader(fileName,indexInTable)
	
	return {
		indexInTable = indexInTable ,
		send = function ( self , ...)
			if shader.file[self.indexInTable] then
				-- pcall send ?? (shader want variable, dosen't get it. will act weird and no errors)
				shader.file[self.indexInTable]:send(...)
			end
		end
	}
end

function shader.set(shaderInfo)
	if shaderInfo == nil then
		love.graphics.setShader()
	else
		if shader.file[shaderInfo.indexInTable] then
			love.graphics.setShader(shader.file[shaderInfo.indexInTable])
		end
	end
end

function shader.hotLoad()
	shader._Loaded = false
	if love.filesystem.getLastModified("shaderfunctions.glsl") ~= shader.shaderFunctionsDate then
		shader.shaderFunctions = love.filesystem.read("shaderfunctions.glsl")
		for i = 1, #shader.file do
			loadShader(shader.name[i] , i )
		end
		shader.shaderFunctionsDate = love.filesystem.getLastModified("shaderfunctions.glsl")
		print("Time: ".._TimeF..", All shaders reloaded")
		shader._Loaded = true
	else -- if shaderfunctions is loaded all files are reloaded anyways
		for i = 1 , #shader.file do
			if love.filesystem.getLastModified(shader.name[i]) ~= shader.date[i] then
				loadShader(shader.name[i] , i)
				print("Time: ".._TimeF, "Loaded: "..shader.name[i])
				shader._Loaded = true
			end
		end
	end
	printv("Shaders Loaded",#shader.file)
	for i = 1, #shader.file do
		if shader.err[i] ~= nil then
			if shader._Loaded then
				print(shader.name[i].."\n"..shader.err[i]) -- Maybe print directly on shader._Loaded ???
			end
		end
	end
end

