
--function get_exe_sequence(exe_number)
--    local exeHandle = gma.show.getobj.handle("exe " .. exe_number);
--    return exeHandle;
--end
--
--function get_seq_handle(name)
--	local seqHandle = gma.show.getobj.handle("sequence " .. name);
--	return seqHandle;
--end
--
--function get_object_name(handle)
--	local getO=gma.show.getobj;
--	local obj_name = getO.name(handle);
--	return obj_name;	
--end
--
--function get_cue_table(seq_handle)
--	local cue_handle;
--	local getO=gma.show.getobj;
--	local cue_table={};
--	local cue_count = getO.amount(seq_handle)-1;--exlude cue 0
--	gma.echo("cue count " .. cue_count);
--	-- loop through cue list, skip cue 0
--	for i = 1, cue_count, 1 do
--		cue_handle = getO.child(seq_handle, i);
--		cue_table[i] = {name=getO.name(cue_handle), number=getO.number(cue_handle)};
--	end
--	return cue_table;
--end

function generate_iterator()
	-- Ask for Exe
	local exe_number = gma.textinput("Enter exe number");
	local seq_handle;
	local getO=gma.show.getobj;
	local getP = gma.show.property;
	
	-- Verify if exe contains seq and save sequence name
	local exe_handle = getO.handle("exe ".. exe_number)
	if (exe_handle == nil) then
		gma.echo("executor " .. exe_number .. " is empty");
		return;
	end
		
	print_obj_property(exe_handle)
	
	local seq_name = getP.get(exe_handle, "Name");
	
	gma.echo("Sequence name: " .. seq_name);
	
	seq_handle = getO.handle("sequence \""..seq_name.."\"")
		
	-- clean name: remove "" or space
	seq_name = sanitize_name(seq_name)
	--seq_name = string.gsub(seq_name, " ", "");
		
	if (seq_handle == nil) then
		gma.echo("Error: Could not get sequence handle");
		return;
	end

	gma.echo(get_object_name(seq_handle))
	-- get cue list and cue name
	local cue_table = get_cue_table(seq_handle);

	for i, cue in ipairs(cue_table) do
		gma.echo("cue " .. i .. " name: " .. cue.name);
	end		
	
	-- search for sequence name i_sequence_name
	local i_seq_name = "i_"..seq_name;
	i_seq_name = string.gsub(i_seq_name, " ", "_");--remove space
	i_seq_name = string.gsub(i_seq_name, "%.", "_");-- remove dot
	local i_seq_handle = get_seq_handle("\""..i_seq_name.."\"");
	local overwrite_i_seq=0;
	-- if iterator sequence already exist, ask user confirmation before deleting
	if (i_seq_handle ~= nil) then
		overwrite_i_seq = gma.gui.confirm("Please Confirm", i_seq_name .. " already exist, overwrite?");
	
		if (overwrite_i_seq) then
			gma.cmd("delete cue 2 thru seq \""..i_seq_name.."\" /nc");
		else
			gma.echo("Iterator generator cancelled");
			return;
		end
	end
	-- Create i_exe sequence
	gma.echo("Creating sequence: "..i_seq_name);
	gma.cmd("store sequence ".. "\""..i_seq_name.."\" /o");
	
	-- Create one cue for each cue in dest exe
	for i, cue in ipairs(cue_table) do
		local cue_name = "\"load_"..sanitize_name(cue.name).."_"..seq_name.."\"";
		local cmd_string = "/cmd=\"load cue "..cue.number.." exe "..exe_number.."\"";
		-- Store cue
		gma.cmd("store cue " .. i .. "/o seq \"".. i_seq_name.."\"");
		-- Label cue with destination cue name
		gma.cmd("label seq \""..i_seq_name.. "\" cue "..i..cue_name);
		-- Add goto cmd
		gma.cmd("assign cue "..i.." seq ".."\""..i_seq_name.."\"".." "..cmd_string);
	end	
	
	-- add a cleanup macro to delete i_seq
	local clean_macro_name = '"cleanup_'..i_seq_name..'"';
	local del_cmd_var = i_seq_name.."_VAR";
	gma.user.setvar(del_cmd_var, 'delete sequence "'..i_seq_name..'"');
	gma.cmd("store macro "..clean_macro_name.." /o");
	gma.cmd("store macro 1."..clean_macro_name..".1");-- call delete cmd
	gma.cmd("store macro 1."..clean_macro_name..".2");-- delete var
	gma.cmd("store macro 1."..clean_macro_name..".3");-- delete macro
	gma.cmd('assign macro 1.'..clean_macro_name..'.1 /cmd="$'..del_cmd_var..'"');
	gma.cmd('assign macro 1.'..clean_macro_name..'.2 /cmd="setuservar $'..del_cmd_var..'=\'\'');
	gma.cmd('assign macro 1.'..clean_macro_name..'.3 /cmd="delete macro cleanup_'..i_seq_name..'"');
	

end


return generate_iterator;