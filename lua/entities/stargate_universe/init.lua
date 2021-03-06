/*
	Stargate Universe for GarrysMod10
	Copyright (C) 2011  Llapp
	Edited by AlexALX
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
include("modules/dialling.lua");
include("modules/wire_dial.lua");

ENT.Models = {
	Base="models/The_Sniper_9/Universe/Stargate/universegate.mdl",
	Ring="models/Iziraider/ring/ring.mdl",
    Chevrons="models/The_Sniper_9/Universe/Stargate/universechevrons.mdl",
	Symbol="models/The_Sniper_9/Universe/Stargate/symbolon.mdl",
}
ENT.Sounds = {
	Open=Sound("stargate/universe/gate_open.mp3"),
	Travel=Sound("stargate/gate_travel.mp3"),
	Close=Sound("stargate/universe/gate_close.mp3"),
	ChevronDHD=Sound("stargate/universe/chevron.mp3"),
	Inbound=Sound("stargate/universe/chevron.mp3");
	Lock=Sound("stargate/universe/chevron_lock.mp3"),
	LockDHD=Sound("stargate/universe/chevron.mp3"),
	Chevron=Sound("stargate/universe/chevlocked.wav"),
	Fail=Sound("stargate/universe/fail3.wav"),
	Activate=Sound("stargate/universe/Stargate Begin Roll.mp3"),
	GateRoll=Sound("stargate/universe/Long_Gate_Roll.wav"),
	StopRoll=Sound("stargate/universe/Chevron2.mp3"),
    EndRoll=Sound("stargate/universe/endroll.mp3"),
}

ENT.Mats = {
  Off="The_Sniper_9/Universe/Stargate/UniverseChevronOff.vmt",
  On="The_Sniper_9/Universe/Stargate/UniverseChevronOn.vmt",
}

--################# Added by AlexALX

ENT.SymbolsLockGroup = {
	Z = {8, 1},
	B = {16, 2},
	[9] = {24, 3},
	J = {32, 4},
	Q = {48, 6},
	N = {56, 7},
	L = {64, 8},
	M = {72, 9},
	V = {88, 11},
	K = {96, 12},
	O = {104, 13},
	[6] = {112, 14},
	D = {128, 16},
	C = {136, 17},
	W = {144, 18},
	Y = {152, 19},
	["#"] = {168, 21},
	R = {176, 22},
	["@"] = {184, 23},
	S = {192, 24},
	[8] = {208, 26},
	A = {216, 27},
	P = {224, 28},
	U = {232, 29},
	T = {248, 31},
	[7] = {256, 32},
	H = {264, 33},
	[5] = {272, 34},
	[4] = {288, 36},
	I = {296, 37},
	G = {304, 38},
	[0] = {312, 39},
	[1] = {328, 41},
	[2] = {336, 42},
	E = {344, 43},
	[3] = {352, 44},

	-- not visible on model
	F = {80, 10},
	X = {280, 35},
}

ENT.SymbolsLockGalaxy = {
	Z = {8, 1},
	B = {16, 2},
	[9] = {24, 3},
	J = {32, 4},
	Q = {48, 6},
	N = {56, 7},
	L = {64, 8},
	M = {72, 9},
	V = {88, 11},
	K = {96, 12},
	O = {104, 13},
	[6] = {112, 14},
	D = {128, 16},
	C = {136, 17},
	W = {144, 18},
	Y = {152, 19},
	["#"] = {168, 21},
	R = {176, 22},
	["@"] = {184, 23},
	S = {192, 24},
	[8] = {208, 26},
	A = {216, 27},
	P = {224, 28},
	U = {232, 29},
	T = {248, 31},
	[7] = {256, 32},
	H = {264, 33},
	[5] = {272, 34},
	[4] = {288, 36},
	I = {296, 37},
	G = {304, 38},
	["!"] = {312, 39},
	[1] = {328, 41},
	[2] = {336, 42},
	E = {344, 43},
	[3] = {352, 44},

	-- not visible on model
	F = {80, 10},
	X = {280, 35},
}

--################# SENT CODE ###############

function ENT:Initialize()
	self.Entity:SetModel(self.Models.Base);
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA);
	self.Entity:SetColor(Color(0,0,0,1)); --this make the entity invisible but alpha must be 1 for dynamic lights!
	self.BaseClass.Initialize(self); -- BaseClass Initialize call
	self:AddModels();
	self.Speed = false;
	self:AddSymbols();
	self.InboundSymbols = 0;
	self.SpinSpeed = 0;
	self.Stop = false;
	self.PlaySp = false;
	self.Speroll = 0;
	self.DiallingSymbol = "";
	self.RingSymbol = "";
	self.SpinBack = false;
	self.StopRollSP = false;
	self.WireSpin = false;
	self.WireSpinSpeed = false;
end

--#################  Called when stargate_group_system changed
function ENT:ChangeSystemType(groupsystem,reload)
	local delay = 4.5
	if (reload) then delay = 2.5 end
	if (groupsystem) then
		if (self.GateSpawnerSpawned) then
			timer.Simple(delay, function()
				if (IsValid(self)) then
					self:GateWireInputs(groupsystem);
				end
			end)
			timer.Simple(2, function()
				if (IsValid(self)) then
					self:GateWireOutputs(groupsystem);
					self:SetWire("Dialing Mode",-1);
					self:SetChevrons(0,0);
				end
			end)
		else
			self:GateWireInputs(groupsystem);
			self:GateWireOutputs(groupsystem);
			self:SetWire("Dialing Mode",-1);
			self:SetChevrons(0,0);
		end
		self.SymbolsLock = self.SymbolsLockGroup;
		self.WireCharters = "A-Z0-9@#";
	else
		if (self.GateSpawnerSpawned) then
			timer.Simple(delay, function()
				if (IsValid(self)) then
					self:GateWireInputs(groupsystem);
				end
			end)
			timer.Simple(2, function()
				if (IsValid(self)) then
					self:GateWireOutputs(groupsystem);
					self:SetWire("Dialing Mode",-1);
					self:SetChevrons(0,0);
				end
			end)
		else
			self:GateWireInputs(groupsystem);
			self:GateWireOutputs(groupsystem);
			self:SetWire("Dialing Mode",-1);
			self:SetChevrons(0,0);
		end
		self.SymbolsLock = self.SymbolsLockGalaxy;
		self.WireCharters = "A-Z1-9@#!";
		if (self:GetGateAddress():find("[0]")) then self:SetGateAddress("");
		elseif (self:GetGateAddress()!="") then
			for _,v in pairs(ents.FindByClass("stargate_*")) do
				if (self.Entity != v.Entity and v.IsStargate and v:GetClass()!="stargate_supergate" and v:GetGateAddress()!="") then
					local address, a = self:GetGateAddress(), string.Explode("",v:GetGateAddress());
					if (address:find(a[1]) and address:find(a[2]) and address:find(a[3]) and address:find(a[4]) and address:find(a[5]) and address:find(a[6])) then self:SetGateAddress(""); end
				end
			end
		end
	end
	if (reload) then
		StarGate.ReloadSystem(groupsystem);
	end
end

function ENT:GateWireInputs(groupsystem)
	self:CreateWireInputs("Dial Address","Dial String [STRING]","Dial Mode","Start String Dial","Close","Disable Autoclose","Transmit [STRING]","Rotate Ring","Ring Speed Mode","Encode Symbol","Symbols Lock","Inbound Symbols","Activate Chevrons","Activate Symbols","Disable Menu");
end

function ENT:GateWireOutputs(groupsystem)
	self:CreateWireOutputs("Active","Open","Inbound","Chevron","Chevron Locked","Ring Symbol [STRING]","Ring Rotation","Dialing Address [STRING]","Dialing Mode","Dialing Symbol [STRING]","Dialed Symbol [STRING]","Received [STRING]");
end

function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	local pos = t.HitPos+Vector(0,0,90);
	local e = ents.Create("stargate_universe");
	e:SetPos(pos);
	e:DrawShadow(false);
    e:Spawn();
	e:Activate();
	e:SetAngles(ang);
	e:SetGateGroup("U@#");
	e:SetLocale(true);
	e:CartersRamps(t); -- put gate on carters ramps
	e:SetWire("Dialing Mode",-1);
	return e;
end

function ENT:AddModels()
	local pos = self.Entity:GetPos();
	local e2 = ents.Create("prop_dynamic_override");
	e2:SetModel(self.Models.Base);
    e2:SetKeyValue("solid",0);
	e2:SetPos(pos);
	e2:SetParent(self.Entity);
	e2:DrawShadow(true);
	e2:Spawn();
	e2:Activate();
	self.Gate = e2;
	self.Gate.Entity = e2;
	self.Gate.Moving = false;
	self.AngGate = self.Gate:GetAngles();
	local e3 = ents.Create("prop_dynamic_override");
	e3:SetModel(self.Models.Chevrons);
    e3:SetKeyValue("solid",0);
	e3:SetPos(pos);
	e3:SetParent(self.Gate);
	e3:DrawShadow(true);
	e3:Spawn();
	e3:Activate();
	self.Chevron = e3;
	return e2;
end

function ENT:AddSymbols()
	self.Symbols={};
	self.ColR={};
	self.ColG={};
	self.ColB={};
	self.ColA={};
	local pos = self.Gate:GetPos() + self.Gate:GetForward()*0.05;
	local angForw = self.Gate:GetAngles():Up();
	local ang = self.Gate:GetAngles();
	for i=1,45 do
		local e = ents.Create("prop_dynamic_override");
		e:SetModel(self.Models.Symbol);
		e:SetKeyValue("solid",0);
		e:SetParent(self.Gate);
		--e:SetDerive(self.Gate); -- Derive Material/Color from "Parent"
		e:DrawShadow(false);
		e:SetPos(pos);
		local a = angForw*(i*8);
		e:SetAngles(ang-Angle(a[1],a[2],a[3]));
		e:Spawn();
		e:Activate();
        self.Symbols[i] = e;
		local color = e:GetColor();
		self.ColR[i] = color.r;
		self.ColG[i] = color.g;
		self.ColB[i] = color.b;
		self.ColA[i] = color.a;
		e:SetColor(Color(40,40,40,255));
	end
end

--############### Change the Universe Symbol Skin
function ENT:ChangeSkin(skin,inbound,symbol)
    if(skin)then
	    if(IsValid(self.Entity))then
		    if(skin > 1 and symbol and symbol!="" and (not inbound or self.InboundSymbols==1))then
			    local i = self.SymbolsLock[tonumber(symbol) or symbol][2]; --self.SymbolPositions[skin-1];
    			self.Symbols[i]:SetColor(Color(self.ColR[i],self.ColG[i],self.ColB[i],self.ColA[i]));
			elseif(skin == 0)then
			    for i=1,45 do
				    local c = self.Symbols[i]:GetColor();
				    if(self.ColA[i] == c.a)then
				        self.Symbols[i]:SetColor(Color(40,40,40,255));
                    end
				end
				self.Chevron:SetMaterial(self.Mats.Off);
			elseif(skin == 1)then
			    self.Chevron:SetMaterial(self.Mats.On);
			end
		end
	end
end

--############# Activate/Deactivate all symbols by AlexALX
function ENT:ActivateSymbols(deactivate)
	if (not IsValid(self.Entity)) then return end
	if (not deactivate) then
		for i=1,45 do
			self.Symbols[i]:SetColor(Color(self.ColR[i],self.ColG[i],self.ColB[i],self.ColA[i]));
		end
	else
		for i=1,45 do
		    self.Symbols[i]:SetColor(Color(40,40,40,255));
		end
	end
end

--############# Activate Sound
function ENT:ActivateGateSound()
    util.PrecacheSound(self.Sounds.Activate)
	self.ActivateSound = CreateSound(self.Entity,self.Sounds.Activate);
	self.ActivateSound:ChangePitch(95,0);
	self.ActivateSound:SetSoundLevel(94);
	self.ActivateSound:PlayEx(1,97);
end

function ENT:StopRollSound()
    util.PrecacheSound(self.Sounds.StopRoll)
    self.StopRollSP = true;
	self.StopRollS = CreateSound(self.Entity,self.Sounds.StopRoll);
	self.StopRollS:ChangePitch(95,0);
	self.StopRollS:SetSoundLevel(94);
	self.StopRollS:PlayEx(1,107);
end

--############# stop at started position
function ENT:StopAtStartPos()
	self.Stop = true;
end

function ENT:SpinSound(spin)
    if(spin)then
	    util.PrecacheSound(self.Sounds.GateRoll)
        self.RollSound = CreateSound(self.Entity,self.Sounds.GateRoll);
	    self.RollSound:ChangePitch(95,0);
	    self.RollSound:SetSoundLevel(99);
	    self.RollSound:PlayEx(1,85);
	    self.StopRollSP = false;
	else
        if(self.RollSound)then
		    self.RollSound:Stop();
		end
	end
end

--############# let the gate rotate with acc/decc
function ENT:Rotation(sse)
    local spr = self.Speroll;
	local e = self.Entity;
	local g = self.Gate;
	local speed,speed2,speed3,speed4 = 0.02,0.18,0.22,1;
	if (self.WireSpin and not self.WireSpinSpeed) then speed,speed2,speed3,speed4 = 0.01, 0.09, 0.11, 0.5; end
	if(sse == 1 and spr < speed4 and spr > -speed)then
        spr = spr + speed;
		self.PlaySp = true;
   	elseif(sse == -1 and spr > -speed4 and spr < speed)then
   	    spr = spr - speed;
		self.PlaySp = true;
   	elseif(sse == 2 and spr < speed4+speed and spr > 0)then
        spr = spr - speed;
    elseif(sse == -2 and spr > -speed4-speed and spr < 0)then
	    spr = spr + speed;
    end
	if(((spr > speed2 and spr < speed3) or (spr < -speed2 and spr > -speed3)) and (sse == 2 or sse == -2))then
	    self:SpinSound(false);
	    self.Entity:SetWire("Ring Rotation",0);
		self:StopRollSound();
	elseif(spr > 0 and spr < speed)then
   	    spr = 0;
   		self.SpinSpeed = 0;
   	end
	self.Speroll = spr;
   	if(spr ~= 0)then
        g:SetParent(nil);
        g:SetAngles(g:GetAngles() + Angle(0,0,spr));
        g:SetParent(e);
   	end
	local val = (g:GetAngles().p + g:GetAngles().y + g:GetAngles().r) % 360;
	local angGate = math.floor(val);
	val = string.Explode(".",tostring(val));
	if (val[2]) then
		val = tonumber(string.format("%f","0."..val[2]));
	else val = 0 end
	local va = 24;
	if(val > 0.5)then va = 25 end ;
	local angEnt = math.floor((e:GetAngles().p + e:GetAngles().y + e:GetAngles().r - va) % 360);
	if(angGate == angEnt and self.Stop)then
	    self:SetSpeed(false);
	end
	if(spr == 0 and self.Stop)then
	    g:SetAngles(Angle(e:GetAngles().p,e:GetAngles().y,e:GetAngles().r));
	    self.Stop = false;
	    if(self.PlaySp)then
	    	self.PlaySp = false;
	    end
	end
end

function ENT:Think()
	if (not IsValid(self)) then return false end;
    self:Rotation(self.SpinSpeed);
    self:UpdateEntity();
	self.Entity:NextThink(CurTime()+0.001);
	return true;
end

function ENT:UpdateEntity()
  self.Entity:SetColor(Color(0,0,0,1));
end

-- Damn, I spent the whole day and night for calculating this formula.
function ENT:StopFormula(y,x,n,n2)
	if (y==nil or x==nil) then return end
	local stop = false;
	local b,c;
	if (self.SpinSpeed==1) then
		if (x<n) then
			b = 360-(n-x);
			if (x<n2) then
				c = 360-(n2-x);
				if (y >= b and y <= c) then stop = true; end
			else
				c = x-n2;
				if (y >= b and c <= y) then stop = true; end
			end
		else
			b = x-n;
			c = x-n2;
			if (y >= b and y <= c) then stop = true; end
		end
	elseif(self.SpinSpeed==-1) then
		local b
		if (x>=(360-n)) then
			b = (x+n)-360;
			if (x>=(360-n2)) then
				c = (x+n2)-360;
				if (y <= b and y >= c) then stop = true; end
			else
				c = x+n2;
				if (y <= b and c >= y) then stop = true; end
			end
		else
			b = x+n;
			c = x+n2;
			if (y <= b and y >= c) then stop = true; end
		end
	end
	return stop;
end

--################# Tick function added by AlexALX
function RingTickUniverse()
	for _,self in pairs(ents.FindByClass("stargate_universe")) do
		if (IsValid(self.Gate)) then
			if ((self.Outbound or self.WireSpin) and self.Gate.Moving) then
				local y = tonumber(math.NormalizeAngle(self.Gate.Entity:GetLocalAngles().r));
				if (y<0) then y = y+360; end;
				local reset = true;
				local symbols = self.SymbolsLock;
				local s1,s2 = 7.5,4.5;
				if (self.WireSpinSpeed) then
					s1,s2 = 26.5,23.5;
				end
				for k, v in pairs(symbols) do
					local symbol = self:StopFormula(y,tonumber(self.SymbolsLock[tonumber(k) or k][1]),s1,s2);
					if (symbol) then
						self.Entity:SetWire("Ring Symbol",tostring(k)); -- Wire
						self.RingSymbol = tostring(k);
						reset = false;
					end
				end
				if (reset and self.RingSymbol != "") then
					self.Entity:SetWire("Ring Symbol",""); -- Wire
					self.RingSymbol = "";
				end
				if (self.DiallingSymbol != "") then
					if (self.SymbolsLock[tonumber(self.DiallingSymbol) or self.DiallingSymbol]==nil) then self:AbortDialling(); self.Gate.Moving = false; else
						local x = tonumber(self.SymbolsLock[tonumber(self.DiallingSymbol) or self.DiallingSymbol][1]);
						if (self:StopFormula(y,x,25,24)) then
							self:SetSpeed(false);
							self.Entity:DHDSetAllBusy();
							self.Gate.Moving = false;
							self.Entity:PauseActions(true);
						end
					end
				end
			end
		end
	end
end
hook.Add("Tick", "RingTick Universe", RingTickUniverse);

function ENT:SetDiallingSymbol(symbol)
	if (symbol) then
		self.DiallingSymbol = tostring(symbol);
	end
end

--############# Set gate direction
function ENT:SetSpeed(speed,speed2)
    self.Speed = speed;
    if(IsValid(self.Entity))then
        if(speed)then
	        if(speed2)then
				self.SpinSpeed = -1;
				self.Entity:SetWire("Ring Rotation",1);
		    else
				self.SpinSpeed = 1;
				self.Entity:SetWire("Ring Rotation",-1);
		    end
			self:SpinSound(true);
			self:SetWire("Ring Symbol","");
			timer.Create("RingTickDelay"..self.Entity:EntIndex(), 1.3, 1, function() if IsValid(self.Entity) then self:RingTickDelay() end end);
			--self.Gate.Moving = true;
        else
			if timer.Exists("RingTickDelay"..self.Entity:EntIndex()) then timer.Remove("RingTickDelay"..self.Entity:EntIndex()) end
		    if(self.SpinSpeed == -1)then
			    self.SpinSpeed = -2;
			elseif(self.SpinSpeed == 1)then
			    self.SpinSpeed = 2;
			end
			self.Gate.Moving = false;
        end
	end
end

function ENT:RingTickDelay()
	if(IsValid(self.Entity) and IsValid(self.Gate.Entity))then
		self.Gate.Moving = true;
	end
end

--############# Activates or deactivates dynamic lights of chevrons
function ENT:ActivateLights(active)
    if(IsValid(self.Entity))then
        if(active) then
	        for i=1,18 do
		        self.Entity:SetNetworkedEntity( "GateLights", self.Gate );
		        self.Entity:SetNetworkedBool("chevron"..i,true);
	        end
	    else
	       for i=1,18 do
			    self.Entity:SetNetworkedEntity( "GateLights" );
			    self.Entity:SetNWBool("chevron"..i,false);
		    end
	    end
    end
end

--############# Fix the Spin Bugs
function ENT:FixSpin(number)
    self.Entity:SetNetworkedEntity( "SpinNumber", number );
end
function ENT:FixSpinOnChevron(bool)
    self.Entity:SetNetworkedEntity( "ChevronBool", bool );
end

--############# Activates/Deactivates the Steam effect
function ENT:Smoke(smoke)
    if(smoke)then
	    self.Entity:SetNWBool( "Smoke", true )
	else
	    self.Entity:SetNWBool( "Smoke", false )
	end
end

function ENT:SpinFailChecker(sb)
    if(sb)then
	    self.SpinBack = true;
	else
	    self.SpinBack = false;
	end
end

--############# Activates Sound and Steam
function ENT:StopWithSteam(fast,outbound,fail) -- muss noch verbessert werden!!!!
    local delay;
    if(outbound and not fast)then
    	delay = 3.5;
	else
	    if(fast and fail)then
	        delay = 2;
	    else
	        delay = 0;
	    end
	end
	timer.Simple( delay, function()
	    if(IsValid(self.Entity))then
	        self:Smoke(true);
		end
    end);
	timer.Simple( delay+3, function()
		if(IsValid(self.Entity))then
	        self:Smoke(false);
		end
    end);
end

--################# Chevron locking sound
function ENT:ChevronSound(chev)
	util.PrecacheSound(self.Sounds.Chevron)
    self.Entity:EmitSound(self.Sounds.Chevron,90,math.random(95,100));
end

--##############################################################################################################
--##############################################################################################################
--################################################  EVENT  #####################################################
--##############################################################################################################
--##############################################################################################################

--################# Wire input @aVoN
function ENT:TriggerInput(k,v,mobile,mdhd)
	self:TriggerInputDefault(k,v,mobile,mdhd);
	if(k == "Rotate Ring" and not self.Active and (not self.NewActive or self.WireManualDial) and not self.WireBlock) then
		if (v >= 1) then
			if (self:CheckEnergy(true,true) or self.WireManualDial) then
				self.WireSpin = true;
				if (self.WireSpinDir) then
					self.WireSpinDir = false;
				else
					self.WireSpinDir = true;
				end
				self:SetSpeed(true,self.WireSpinDir);
				self.WireBlock = true;
				if (timer.Exists("StarGate.Universe.WireBlock_"..self.Entity:EntIndex())) then
					timer.Remove("StarGate.Universe.WireBlock_"..self.Entity:EntIndex());
				end
				timer.Create("StarGate.Universe.WireBlock_"..self.Entity:EntIndex(), 0.1, 1, function ()
					if (IsValid(self.Entity)) then
						self.WireBlock = false;
					end
				end );
				self.Entity:SetNWBool("ActRotRingL",true);
			end
		elseif (self.WireSpin) then
			self.WireSpin = false;
			self:SetSpeed(false);
			self.WireBlock = true;
			if (timer.Exists("StarGate.Universe.WireBlock_"..self.Entity:EntIndex())) then
				timer.Remove("StarGate.Universe.WireBlock_"..self.Entity:EntIndex());
			end
			timer.Create("StarGate.Universe.WireBlock_"..self.Entity:EntIndex(), 1.0, 1, function ()
				if (IsValid(self.Entity)) then
					self.WireBlock = false;
				end
			end );
			self.Entity:SetNWBool("ActRotRingL",false);
		end
	elseif(k == "Ring Speed Mode" and IsValid(self.Gate) and not self.Active and (not self.NewActive or self.WireManualDial)) then
		if (self:GetWire("Ring Speed Mode",0) >= 1) then
			self.WireSpinSpeed = true;
		else
			self.WireSpinSpeed = false;
		end
	elseif(k == "Encode Symbol" and not self.Active and (not self.NewActive or self.WireManualDial) and not self.WireBlock and not self.WireSpin) then
		if (self:GetWire("Encode Symbol",0) >= 1) then
			self:EncodeChevron();
		end
	elseif(k == "Symbols Lock" and not self.Active and (not self.NewActive or self.WireManualDial) and not self.WireBlock and not self.WireSpin) then
		if (self:GetWire("Symbols Lock",0) >= 1) then
			self:Chevron7Lock();
		end
	elseif(k == "Inbound Symbols")then
		if (v == 1) then
	    	self.InboundSymbols = 1;
	    elseif (v >= 2) then
	    	self.InboundSymbols = 2;
	    else
			self.InboundSymbols = 0;
		end
		self.Entity:SetNWInt("ActSymsI",self.InboundSymbols);
	elseif(k == "Activate Symbols" and not self.NewActive and not self.WireManualDial)then
		if (v >= 1 and self:CheckEnergy(true,true)) then
	    	self:ActivateSymbols();
	    	self.Entity:SetNWBool("ActSymsL",true);
	    else
			self:ActivateSymbols(true);
			self.Entity:SetNWBool("ActSymsL",false);
		end
	elseif(k == "Activate Chevrons" and not self.NewActive and not self.WireManualDial)then
		if (v >= 1 and self:CheckEnergy(true,true)) then
			self.Entity:EmitSound(self.Sounds.Activate,90,math.random(95,100));
	    	self.Chevron:SetMaterial("The_Sniper_9/Universe/Stargate/UniverseChevronOn.vmt");
	    	self.Entity:SetNWBool("ActChevronsL",true);
	    else
			self.Chevron:SetMaterial("The_Sniper_9/Universe/Stargate/UniverseChevronOff.vmt");
			self.Entity:SetNWBool("ActChevronsL",false);
		end
	end
end

--#############################################################
function ENT:BearingSetSkin(BearingLight)
    if(IsValid(self.Entity))then
	    local delay = 0;
	    for k,v in pairs(StarGate.GetConstrainedEnts(self.Entity,2) or {}) do
		    if(v:IsValid() and v:GetClass():find("bearing"))then
			    timer.Create("Bearing"..k..self.Entity:EntIndex(),delay,1,
				    function()
					    if(IsValid(v)) then
					        if(BearingLight)then
				                v:Bearing(true);
						    else
						        v:Bearing(false);
						    end
					    end
				    end
				);
		    end
	    end
    end
end

-- FloorChevron
function ENT:FloorChevron(FloorChevLight)
    if(IsValid(self.Entity))then
	    local delay = 0;
	    for k,v in pairs(StarGate.GetConstrainedEnts(self.Entity,2) or {}) do
		    if(v:IsValid() and v:GetClass():find("floorchevron"))then
			    timer.Create("FloorChevron"..k..self.Entity:EntIndex(),delay,1,
				    function()
					    if(IsValid(v)) then
					        if(FloorChevLight)then
				                v:FloorChev(true);
						    else
						        v:FloorChev(false);
						    end
					    end
				    end
				);
		    end
	    end
    end
end

--SGU Ramp
function ENT:SguRampSetSkin(rampchevlight,rampchevlightoff)
    if(IsValid(self.Entity))then
	    local delay = 0;
	    for k,v in pairs(StarGate.GetConstrainedEnts(self.Entity,2) or {}) do
		    if(v:IsValid() and v:GetClass():find("sgu_ramp"))then
			    timer.Create("SguRamp"..k..self.Entity:EntIndex(),delay,1,
				    function()
					    if(IsValid(v)) then
					        if(rampchevlight)then
				                v:SguRampSkin(2);
						    else
						        v:SguRampSkin(1);
						    end
							if(rampchevlightoff)then v:SguRampSkin(0) end
					    end
				    end
				);
		    end
	    end
    end
end

--#################  When getting removed..
function ENT:OnRemove()
	StarGate.StopUpdateGateTemperatures(self);
	if timer.Exists("LowPriorityThink"..self:EntIndex()) then timer.Remove("LowPriorityThink"..self:EntIndex()) end
	if timer.Exists("ConvarsThink"..self:EntIndex()) then timer.Remove("ConvarsThink"..self:EntIndex()) end
	if timer.Exists("RingTickDelay"..self.Entity:EntIndex()) then timer.Remove("RingTickDelay"..self.Entity:EntIndex()) end

	self:Close(); -- Close the horizon
	self:StopActions(); -- Stop all actions and sounds
	self:DHDDisable(0); -- Shutdown near DHD's
	if(IsValid(self.Target)) then
		if(self.IsOpen) then
			self.Target:DeactivateStargate(true);
		elseif(self.Dialling) then
			self.Target:EmergencyShutdown(true);
		end
	end
	if(self.RollSound)then
	    self.RollSound:Stop();
	end
	if (self.HasRD) then StarGate.WireRD.OnRemove(self) end;
	self:RemoveGateFromList();
end

function ENT:Shutdown() -- It is called at the end of ENT:Close or ENT.Sequence:DialFail
	self.DiallingSymbol = "";
	self.RingSymbol = "";
	self.WireDialledAddress = {};
	self.WireManualDial = false;
	self.WireSpin = false;
	self.WireSpinDir = false;
	self.WireBlock = false;
	if (IsValid(self.Gate)) then
		self.Gate.Moving = false;
	end
	if (IsValid(self.Entity)) then
		self.Entity:SetNWBool("ActChevronsL",false);
		self.Entity:SetNWBool("ActRotRingL",false);
		self.Entity:SetNWBool("ActSymsL",false);
		self:SetWire("Ring Symbol",""); -- Wire
		if timer.Exists("RingTickDelay"..self.Entity:EntIndex()) then timer.Remove("RingTickDelay"..self.Entity:EntIndex()) end
	end
end

--################# DialFail sequence @aVoN
function ENT.Sequence:DialFail(instant_stop,play_sound,fail)
	self:StopActions();
	if timer.Exists("RingTickDelay"..self.Entity:EntIndex()) then timer.Remove("RingTickDelay"..self.Entity:EntIndex()) end
	local action = self:New();
	local delay = 1.5;
	local y = tonumber(math.NormalizeAngle(self.Gate.Entity:GetLocalAngles().r));
	action:Add({f=self.SetShutdown,v={self,true},d=0});
	if ((y>=0.25 or y<=-0.25) and (self.WireSpin or self.WireManualDial)) then
		self.WireSpin = false;
		local delay = 0;
		if (self.WireManualDial) then
			delay = 1;
			if (self.WireSpinDir) then
				action:Add({f=self.SetSpeed,v={self,false},d=delay}); -- Stop at Started Position
				delay = 0;
			end
		end
		action:Add({f=self.SetSpeed,v={self,true},d=delay}); -- Stop at Started Position
	end
	if(self.DialType.Fast or self.WireManualDial)then
		action:Add({f=self.StopAtStartPos,v={self},d=1}); -- Stop at Started Position
	end
	if(instant_stop) then delay = 0 end;
	action:Add({f=self.SetStatus,v={self,false,true,true},d=0}); -- We need to keep in "dialling" mode to get around with conflicts
	if(self.Entity.Active or play_sound) then
		action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Fail,90,math.random(95,105)},d=0});-- Fail sound
	end
	action:Add({f=self.DHDDisable,v={self,1.5,true},d=delay});-- Shutdown EVERY DHD
	action:Add({f=self.ActivateRing,v={self,false},d=0}); -- Deactivate ring (if existant);
	-- Stop all chevrons (if active only!)
	if(self.Entity.Active or play_sound) then
		for i=1,9 do
			action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
		end
	end
	if(self.Shutdown) then
		action:Add({f=self.Shutdown,v={self},d=0});
		action:Add({f=self.ChangeSkin,v={self,0},d=0});  -- @Llapp, needs to change the skin to default!
		action:Add({f=self.FloorChevron,v={self,false},d=0}); -- change the floor chevron skin
		action:Add({f=self.ActivateSymbols,v={self,true},d=0}); -- lights off of symbols
		action:Add({f=self.BearingSetSkin,v={self,false},d=0}); -- change the bearing skin
		action:Add({f=self.SguRampSetSkin,v={self,false,true},d=0}); -- change the sgu ramp skin
		local number=0;
	    if(self.Entity:GetNetworkedEntity( "SpinNumber", number ))then
	        number = self.Entity:GetNetworkedEntity( "SpinNumber", number );
		end
		local lightdelay = 0;
		if(number==2 or number==4 or number==6 or number==8)then
		    lightdelay = 1.6;
		end
	    action:Add({f=self.ActivateLights,v={self,false},d=lightdelay}); -- lights off of chevs -- verbessern
		if(self.Outbound or fail)then -- and self.SpinBack
		    if(not self.DialType.Fast)then
				local chevron = self.Entity:GetNetworkedEntity( "ChevronBool", false );
				if(number==1 or number==3 or number==5 or number==7 or number==9)then
				    action:Add({f=self.SetSpeed,v={self,false},d=2}); -- Pause the ring
				    --action:Add({f=self.StopRollSound,v={self},d=0});
					action:Add({f=self.SetSpeed,v={self,true,false},d=0}); -- Fix the StartAtStopPos
				else
			 	    action:Add({f=self.SetSpeed,v={self,true,false},d=0}); -- Fix the StartAtStopPos
				end
				self.Entity:SetNetworkedEntity( "SpinNumber", 0 );
				self.Entity:SetNetworkedEntity( "ChevronBool", false );
		    end
		end
		action:Add({f=self.StopWithSteam,v={self,self.DialType.Fast,self.Outbound,fail},d=0});
		if(not self.DialType.Fast)then
		    if(fail and self.Outbound)then
		        action:Add({f=self.SetSpeed,v={self,true,false},d=0});
			end
		    action:Add({f=self.StopAtStartPos,v={self},d=1.5}); -- Stop at Started Position
		end
	end

	action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetStatus,v={self,false,false},d=0.8}); -- Make the Wire-Value of "-7" = dial-fail stay longer so people's script work along with the sound
	action:Add({f=self.SetWire,v={self,"Chevron",0},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Chevron Locked",0},d=0}); -- Wire
	action:Add({f=self.SpinFailChecker,v={self,false},d=0});
	action:Add({f=self.SetShutdown,v={self,false},d=0});
	return action;
end

--################# Close wormhole (effect) @aVoN
function ENT:Close(ignore,fast)
	self.DialType = self.DialType or {};
	if (self.DialType.Fast==nil) then self.DialType.Fast = false end
	self:StopActions();
	-- Remove the EH
	if(self.EventHorizon and self.EventHorizon:IsValid()) then
		self.EventHorizon:Shutdown(ignore);
	end
	-- Stop all chevrons
	local action = self.Sequence:New({
		{f=self.SetStatus,v={self,true,true},d=0},
		{pause=true,d=2.7},
	});
	action:Add({f=self.SetShutdown,v={self,true},d=0});
	for i=1,9 do
		action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
	end
	action:Add({f=self.SetStatus,v={self,false,false},d=0}); -- Add the "close" flag
	action:Add({f=self.SetWire,v={self,"Chevron",0},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Chevron Locked",0},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",""},d=0}); -- Wire
	-- Add additional shutdown sequences
	if(self.Shutdown) then
		action:Add({f=self.Shutdown,v={self},d=0});
		action:Add({f=self.ChangeSkin,v={self,0},d=0});  -- @Llapp, needs to change the skin to default!
		action:Add({f=self.ActivateSymbols,v={self,true},d=0}); -- lights off of symbols
		action:Add({f=self.BearingSetSkin,v={self,false},d=0}); -- change the bearing skin
		action:Add({f=self.SguRampSetSkin,v={self,false,true},d=0}); -- change the sgu ramp skin
		action:Add({f=self.FloorChevron,v={self,false},d=0}); -- change the floor chevron skin
	    action:Add({f=self.ActivateLights,v={self,false},d=1.2}); -- lights off of chevs
		if(self.Outbound and not self.DialType.Fast or self.WireSpin)then
		    action:Add({f=self.SetSpeed,v={self,true,false},d=0}); -- Fix the StartAtStopPos
			action:Add({f=self.StopAtStartPos,v={self,true},d=1.5}); -- Stop at Started Position
 		end
		action:Add({f=self.StopWithSteam,v={self,self.DialType.Fast,self.Outbound},d=0}); -- Stop at Started Position
	end
	action:Add({f=self.DHDDisable,v={self,0,true},d=0});
	action:Add({f=self.SpinFailChecker,v={self,false},d=0});
	action:Add({f=self.SetShutdown,v={self,false},d=0});
	self:RunActions(action);
end