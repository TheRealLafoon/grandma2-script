-- Utility code for grandMA2 scripts

function my_print(string)
gma.echo(string);
end

function print_obj_property(handle)
	local getP = gma.show.property;
	local amount = getP.amount(handle)
	gma.echo("property amount: "..amount)
	for i = 0, amount-1, 1 do
		text = string.format("property: %s, value: %s", getP.name(handle, i), getP.get(handle, i))
		gma.echo(text)
	end 	
end

--function print_obj(handle)
--	local getO = gma.show.getobj
--	text = string.format("class: %s, index: %d, number: %d, name: %s, label: %s,)

-- number:amount            = gma.show.property.amount(number:handle)
-- string:property_name     = gma.show.property.name(number:handle,number:index)
-- string:property          = gma.show.property.get(number:handle,number:index/string:property_name)

-- fonction simple pour nettoyer un nom (enlever guillemets et remplacer espaces par _)
function sanitize_name(name)
    if not name then return "noname" end
    -- enlever guillemets doubles et simples
    name = name:gsub('"', ''):gsub("'", "")
    -- remplacer espaces et caractères non-alphanum par underscore
    name = name:gsub("%s+", "_"):gsub("[^%w_%-]", "_")
    return name
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