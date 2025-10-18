-- Author: Samuel Lafond
-- Date: 30-09-2025
-- Version: 0.1
-- Generate a one macro per exe cue
function generate_macro_iterator()
	-- Ask for Exe
	local exe_number = gma.textinput("Enter exe number");
	local seq_handle;
	
	-- Verify if exe contains seq and save sequence name
	local exe_handle = get_exe_handle(exe_number)
	if (exe_handle == nil) then
		gma.echo("executor " .. exe_number .. " is empty");
		return;
	end
	local exe_name = get_object_name(exe_handle);
	
	gma.echo("Executor name: " .. exe_name);

	-- remove exe number from sequence name
	local seq_name = string.gsub(exe_name, exe_number, "");
	-- remove space
	seq_name = string.gsub(seq_name, " ", "");
	
	-- get executor's sequence handle
	seq_handle = get_seq_handle(seq_name);
	
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
	
	-- Create i_exe sequence
	--gma.echo("Creating sequence: "..i_seq_name);
	--gma.cmd("store sequence ".. "\""..i_seq_name.."\" /o");
	--
	---- Create one cue for each cue in dest exe
	--for i, cue in ipairs(cue_table) do
	--	local cue_name = "\"load_"..cue.name.."_"..exe_name.."\"";
	--	local cmd_string = "/cmd=\"load cue "..cue.number.." exe "..exe_number.."\"";
	--	-- Store cue
	--	gma.cmd("store cue " .. i .. "/o seq \"".. i_seq_name.."\"");
	--	-- Label cue with destination cue name
	--	gma.cmd("label seq \""..i_seq_name.. "\" cue "..i..cue_name);
	--	-- Add goto cmd
	--	gma.cmd("assign cue "..i.." seq ".."\""..i_seq_name.."\"".." "..cmd_string);
	--end	
	--
	---- add a cleanup macro to delete i_seq
	--local clean_macro_name = '"cleanup_'..i_seq_name..'"';
	--local del_cmd_var = i_seq_name.."_VAR";
	--gma.user.setvar(del_cmd_var, 'delete sequence "'..i_seq_name..'"');
	--gma.cmd("store macro "..clean_macro_name.." /o");
	--gma.cmd("store macro 1."..clean_macro_name..".1");-- call delete cmd
	--gma.cmd("store macro 1."..clean_macro_name..".2");-- delete var
	--gma.cmd("store macro 1."..clean_macro_name..".3");-- delete macro
	--gma.cmd('assign macro 1.'..clean_macro_name..'.1 /cmd="$'..del_cmd_var..'"');
	--gma.cmd('assign macro 1.'..clean_macro_name..'.2 /cmd="setuservar $'..del_cmd_var..'=\'\'');
	--gma.cmd('assign macro 1.'..clean_macro_name..'.3 /cmd="delete macro cleanup_'..i_seq_name..'"');
	

end


return generate_macro_iterator;