local S = attrans

-- Gets called when an entity is made - will set the right livery that was painted
local function tram_set_textures(self, data)
    local new_textures = self.textures
	if data.livery then
        new_textures[2] = data.livery.painting
        new_textures[3] = data.livery.line
	end
    self.object:set_properties({textures=new_textures})
end

local function tram_set_line(self, data, train)
    local line = nil
    local new_line_tex="somemoretrains_tram_line.png"
	self.line_cache=train.line
	local lint = train.line
	if string.sub(train.line, 1, 1) == "S" then
		lint = string.sub(train.line,2)
	end
	if string.len(lint) == 1 then
		if lint=="X" then line="X" end
		line = tonumber(lint)
	elseif string.len(lint) == 2 then
		if tonumber(lint) then
			line = lint
		end
	end
	if line then
		if type(line)=="number" or line == "X" then
			new_line_tex = new_line_tex.."^somemoretrains_tram_line"..line..".png"
		else
			local num = tonumber(line)
			local red = math.fmod(line*67+101, 255)
			local green = math.fmod(line*97+109, 255)
			local blue = math.fmod(line*73+127, 255)
			new_line_tex = new_line_tex..string.format("^(somemoretrains_tram_line.png^[colorize:#%X%X%X%X%X%X)^(somemoretrains_tram_line%s_.png^somemoretrains_tram_line_%s.png", math.floor(red/16), math.fmod(red,16), math.floor(green/16), math.fmod(green,16), math.floor(blue/16), math.fmod(blue,16), string.sub(line, 1, 1), string.sub(line, 2, 2))
			if red + green + blue > 512 then
				new_line_tex = new_line_tex .. "^[colorize:#000)"
			else
				new_line_tex = new_line_tex .. ")"
			end
		end
	elseif self.line_cache~=nil and line==nil then
		self.line_cache=nil
	end
    data.livery.line = new_line_tex
	tram_set_textures(self, data)
end

-- Gets called one, currently when punched with bike painter
local function tram_set_livery(self, puncher, itemstack, data)
    local itmstck=puncher:get_wielded_item()
    local item_name = ""
    if itmstck then item_name = itmstck:get_name() end

    if item_name == "bike:painter" then
        local meta = itemstack:get_meta()
        local newliv = "somemoretrains_tram_painting.png"
	    local color = meta:get_string("paint_color")
        --minetest.chat_send_all('color: '.. color)
        if color == "#0000FF" then
            newliv = "somemoretrains_tram_painting_blue.png"
        end
        if color == "#FF0000" then
            newliv = "somemoretrains_tram_painting_red.png"
        end
        if color == "#00FF00" then
            newliv = "somemoretrains_tram_painting.png"
        end
        if color == "#FFFF00" then
            newliv = "somemoretrains_tram_painting_yellow.png"
        end
        data.livery.painting = newliv
        tram_set_textures(self, data)
        --self:set_textures(data)
    end
end

advtrains.register_wagon("tram", {
	mesh="somemoretrains_tram.b3d",
	textures = {
                "somemoretrains_tram_cyan.png", --chassis
                "somemoretrains_tram_painting.png", --painting
                "somemoretrains_tram_line.png", --line sign
                "somemoretrains_tram_glass.png", --glass
                "somemoretrains_tram_glass.png", --glass
                "somemoretrains_tram_wood2.png", --interior
                "somemoretrains_tram_grey.png", --lente farol
                "somemoretrains_tram_black.png", --roof
                "somemoretrains_tram_black.png", --roof2
                "somemoretrains_tram_black2.png", --sapata
                "somemoretrains_tram_wood.png", --seat
                "somemoretrains_tram_black.png", --wheels
                },
	drives_on={default=true},
	max_speed=8,
	seats = {
		{
			name="Driver stand",
			attach_offset={x=0, y=0, z=12},
			view_offset={x=0, y=0, z=0},
			group="dstand",
		},
		{
			name="1",
			attach_offset={x=-3, y=-1, z=5},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=3, y=-1, z=5},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-3, y=-1, z=-5},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=3, y=-1, z=-5},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
	},
	seat_groups = {
		dstand={
			name = "Driver Stand",
			access_to = {"pass"},
			require_doors_open=false,
			driving_ctrl_access=true,
		},
		pass={
			name = "Passenger area",
			access_to = {"dstand"},
			require_doors_open=false,
		},
	},
	assign_to_seat_group = {"pass", "dstand"},
	visual_size = {x=1, y=1},
	wagon_span=2,
	--collisionbox = {-1.0,-0.5,-1.8, 1.0,2.5,1.8},
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	is_locomotive=true,
	drops={"default:steelblock 4"},
	horn_sound = "somemoretrains_tram_horn",
	custom_on_velocity_change = function(self, velocity, old_velocity, dtime)
		if not velocity or not old_velocity then return end
		if old_velocity == 0 and velocity > 0 then
			minetest.sound_play("somemoretrains_tram_depart", {object = self.object})
		end
		if velocity < 2 and (old_velocity >= 2 or old_velocity == velocity) and not self.sound_arrive_handle then
			self.sound_arrive_handle = minetest.sound_play("somemoretrains_tram_arrive", {object = self.object})
		elseif (velocity > old_velocity) and self.sound_arrive_handle then
			minetest.sound_stop(self.sound_arrive_handle)
			self.sound_arrive_handle = nil
		end
		if velocity > 0 and (self.sound_loop_tmr or 0)<=0 then
			self.sound_loop_handle = minetest.sound_play({name="somemoretrains_tram_loop", gain=0.3}, {object = self.object})
			self.sound_loop_tmr=3
		elseif velocity>0 then
			self.sound_loop_tmr = self.sound_loop_tmr - dtime
		elseif velocity==0 then
			if self.sound_loop_handle then
				minetest.sound_stop(self.sound_loop_handle)
				self.sound_loop_handle = nil
			end
			self.sound_loop_tmr=0
		end
	end,
	custom_on_step = function(self, dtime, data, train)
        if data.livery == nil then
            data.livery = {painting="somemoretrains_tram_painting.png",line="somemoretrains_tram_line.png"}
            tram_set_textures(self, data)
        end
        --[[if data.livery ~= self.textures[2] then
            minetest.chat_send_all('data.livery: '.. data.livery .. ' - texture: ' .. self.textures[2])
            tram_set_textures(self, data)
        end]]--
		--set line number
		local line = nil
		if train.line and self.line_cache ~= train.line then
            tram_set_line(self, data, train)
		end	
	end,
	set_textures = tram_set_textures,
    set_livery = tram_set_livery,
}, S("Tram"), "somemoretrains_tram_inv.png")

--wagons
minetest.register_craft({
	output = 'advtrains:tram',
	recipe = {
		{'default:steelblock', 'group:wood', 'default:steelblock'},
		{'group:wood', 'default:glass', 'group:wood'},
		{'default:steelblock', 'default:steelblock', 'default:steelblock'},
	},
})
