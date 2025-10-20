-- Author: Samuel Lafond
-- Date: 30-09-2025
-- Version: 0.1
-- Generate a one macro per exe cue
function generate_macro_iterator()
	local getO=gma.show.getobj;
	local getP = gma.show.property;
	local seq_handle;
	
	-- Ask for Exe
	local exe_number = gma.textinput("Enter exe number");

	-- Verify if exe contains seq and save sequence name
	local exe_handle = getO.handle("exe " .. exe_number)
	if (exe_handle == nil) then
		gma.echo("executor " .. exe_number .. " is empty");
		return;
	end
	local seq_name = getP.get(exe_handle, "Name");
	
	gma.echo("Sequence name: " .. seq_name);
	
	-- get executor's sequence handle
	seq_handle = getO.handle("sequence \"" .. seq_name .. "\"");
	
	if (seq_handle == nil) then
		gma.echo("Error: Could not get sequence handle");
		return;
	end

	-- get cue list and cue name
	local cue_table = get_cue_table(seq_handle);

	for i, cue in ipairs(cue_table) do
		gma.echo("cue " .. i .. " name: " .. cue.name);
	end		

	-- ask for macro start location
	local macro_start_idx = gma.textinput("Enter macro start location (required "..#cue_table.." slot");
	if (macro_start_idx == nil) then
		gma.echo("Error: macro start number is not valid");
		return;
	end
	
	macro_start_idx = math.floor(tonumber(macro_start_idx));
	
	-- for each cue, store a macro calling that cue on the choosen exe
		for i, cue in ipairs(cue_table) do
		local macro_name = "goto_"..sanitize_name(cue.name).."_"..sanitize_name(exe_name);
		gma.cmd("store macro "..(macro_start_idx+ i - 1).. " \""..macro_name.."\"");
		gma.cmd("store macro 1.\""..macro_name.."\".1");-- call delete cmd
		gma.cmd('assign macro 1."'..macro_name..'".1 /cmd="goto cue '..cue.number..' exe '..exe_number..'"');		
	end
	
end


return generate_macro_iterator;