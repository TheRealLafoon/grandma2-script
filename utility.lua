-- Utility code for grandMA2 scripts

function my_print(string)
gma.echo(string);
end

function get_object_name(handle)
	local getO=gma.show.getobj;
	local obj_name = getO.name(handle);
	return obj_name;	
end

function get_seq_handle(name)
	local seqHandle = gma.show.getobj.handle("sequence " .. name);
	return seqHandle;
end

function get_exe_handle(exe_number)
    local exeHandle = gma.show.getobj.handle("exe " .. exe_number);
    return exeHandle;
end

function get_cue_table(seq_handle)
	local cue_handle;
	local getO=gma.show.getobj;
	local cue_table={};
	local cue_count = getO.amount(seq_handle)-1;--exlude cue 0
	gma.echo("cue count " .. cue_count);
	-- loop through cue list, skip cue 0
	for i = 1, cue_count, 1 do
		cue_handle = getO.child(seq_handle, i);
		cue_table[i] = {name=getO.name(cue_handle), number=getO.number(cue_handle)};
	end
	return cue_table;
end