--[[
A few table helper functions, in addition to a new T-table interface, which enables method indexing on tables.

To define a T-table with explicit values use T{...}, to convert an existing table t, use T(t). To access table methods of a T-table t, use t:methodname(args).

Some functions, such as table.map(t, fn), are optimized for arrays. These functions have the same name as the regular functions, but preceded with an "arr", such as table.arrmap(t, fn). These are only needed, if explicit nil handling between keys is required, that is, if nil is an actual value in the table. This case is very rare, and should not normally be needed. Argument lists are an example of their application.
]]

require 'mathhelper'

-- Constructor for T-tables.
-- t = T{...} for explicit declaration.
-- t = T(regular_table) to cast to a T-table.
function T(t)
	-- Sets T's metatable's index to the table namespace, which will take effect for all T-tables.
	-- This makes every function that tables have also available for T-tables.
	return setmetatable(t, {__index=table})
end

-- Returns true if searchval is in t.
function table.contains(t, searchval)
	for key, val in pairs(t) do
		if val == searchval then
			return true
		end
	end
	
	return false
end

-- Appends an element to the end of an array table.
function table.append(t, val)
	t[#t+1] = val
	return t
end

-- Appends an array table to the end of another array table.
function table.extend(t, t_ext)
	t_ext:map(function (x) t:append(x) end)
	return t
end

-- Returns if the key searchkey is in t.
function table.containskey(t, searchkey)
	return t[searchkey] ~= nil
end

-- Returns a partial table sliced from t, equivalent to t[x:y] in certain languages.
-- Negative indices will be used to access the table from the other end.
function table.slice(t, from, to)
	from = from or 1
	if from < 0 then
		-- Modulo the negative index, to get it back into range.
		from = from%#t+1
	end
	to = to or #t
	if to < 0 then
		-- Modulo the negative index, to get it back into range.
		to = (to-1)%#t+1
	end
	
	-- Copy relevant elements into a blank T-table.
	local res = T{}
	for i = from, to do
		res[#res+1] = t[i]
	end
	
	return res
end

-- Applies function fn to all elements of the table and returns the resulting table.
function table.map(t, fn)
	local res = T{}
	for key, val in pairs(t) do
		-- Evaluate fn with the element and store it.
		res[key] = fn(val)
	end
	
	return res
end

-- Analogon to table.map, but for array-tables. Possibility to include nil values.
function table.arrmap(t, fn)
	local res = T{}
	for key = 1, #t do
		-- Evaluate fn with the element and store it.
		res[key] = fn(t[key])
	end
	
	return res
end

-- Returns a table with all elements from t that satisfy the condition fn.
function table.filter(t, fn)
	local res = T{}
	for key, val in pairs(t) do
		-- Only copy if fn(val) evaluates to true
		if fn(val) then
			res[key] = val
		end
	end
	
	return res
end

-- Returns a table with all elements from t whose keys satisfy the condition fn.
function table.filterkey(t, fn)
	local res = T{}
	for key, val in pairs(t) do
		-- Only copy if fn(key) evaluates to true
		if fn(key) then
			res[key] = val
		end
	end
	
	return res
end

-- Returns the result of applying the function fn to the first two elements of t, then again on the result and the next element from t, until all elements are accumulated.
-- init is an optional initial value to be used. If provided, init and t[1] will be compared first, otherwise t[1] and t[2].
function table.reduce(t, fn, init)
	t = T(t)
	
	-- Return the initial argument if table is empty
	if t:isempty() then
		return init
	end
	
	-- Set the accumulator variable to the init value (which can be nil as well)
	acc = init
	for key, val in pairs(t) do
		-- If the accumulator is nil, which can only happen on the first iteration and if no initial value was provided, set acc to the first value val.
		if acc == nil then
			acc = val
		-- If not, which will hold true for all subsequent values, apply the funtion to the accumulated value and the next table value and store the result.
		else
			acc = fn(acc, val)
		end
	end
	
	return acc
end

-- Return true if any element of t satisfies the condition fn.
function table.any(t, fn)
	for key, val in pairs(t) do
		if(fn(val) == true) then
			return true
		end
	end
	
	return false
end

-- Return true if all elements of t satisfy the condition fn.
function table.all(t, fn)
	for key, val in pairs(t) do
		if(fn(val) ~= true) then
			return false
		end
	end
	
	return true
end

-- Concatenates all elements with a whitespace in between.
function table.sconcat(t)
	return table.concat(t, ' ')
end

-- Sum up all elements of a table.
function table.sum(t)
	return table.reduce(t, math.sum, 0)
end

-- Multiply all elements of a table.
function table.mult(t)
	return table.reduce(t, math.mult, 1)
end

-- Check if table is empty.
function table.isempty(t)
	return next(t) == nil
end
