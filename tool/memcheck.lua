memcheck = {}

local count

function memcheck.start()
	assert(count == nil , "memcheck.start has been started twice")

	collectgarbage("stop")
	count = collectgarbage("count")
end

function memcheck.stop()
	local countEnd = collectgarbage("count")
	collectgarbage("restart")
	local countStart = count
	count = nil
	assert(type(countStart) == "number", "memcheck.stop has been stopped twice")

	return countEnd-countStart
end

--memcheck.start()
--memcheck.stop() -- Returns the garbage in KB