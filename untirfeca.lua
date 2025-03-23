local a, b, c, d = (function(a)
	local b = {
		[{}] = true
	};
	local c;
	local d = {};
	local e;
	local f = {};
	c = function(g, h)
		if not d[g] then
			d[g] = h;
		end;
	end;
	e = function(g)
		local h = f[g];
		if h then
			if h == b then
				return nil;
			end;
		else
			if not d[g] then
				if not a then
					local i = type(g) == "string" and "\"" .. g .. "\"" or tostring(g);
					error("Tried to require " .. i .. ", but no such module has been registered");
				else
					return a(g);
				end;
			end;
			f[g] = b;
			h = d[g](e, f, c, d);
			f[g] = h;
		end;
		return h;
	end;
	return e, f, c, d;
end)(require);
c("__root", function(e, f, g, h)
	local i = {};
	local j = (e("Internal"))(i);
	i.Disabled = false;
	i.Args = {};
	i.Events = {};
	function i.Init(k, l)
		local m = j._started == false;
		local n = j._shutdown == false;
		if k == nil then
			k = (game:GetService("Players")).LocalPlayer:WaitForChild("PlayerGui");
		end;
		if l == nil then
			l = (game:GetService("RunService")).Heartbeat;
		end;
		j.parentInstance = k;
		j._started = true;
		j._generateRootInstance();
		j._generateSelectionImageObject();
		for o, p in j._initFunctions do
			p();
		end;
		task.spawn(function()
			if typeof(l) == "function" then
				while j._started do
					local o = l();
					j._cycle(o);
				end;
			elseif l ~= nil and l ~= false then
				j._eventConnection = l:Connect(function(...)
					j._cycle(...);
				end);
			end;
		end);
		return i;
	end;
	function i.Shutdown()
		j._started = false;
		j._shutdown = true;
		if j._eventConnection then
			j._eventConnection:Disconnect();
		end;
		j._eventConnection = nil;
		if j._rootWidget then
			if j._rootWidget.Instance then
				j._widgets.Root.Discard(j._rootWidget);
			end;
			j._rootInstance = nil;
		end;
		if j.SelectionImageObject then
			j.SelectionImageObject:Destroy();
		end;
		for k, l in j._connections do
			l:Disconnect();
		end;
	end;
	function i.Connect(k, l)
		if j._started == false then
			warn("Iris:Connect() was called before calling Iris.Init(); always initialise Iris first.");
		end;
		local n = (#j._connectedFunctions) + 1;
		j._connectedFunctions[n] = l;
		return function()
			j._connectedFunctions[n] = nil;
		end;
	end;
	function i.Append(k)
		local l = j._GetParentWidget();
		local n;
		if j._config.Parent then
			n = j._config.Parent;
		else
			n = j._widgets[l.type].ChildAdded(l, {
				type = "userInstance"
			});
		end;
		k.Parent = n;
	end;
	function i.End()
		if j._stackIndex == 1 then
			error("Too many calls to Iris.End().", 2);
		end;
		j._IDStack[j._stackIndex] = nil;
		j._stackIndex = j._stackIndex - 1;
	end;
	function i.ForceRefresh()
		j._globalRefreshRequested = true;
	end;
	function i.UpdateGlobalConfig(k)
		for l, n in k do
			j._rootConfig[l] = n;
		end;
		i.ForceRefresh();
	end;
	function i.PushConfig(k)
		local l = i.State(-1);
		if l.value == (-1) then
			l:set(k);
		elseif j._deepCompare(l:get(), k) == false then
			j._localRefreshActive = true;
			l:set(k);
		end;
		j._config = setmetatable(k, {
			__index = j._config
		});
	end;
	function i.PopConfig()
		j._localRefreshActive = false;
		j._config = (getmetatable(j._config)).__index;
	end;
	i.TemplateConfig = e("config");
	i.UpdateGlobalConfig(i.TemplateConfig.colorDark);
	i.UpdateGlobalConfig(i.TemplateConfig.sizeDefault);
	i.UpdateGlobalConfig(i.TemplateConfig.utilityDefault);
	j._globalRefreshRequested = false;
	function i.PushId(k)
		local l = typeof(k) == "string";
		j._pushedId = tostring(k);
	end;
	function i.PopId()
		j._pushedId = nil;
	end;
	function i.SetNextWidgetID(k)
		j._nextWidgetId = k;
	end;
	function i.State(k)
		local l = j._getID(2);
		if j._states[l] then
			return j._states[l];
		end;
		j._states[l] = {
			ID = l,
			value = k,
			lastChangeTick = i.Internal._cycleTick,
			ConnectedWidgets = {},
			ConnectedFunctions = {}
		};
		setmetatable(j._states[l], j.StateClass);
		return j._states[l];
	end;
	function i.WeakState(k)
		local l = j._getID(2);
		if j._states[l] then
			if next(j._states[l].ConnectedWidgets) == nil then
				j._states[l] = nil;
			else
				return j._states[l];
			end;
		end;
		j._states[l] = {
			ID = l,
			value = k,
			lastChangeTick = i.Internal._cycleTick,
			ConnectedWidgets = {},
			ConnectedFunctions = {}
		};
		setmetatable(j._states[l], j.StateClass);
		return j._states[l];
	end;
	function i.VariableState(k, l)
		local n = j._getID(2);
		local o = j._states[n];
		if o then
			if k ~= o.value then
				o:set(k);
			end;
			return o;
		end;
		local p = {
			ID = n,
			value = k,
			lastChangeTick = i.Internal._cycleTick,
			ConnectedWidgets = {},
			ConnectedFunctions = {}
		};
		setmetatable(p, j.StateClass);
		j._states[n] = p;
		p:onChange(l);
		return p;
	end;
	function i.TableState(k, l, n)
		local o = k[l];
		local p = j._getID(2);
		local q = j._states[p];
		if q then
			if o ~= q.value then
				q:set(o);
			end;
			return q;
		end;
		local r = {
			ID = p,
			value = o,
			lastChangeTick = i.Internal._cycleTick,
			ConnectedWidgets = {},
			ConnectedFunctions = {}
		};
		setmetatable(r, j.StateClass);
		j._states[p] = r;
		r:onChange(function()
			if n ~= nil then
				if n(r.value) then
					k[l] = r.value;
				end;
			else
				k[l] = r.value;
			end;
		end);
		return r;
	end;
	function i.ComputedState(k, l)
		local n = j._getID(2);
		if j._states[n] then
			return j._states[n];
		else
			j._states[n] = {
				ID = n,
				value = l(k.value),
				lastChangeTick = i.Internal._cycleTick,
				ConnectedWidgets = {},
				ConnectedFunctions = {}
			};
			k:onChange(function(o)
				j._states[n]:set(l(o));
			end);
			setmetatable(j._states[n], j.StateClass);
			return j._states[n];
		end;
	end;
	i.ShowDemoWindow = (e("demoWindow"))(i);
	(e("widgets/init"))(j);
	(e("API"))(i);
	return i;
end);
c("API", function(e, f, g, h)
	return function(i)
		local j = function(j)
			return function(k, l)
				return i.Internal._Insert(j, k, l);
			end;
		end;
		i.Window = j("Window");
		i.SetFocusedWindow = i.Internal.SetFocusedWindow;
		i.Tooltip = j("Tooltip");
		i.MenuBar = j("MenuBar");
		i.Menu = j("Menu");
		i.MenuItem = j("MenuItem");
		i.MenuToggle = j("MenuToggle");
		i.Separator = j("Separator");
		i.Indent = j("Indent");
		i.SameLine = j("SameLine");
		i.Group = j("Group");
		i.Text = j("Text");
		i.TextWrapped = function(k)
			k[2] = true;
			return i.Internal._Insert("Text", k);
		end;
		i.TextColored = function(k)
			k[3] = k[2];
			k[2] = nil;
			return i.Internal._Insert("Text", k);
		end;
		i.SeparatorText = j("SeparatorText");
		i.InputText = j("InputText");
		i.Button = j("Button");
		i.SmallButton = j("SmallButton");
		i.Checkbox = j("Checkbox");
		i.RadioButton = j("RadioButton");
		i.Image = j("Image");
		i.ImageButton = j("ImageButton");
		i.Tree = j("Tree");
		i.CollapsingHeader = j("CollapsingHeader");
		i.TabBar = j("TabBar");
		i.Tab = j("Tab");
		i.InputNum = j("InputNum");
		i.InputVector2 = j("InputVector2");
		i.InputVector3 = j("InputVector3");
		i.InputUDim = j("InputUDim");
		i.InputUDim2 = j("InputUDim2");
		i.InputRect = j("InputRect");
		i.DragNum = j("DragNum");
		i.DragVector2 = j("DragVector2");
		i.DragVector3 = j("DragVector3");
		i.DragUDim = j("DragUDim");
		i.DragUDim2 = j("DragUDim2");
		i.DragRect = j("DragRect");
		i.InputColor3 = j("InputColor3");
		i.InputColor4 = j("InputColor4");
		i.SliderNum = j("SliderNum");
		i.SliderVector2 = j("SliderVector2");
		i.SliderVector3 = j("SliderVector3");
		i.SliderUDim = j("SliderUDim");
		i.SliderUDim2 = j("SliderUDim2");
		i.SliderRect = j("SliderRect");
		i.Selectable = j("Selectable");
		i.Combo = j("Combo");
		i.ComboArray = function(k, l, n)
			local o;
			if l == nil then
				o = i.State(n[1]);
			else
				o = l;
			end;
			local p = i.Internal._Insert("Combo", k, o);
			local q = p.state.index;
			for r, s in n do
				i.Internal._Insert("Selectable", {
					s,
					s
				}, {
					index = q
				});
			end;
			i.End();
			return p;
		end;
		i.ComboEnum = function(k, l, n)
			local o;
			if l == nil then
				o = i.State((n:GetEnumItems())[1]);
			else
				o = l;
			end;
			local p = i.Internal._Insert("Combo", k, o);
			local q = p.state.index;
			for r, s in n:GetEnumItems() do
				i.Internal._Insert("Selectable", {
					s.Name,
					s
				}, {
					index = q
				});
			end;
			i.End();
			return p;
		end;
		i.InputEnum = i.ComboEnum;
		i.ProgressBar = j("ProgressBar");
		i.PlotLines = j("PlotLines");
		i.PlotHistogram = j("PlotHistogram");
		i.Table = j("Table");
		i.NextColumn = function()
			local k = i.Internal._GetParentWidget();
			local l = k.type == "Table";
			k.RowColumnIndex = k.RowColumnIndex + 1;
		end;
		i.SetColumnIndex = function(k)
			local l = i.Internal._GetParentWidget();
			local n = l.type == "Table";
			local o = k >= l.InitialNumColumns;
			l.RowColumnIndex = math.floor(l.RowColumnIndex / l.InitialNumColumns) + (k - 1);
		end;
		i.NextRow = function()
			local k = i.Internal._GetParentWidget();
			local l = k.type == "Table";
			local o = k.InitialNumColumns;
			local p = math.floor((k.RowColumnIndex + 1) / o) * o;
			k.RowColumnIndex = p;
		end;
	end;
end);
c("widgets/init", function(e, f, g, h)
	local i = {};
	return function(j)
		i.GuiService = game:GetService("GuiService");
		i.RunService = game:GetService("RunService");
		i.UserInputService = game:GetService("UserInputService");
		i.ContextActionService = game:GetService("ContextActionService");
		i.TextService = game:GetService("TextService");
		i.ICONS = {
			RIGHT_POINTING_TRIANGLE = "rbxasset://textures/DeveloperFramework/button_arrow_right.png",
			DOWN_POINTING_TRIANGLE = "rbxasset://textures/DeveloperFramework/button_arrow_down.png",
			MULTIPLICATION_SIGN = "rbxasset://textures/AnimationEditor/icon_close.png",
			BOTTOM_RIGHT_CORNER = "rbxasset://textures/ui/InspectMenu/gr-item-selector-triangle.png",
			CHECK_MARK = "rbxasset://textures/AnimationEditor/icon_checkmark.png",
			BORDER = "rbxasset://textures/ui/InspectMenu/gr-item-selector.png",
			ALPHA_BACKGROUND_TEXTURE = "rbxasset://textures/meshPartFallback.png",
			UNKNOWN_TEXTURE = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		};
		i.IS_STUDIO = i.RunService:IsStudio();
		function i.getTime()
			if i.IS_STUDIO then
				return os.clock();
			else
				return time();
			end;
		end;
		i.GuiOffset = (j._config.IgnoreGuiInset and {
			(-i.GuiService:GetGuiInset())
		} or {
			Vector2.zero
		})[1];
		i.MouseOffset = (j._config.IgnoreGuiInset and {
			Vector2.zero
		} or {
			i.GuiService:GetGuiInset()
		})[1];
		local k;
		k = (i.GuiService:GetPropertyChangedSignal("TopbarInset")):Once(function()
			i.MouseOffset = (j._config.IgnoreGuiInset and {
				Vector2.zero
			} or {
				i.GuiService:GetGuiInset()
			})[1];
			i.GuiOffset = (j._config.IgnoreGuiInset and {
				(-i.GuiService:GetGuiInset())
			} or {
				Vector2.zero
			})[1];
			k:Disconnect();
		end);
		task.delay(5, function()
			k:Disconnect();
		end);
		function i.getMouseLocation()
			return i.UserInputService:GetMouseLocation() - i.MouseOffset;
		end;
		function i.isPosInsideRect(l, o, p)
			return l.X >= o.X and l.X <= p.X and l.Y >= o.Y and l.Y <= p.Y;
		end;
		function i.findBestWindowPosForPopup(l, o, p, q)
			local r = 20;
			if l.X + o.X + r > q.X then
				if l.Y + o.Y + r > q.Y then
					l = l + Vector2.new(0, (-(r + o.Y)));
				else
					l = l + Vector2.new(0, r);
				end;
			else
				l = l + Vector2.new(r);
			end;
			local s = Vector2.new(math.max(math.min(l.X + o.X, q.X) - o.X, p.X), math.max(math.min(l.Y + o.Y, q.Y) - o.Y, p.Y));
			return s;
		end;
		function i.getScreenSizeForWindow(l)
			if l.Instance:IsA("GuiBase2d") then
				return l.Instance.AbsoluteSize;
			else
				local o = l.Instance.Parent;
				if o:IsA("GuiBase2d") then
					return o.AbsoluteSize;
				elseif o.Parent:IsA("GuiBase2d") then
					return o.AbsoluteSize;
				else
					return workspace.CurrentCamera.ViewportSize;
				end;
			end;
		end;
		function i.extend(l, o)
			local p = table.clone(l);
			for q, r in o do
				p[q] = r;
			end;
			return p;
		end;
		function i.UIPadding(l, o)
			local p = Instance.new("UIPadding");
			p.PaddingLeft = UDim.new(0, o.X);
			p.PaddingRight = UDim.new(0, o.X);
			p.PaddingTop = UDim.new(0, o.Y);
			p.PaddingBottom = UDim.new(0, o.Y);
			p.Parent = l;
			return p;
		end;
		function i.UIListLayout(l, o, p)
			local q = Instance.new("UIListLayout");
			q.SortOrder = Enum.SortOrder.LayoutOrder;
			q.Padding = p;
			q.FillDirection = o;
			q.Parent = l;
			return q;
		end;
		function i.UIStroke(l, o, p, q)
			local r = Instance.new("UIStroke");
			r.Thickness = o;
			r.Color = p;
			r.Transparency = q;
			r.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			r.LineJoinMode = Enum.LineJoinMode.Round;
			r.Parent = l;
			return r;
		end;
		function i.UICorner(l, o)
			local p = Instance.new("UICorner");
			p.CornerRadius = UDim.new(o and 0 or 1, o or 0);
			p.Parent = l;
			return p;
		end;
		function i.UISizeConstraint(l, o, p)
			local q = Instance.new("UISizeConstraint");
			q.MinSize = o or q.MinSize;
			q.MaxSize = p or q.MaxSize;
			q.Parent = l;
			return q;
		end;
		function i.applyTextStyle(l)
			l.FontFace = j._config.TextFont;
			l.TextSize = j._config.TextSize;
			l.TextColor3 = j._config.TextColor;
			l.TextTransparency = j._config.TextTransparency;
			l.TextXAlignment = Enum.TextXAlignment.Left;
			l.TextYAlignment = Enum.TextYAlignment.Center;
			l.RichText = j._config.RichText;
			l.TextWrapped = j._config.TextWrapped;
			l.AutoLocalize = false;
		end;
		function i.applyInteractionHighlights(l, o, p, q)
			local r = false;
			i.applyMouseEnter(o, function()
				p[l .. "Color3"] = q.HoveredColor;
				p[l .. "Transparency"] = q.HoveredTransparency;
				r = false;
			end);
			i.applyMouseLeave(o, function()
				p[l .. "Color3"] = q.Color;
				p[l .. "Transparency"] = q.Transparency;
				r = true;
			end);
			i.applyInputBegan(o, function(s)
				if not (s.UserInputType == Enum.UserInputType.MouseButton1 or s.UserInputType == Enum.UserInputType.Gamepad1) then
					return;
				end;
				p[l .. "Color3"] = q.ActiveColor;
				p[l .. "Transparency"] = q.ActiveTransparency;
			end);
			i.applyInputEnded(o, function(s)
				if not (s.UserInputType == Enum.UserInputType.MouseButton1 or s.UserInputType == Enum.UserInputType.Gamepad1) or r then
					return;
				end;
				if s.UserInputType == Enum.UserInputType.MouseButton1 then
					p[l .. "Color3"] = q.HoveredColor;
					p[l .. "Transparency"] = q.HoveredTransparency;
				end;
				if s.UserInputType == Enum.UserInputType.Gamepad1 then
					p[l .. "Color3"] = q.Color;
					p[l .. "Transparency"] = q.Transparency;
				end;
			end);
			o.SelectionImageObject = j.SelectionImageObject;
		end;
		function i.applyInteractionHighlightsWithMultiHighlightee(l, o, p)
			local q = false;
			i.applyMouseEnter(o, function()
				for r, s in p do
					s[1][l .. "Color3"] = s[2].HoveredColor;
					s[1][l .. "Transparency"] = s[2].HoveredTransparency;
					q = false;
				end;
			end);
			i.applyMouseLeave(o, function()
				for r, s in p do
					s[1][l .. "Color3"] = s[2].Color;
					s[1][l .. "Transparency"] = s[2].Transparency;
					q = true;
				end;
			end);
			i.applyInputBegan(o, function(r)
				if not (r.UserInputType == Enum.UserInputType.MouseButton1 or r.UserInputType == Enum.UserInputType.Gamepad1) then
					return;
				end;
				for s, t in p do
					t[1][l .. "Color3"] = t[2].ActiveColor;
					t[1][l .. "Transparency"] = t[2].ActiveTransparency;
				end;
			end);
			i.applyInputEnded(o, function(r)
				if not (r.UserInputType == Enum.UserInputType.MouseButton1 or r.UserInputType == Enum.UserInputType.Gamepad1) or q then
					return;
				end;
				for s, t in p do
					if r.UserInputType == Enum.UserInputType.MouseButton1 then
						t[1][l .. "Color3"] = t[2].HoveredColor;
						t[1][l .. "Transparency"] = t[2].HoveredTransparency;
					end;
					if r.UserInputType == Enum.UserInputType.Gamepad1 then
						t[1][l .. "Color3"] = t[2].Color;
						t[1][l .. "Transparency"] = t[2].Transparency;
					end;
				end;
			end);
			o.SelectionImageObject = j.SelectionImageObject;
		end;
		function i.applyFrameStyle(l, o, p)
			local q = j._config.FrameBorderSize;
			local r = j._config.FrameRounding;
			l.BorderSizePixel = 0;
			if q > 0 then
				i.UIStroke(l, q, j._config.BorderColor, j._config.BorderTransparency);
			end;
			if r > 0 and (not p) then
				i.UICorner(l, r);
			end;
			if not o then
				i.UIPadding(l, j._config.FramePadding);
			end;
		end;
		function i.applyButtonClick(l, o)
			l.MouseButton1Click:Connect(function()
				o();
			end);
		end;
		function i.applyButtonDown(l, o)
			l.MouseButton1Down:Connect(function(p, q)
				local r = Vector2.new(p, q) - i.MouseOffset;
				o(r.X, r.Y);
			end);
		end;
		function i.applyMouseEnter(l, o)
			l.MouseEnter:Connect(function(p, q)
				local r = Vector2.new(p, q) - i.MouseOffset;
				o(r.X, r.Y);
			end);
		end;
		function i.applyMouseMoved(l, o)
			l.MouseMoved:Connect(function(p, q)
				local r = Vector2.new(p, q) - i.MouseOffset;
				o(r.X, r.Y);
			end);
		end;
		function i.applyMouseLeave(l, o)
			l.MouseLeave:Connect(function(p, q)
				local r = Vector2.new(p, q) - i.MouseOffset;
				o(r.X, r.Y);
			end);
		end;
		function i.applyInputBegan(l, o)
			l.InputBegan:Connect(function(...)
				o(...);
			end);
		end;
		function i.applyInputEnded(l, o)
			l.InputEnded:Connect(function(...)
				o(...);
			end);
		end;
		function i.discardState(l)
			for o, p in l.state do
				p.ConnectedWidgets[l.ID] = nil;
			end;
		end;
		function i.registerEvent(l, o)
			table.insert(j._initFunctions, function()
				table.insert(j._connections, i.UserInputService[l]:Connect(o));
			end);
		end;
		i.EVENTS = {
			hover = function(l)
				return {
					Init = function(o)
						local p = l(o);
						i.applyMouseEnter(p, function()
							o.isHoveredEvent = true;
						end);
						i.applyMouseLeave(p, function()
							o.isHoveredEvent = false;
						end);
						o.isHoveredEvent = false;
					end,
					Get = function(o)
						return o.isHoveredEvent;
					end
				};
			end,
			click = function(l)
				return {
					Init = function(o)
						local p = l(o);
						o.lastClickedTick = -1;
						i.applyButtonClick(p, function()
							o.lastClickedTick = j._cycleTick + 1;
						end);
					end,
					Get = function(o)
						return o.lastClickedTick == j._cycleTick;
					end
				};
			end,
			rightClick = function(l)
				return {
					Init = function(o)
						local p = l(o);
						o.lastRightClickedTick = -1;
						p.MouseButton2Click:Connect(function()
							o.lastRightClickedTick = j._cycleTick + 1;
						end);
					end,
					Get = function(o)
						return o.lastRightClickedTick == j._cycleTick;
					end
				};
			end,
			doubleClick = function(l)
				return {
					Init = function(o)
						local p = l(o);
						o.lastClickedTime = -1;
						o.lastClickedPosition = Vector2.zero;
						o.lastDoubleClickedTick = -1;
						i.applyButtonDown(p, function(q, r)
							local s = i.getTime();
							local t = s - o.lastClickedTime < j._config.MouseDoubleClickTime;
							if t and (Vector2.new(q, r) - o.lastClickedPosition).Magnitude < j._config.MouseDoubleClickMaxDist then
								o.lastDoubleClickedTick = j._cycleTick + 1;
							else
								o.lastClickedTime = s;
								o.lastClickedPosition = Vector2.new(q, r);
							end;
						end);
					end,
					Get = function(o)
						return o.lastDoubleClickedTick == j._cycleTick;
					end
				};
			end,
			ctrlClick = function(l)
				return {
					Init = function(o)
						local p = l(o);
						o.lastCtrlClickedTick = -1;
						i.applyButtonClick(p, function()
							if i.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or i.UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
								o.lastCtrlClickedTick = j._cycleTick + 1;
							end;
						end);
					end,
					Get = function(o)
						return o.lastCtrlClickedTick == j._cycleTick;
					end
				};
			end
		};
		j._utility = i;
		(e("widgets/Root"))(j, i);
		(e("widgets/Window"))(j, i);
		(e("widgets/Menu"))(j, i);
		(e("widgets/Format"))(j, i);
		(e("widgets/Text"))(j, i);
		(e("widgets/Button"))(j, i);
		(e("widgets/Checkbox"))(j, i);
		(e("widgets/RadioButton"))(j, i);
		(e("widgets/Image"))(j, i);
		(e("widgets/Tree"))(j, i);
		(e("widgets/Tab"))(j, i);
		(e("widgets/Input"))(j, i);
		(e("widgets/Combo"))(j, i);
		(e("widgets/Plot"))(j, i);
		(e("widgets/Table"))(j, i);
	end;
end);
c("widgets/Table", function(e, f, g, h)
	return function(i, j)
		local k = {};
		table.insert(i._postCycleCallbacks, function()
			for l, o in k do
				o.RowColumnIndex = 0;
			end;
		end);
		i.WidgetConstructor("Table", {
			hasState = false,
			hasChildren = true,
			Args = {
				NumColumns = 1,
				RowBg = 2,
				BordersOuter = 3,
				BordersInner = 4
			},
			Events = {
				hovered = j.EVENTS.hover(function(l)
					return l.Instance;
				end)
			},
			Generate = function(l)
				k[l.ID] = l;
				l.InitialNumColumns = -1;
				l.RowColumnIndex = 0;
				l.ColumnInstances = {};
				l.CellInstances = {};
				local o = Instance.new("Frame");
				o.Name = "Iris_Table";
				o.Size = UDim2.new(i._config.ItemWidth, UDim.new(0, 0));
				o.AutomaticSize = Enum.AutomaticSize.Y;
				o.BackgroundTransparency = 1;
				o.BorderSizePixel = 0;
				o.ZIndex = l.ZIndex + 1024;
				o.LayoutOrder = l.ZIndex;
				o.ClipsDescendants = true;
				j.UIListLayout(o, Enum.FillDirection.Horizontal, UDim.new(0, 0));
				j.UIStroke(o, 1, i._config.TableBorderStrongColor, i._config.TableBorderStrongTransparency);
				return o;
			end,
			Update = function(l)
				local o = l.Instance;
				if l.arguments.BordersOuter == false then
					o.UIStroke.Thickness = 0;
				else
					o.UIStroke.Thickness = 1;
				end;
				if l.InitialNumColumns == (-1) then
					if l.arguments.NumColumns == nil then
						error("NumColumns argument is required for Iris.Table().", 5);
					end;
					l.InitialNumColumns = l.arguments.NumColumns;
					for p = 1, l.InitialNumColumns do
						local q = l.ZIndex + 1 + p;
						local r = Instance.new("Frame");
						r.Name = string.format("Column_%s", tostring(p));
						r.Size = UDim2.new(1 / l.InitialNumColumns, 0, 0, 0);
						r.AutomaticSize = Enum.AutomaticSize.Y;
						r.BackgroundTransparency = 1;
						r.BorderSizePixel = 0;
						r.ZIndex = q;
						r.LayoutOrder = q;
						r.ClipsDescendants = true;
						j.UIListLayout(r, Enum.FillDirection.Vertical, UDim.new(0, 0));
						l.ColumnInstances[p] = r;
						r.Parent = o;
					end;
				elseif l.arguments.NumColumns ~= l.InitialNumColumns then
					error("NumColumns Argument must be static for Iris.Table().");
				end;
				if l.arguments.RowBg == false then
					for p, q in l.CellInstances do
						q.BackgroundTransparency = 1;
					end;
				else
					for p, q in l.CellInstances do
						local r = math.ceil(p / l.InitialNumColumns);
						q.BackgroundTransparency = (r % 2 == 0 and {
							i._config.TableRowBgAltTransparency
						} or {
							i._config.TableRowBgTransparency
						})[1];
					end;
				end;
				if l.arguments.BordersInner == false then
					for p, q in l.CellInstances do
						q.UIStroke.Thickness = 0;
					end;
				else
					for p, q in l.CellInstances do
						q.UIStroke.Thickness = 0.5;
					end;
				end;
			end,
			Discard = function(l)
				k[l.ID] = nil;
				l.Instance:Destroy();
			end,
			ChildAdded = function(l, o)
				if l.RowColumnIndex == 0 then
					l.RowColumnIndex = 1;
				end;
				local p = l.CellInstances[l.RowColumnIndex];
				if p then
					return p;
				end;
				local q = l.ColumnInstances[(l.RowColumnIndex - 1) % l.InitialNumColumns + 1];
				local r = q.ZIndex + l.RowColumnIndex;
				local s = Instance.new("Frame");
				s.Name = string.format("Cell_%s", tostring(l.RowColumnIndex));
				s.Size = UDim2.new(1, 0, 0, 0);
				s.AutomaticSize = Enum.AutomaticSize.Y;
				s.BackgroundTransparency = 1;
				s.BorderSizePixel = 0;
				s.ZIndex = r;
				s.LayoutOrder = r;
				s.ClipsDescendants = true;
				j.UIPadding(s, i._config.CellPadding);
				j.UIListLayout(s, Enum.FillDirection.Vertical, UDim.new(0, i._config.ItemSpacing.Y));
				if l.arguments.BordersInner == false then
					j.UIStroke(s, 0, i._config.TableBorderLightColor, i._config.TableBorderLightTransparency);
				else
					j.UIStroke(s, 0.5, i._config.TableBorderLightColor, i._config.TableBorderLightTransparency);
				end;
				if l.arguments.RowBg ~= false then
					local t = math.ceil(l.RowColumnIndex / l.InitialNumColumns);
					local u = (t % 2 == 0 and {
						i._config.TableRowBgAltColor
					} or {
						i._config.TableRowBgColor
					})[1];
					local v = (t % 2 == 0 and {
						i._config.TableRowBgAltTransparency
					} or {
						i._config.TableRowBgTransparency
					})[1];
					s.BackgroundColor3 = u;
					s.BackgroundTransparency = v;
				end;
				l.CellInstances[l.RowColumnIndex] = s;
				s.Parent = q;
				return s;
			end
		});
	end;
end);
c("widgets/Plot", function(e, f, g, h)
	return function(i, j)
		i.WidgetConstructor("ProgressBar", {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				Format = 2
			},
			Events = {
				hovered = j.EVENTS.hover(function(k)
					return k.Instance;
				end),
				changed = {
					Init = function(k)
					end,
					Get = function(k)
						return k.lastChangedTick == i._cycleTick;
					end
				}
			},
			Generate = function(k)
				local l = Instance.new("Frame");
				l.Name = "Iris_ProgressBar";
				l.Size = UDim2.new(i._config.ItemWidth, UDim.new());
				l.BackgroundTransparency = 1;
				l.AutomaticSize = Enum.AutomaticSize.Y;
				l.LayoutOrder = k.ZIndex;
				local o = j.UIListLayout(l, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X));
				o.VerticalAlignment = Enum.VerticalAlignment.Center;
				local p = Instance.new("Frame");
				p.Name = "Bar";
				p.Size = UDim2.new(i._config.ContentWidth, i._config.ContentHeight);
				p.BackgroundColor3 = i._config.FrameBgColor;
				p.BackgroundTransparency = i._config.FrameBgTransparency;
				p.BorderSizePixel = 0;
				p.AutomaticSize = Enum.AutomaticSize.Y;
				p.ClipsDescendants = true;
				j.applyFrameStyle(p, true);
				p.Parent = l;
				local q = Instance.new("TextLabel");
				q.Name = "Progress";
				q.AutomaticSize = Enum.AutomaticSize.Y;
				q.Size = UDim2.new(UDim.new(0, 0), i._config.ContentHeight);
				q.BackgroundColor3 = i._config.PlotHistogramColor;
				q.BackgroundTransparency = i._config.PlotHistogramTransparency;
				q.BorderSizePixel = 0;
				j.applyTextStyle(q);
				j.UIPadding(q, i._config.FramePadding);
				j.UICorner(q, i._config.FrameRounding);
				q.Text = "";
				q.Parent = p;
				local r = Instance.new("TextLabel");
				r.Name = "Value";
				r.AutomaticSize = Enum.AutomaticSize.XY;
				r.Size = UDim2.new(UDim.new(0, 0), i._config.ContentHeight);
				r.BackgroundTransparency = 1;
				r.BorderSizePixel = 0;
				r.ZIndex = 1;
				j.applyTextStyle(r);
				j.UIPadding(r, i._config.FramePadding);
				r.Parent = p;
				local s = Instance.new("TextLabel");
				s.Name = "TextLabel";
				s.AutomaticSize = Enum.AutomaticSize.XY;
				s.AnchorPoint = Vector2.new(0, 0.5);
				s.BackgroundTransparency = 1;
				s.BorderSizePixel = 0;
				s.LayoutOrder = 1;
				j.applyTextStyle(s);
				j.UIPadding(r, i._config.FramePadding);
				s.Parent = l;
				return l;
			end,
			GenerateState = function(k)
				if k.state.progress == nil then
					k.state.progress = i._widgetState(k, "Progress", 0);
				end;
			end,
			Update = function(k)
				local l = k.Instance;
				local o = l.TextLabel;
				local p = l.Bar;
				local q = p.Value;
				if k.arguments.Format ~= nil and typeof(k.arguments.Format) == "string" then
					q.Text = k.arguments.Format;
				end;
				o.Text = k.arguments.Text or "Progress Bar";
			end,
			UpdateState = function(k)
				local l = k.Instance;
				local o = l.Bar;
				local p = o.Progress;
				local q = o.Value;
				local r = k.state.progress.value;
				r = math.clamp(r, 0, 1);
				local s = o.AbsoluteSize.X;
				local t = q.AbsoluteSize.X;
				if s * (1 - r) < t then
					q.AnchorPoint = Vector2.xAxis;
					q.Position = UDim2.fromScale(1, 0);
				else
					q.AnchorPoint = Vector2.zero;
					q.Position = UDim2.new(r, 0, 0, 0);
				end;
				p.Size = UDim2.new(UDim.new(r, 0), p.Size.Height);
				if k.arguments.Format ~= nil and typeof(k.arguments.Format) == "string" then
					q.Text = k.arguments.Format;
				else
					q.Text = string.format("%d%%", r * 100);
				end;
				k.lastChangedTick = i._cycleTick + 1;
			end,
			Discard = function(k)
				k.Instance:Destroy();
				j.discardState(k);
			end
		});
		local k = function(k, l)
			local o = Instance.new("Frame");
			o.Name = tostring(l);
			o.AnchorPoint = Vector2.new(0.5, 0.5);
			o.BackgroundColor3 = i._config.PlotLinesColor;
			o.BackgroundTransparency = i._config.PlotLinesTransparency;
			o.BorderSizePixel = 0;
			o.Parent = k;
			return o;
		end;
		local l = function(l)
			if l.HoveredLine then
				l.HoveredLine.BackgroundColor3 = i._config.PlotLinesColor;
				l.HoveredLine.BackgroundTransparency = i._config.PlotLinesTransparency;
				l.HoveredLine = false;
				l.state.hovered:set(nil);
			end;
		end;
		local o = function(o)
			local p = o.Instance;
			local q = p.Background;
			local r = q.Plot;
			local s = j.getMouseLocation();
			local t = r.AbsolutePosition - j.GuiOffset;
			local u = (s.X - t.X) / r.AbsoluteSize.X;
			local v = math.ceil(u * (#o.Lines));
			local w = o.Lines[v];
			if w then
				if w ~= o.HoveredLine then
					l(o);
				end;
				local x = o.state.values.value[v];
				local y = o.state.values.value[v + 1];
				if x and y then
					if math.floor(x) == x and math.floor(y) == y then
						o.Tooltip.Text = ("%d: %d\n%d: %d"):format(v, x, v + 1, y);
					else
						o.Tooltip.Text = ("%d: %.3f\n%d: %.3f"):format(v, x, v + 1, y);
					end;
				end;
				o.HoveredLine = w;
				w.BackgroundColor3 = i._config.PlotLinesHoveredColor;
				w.BackgroundTransparency = i._config.PlotLinesHoveredTransparency;
				o.state.hovered:set({
					x,
					y
				});
			end;
		end;
		i.WidgetConstructor("PlotLines", {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				Height = 2,
				Min = 3,
				Max = 4,
				TextOverlay = 5
			},
			Events = {
				hovered = j.EVENTS.hover(function(p)
					return p.Instance;
				end)
			},
			Generate = function(p)
				local q = Instance.new("Frame");
				q.Name = "Iris_PlotLines";
				q.Size = UDim2.fromScale(1, 0);
				q.BackgroundTransparency = 1;
				q.BorderSizePixel = 0;
				q.ZIndex = p.ZIndex;
				q.LayoutOrder = p.ZIndex;
				local r = j.UIListLayout(q, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X));
				r.VerticalAlignment = Enum.VerticalAlignment.Center;
				local s = Instance.new("Frame");
				s.Name = "Background";
				s.Size = UDim2.new(i._config.ContentWidth, UDim.new(1, 0));
				s.BackgroundColor3 = i._config.FrameBgColor;
				s.BackgroundTransparency = i._config.FrameBgTransparency;
				j.applyFrameStyle(s);
				s.Parent = q;
				local t = Instance.new("Frame");
				t.Name = "Plot";
				t.Size = UDim2.fromScale(1, 1);
				t.BackgroundTransparency = 1;
				t.BorderSizePixel = 0;
				t.ClipsDescendants = true;
				(t:GetPropertyChangedSignal("AbsoluteSize")):Connect(function()
					p.state.values.lastChangeTick = i._cycleTick;
					i._widgets.PlotLines.UpdateState(p);
				end);
				local u = Instance.new("TextLabel");
				u.Name = "OverlayText";
				u.AutomaticSize = Enum.AutomaticSize.XY;
				u.AnchorPoint = Vector2.new(0.5, 0);
				u.Size = UDim2.fromOffset(0, 0);
				u.Position = UDim2.fromScale(0.5, 0);
				u.BackgroundTransparency = 1;
				u.BorderSizePixel = 0;
				u.ZIndex = 2;
				j.applyTextStyle(u);
				u.Parent = t;
				local v = Instance.new("TextLabel");
				v.Name = "Iris_Tooltip";
				v.AutomaticSize = Enum.AutomaticSize.XY;
				v.Size = UDim2.fromOffset(0, 0);
				v.BackgroundColor3 = i._config.PopupBgColor;
				v.BackgroundTransparency = i._config.PopupBgTransparency;
				v.BorderSizePixel = 0;
				v.Visible = false;
				j.applyTextStyle(v);
				j.UIStroke(v, i._config.PopupBorderSize, i._config.BorderActiveColor, i._config.BorderActiveTransparency);
				j.UIPadding(v, i._config.WindowPadding);
				if i._config.PopupRounding > 0 then
					j.UICorner(v, i._config.PopupRounding);
				end;
				local w = i._rootInstance and i._rootInstance:FindFirstChild("PopupScreenGui");
				v.Parent = w and w:FindFirstChild("TooltipContainer");
				p.Tooltip = v;
				j.applyMouseMoved(t, function()
					o(p);
				end);
				j.applyMouseLeave(t, function()
					l(p);
				end);
				t.Parent = s;
				p.Lines = {};
				p.HoveredLine = false;
				local x = Instance.new("TextLabel");
				x.Name = "TextLabel";
				x.AutomaticSize = Enum.AutomaticSize.XY;
				x.Size = UDim2.fromOffset(0, 0);
				x.BackgroundTransparency = 1;
				x.BorderSizePixel = 0;
				x.ZIndex = p.ZIndex + 3;
				x.LayoutOrder = p.ZIndex + 3;
				j.applyTextStyle(x);
				x.Parent = q;
				return q;
			end,
			GenerateState = function(p)
				if p.state.values == nil then
					p.state.values = i._widgetState(p, "values", {
						0,
						1
					});
				end;
				if p.state.hovered == nil then
					p.state.hovered = i._widgetState(p, "hovered", nil);
				end;
			end,
			Update = function(p)
				local q = p.Instance;
				local r = q.TextLabel;
				local s = q.Background;
				local t = s.Plot;
				local u = t.OverlayText;
				r.Text = p.arguments.Text or "Plot Lines";
				u.Text = p.arguments.TextOverlay or "";
				q.Size = UDim2.new(1, 0, 0, p.arguments.Height or 0);
			end,
			UpdateState = function(p)
				if p.state.hovered.lastChangeTick == i._cycleTick then
					if p.state.hovered.value then
						p.Tooltip.Visible = true;
					else
						p.Tooltip.Visible = false;
					end;
				end;
				if p.state.values.lastChangeTick == i._cycleTick then
					local q = p.Instance;
					local r = q.Background;
					local s = r.Plot;
					local t = p.state.values.value;
					local u = (#t) - 1;
					local v = #p.Lines;
					local w = p.arguments.Min;
					local x = p.arguments.Max;
					if w == nil or x == nil then
						for y, z in t do
							w = math.min(w or z, z);
							x = math.max(x or z, z);
						end;
					end;
					if v < u then
						for y = v + 1, u do
							table.insert(p.Lines, k(s, y));
						end;
					elseif v > u then
						for y = u + 1, v do
							local z = table.remove(p.Lines);
							if z then
								z:Destroy();
							end;
						end;
					end;
					local y = x - w;
					local z = s.AbsoluteSize;
					for A = 1, u do
						local B = t[A];
						local C = t[A + 1];
						local D = z * Vector2.new(((A - 1) / u), ((x - B) / y));
						local E = z * Vector2.new((A / u), ((x - C) / y));
						local F = (D + E) / 2;
						p.Lines[A].Size = UDim2.fromOffset((E - D).Magnitude + 1, 1);
						p.Lines[A].Position = UDim2.fromOffset(F.X, F.Y);
						p.Lines[A].Rotation = math.atan2((E.Y - D.Y), (E.X - D.X)) * (180 / math.pi);
					end;
				end;
			end,
			Discard = function(p)
				p.Instance:Destroy();
				j.discardState(p);
			end
		});
		local p = function(p, q)
			local r = Instance.new("Frame");
			r.Name = tostring(q);
			r.BackgroundColor3 = i._config.PlotHistogramColor;
			r.BackgroundTransparency = i._config.PlotHistogramTransparency;
			r.BorderSizePixel = 0;
			r.Parent = p;
			return r;
		end;
		local q = function(q)
			if q.HoveredBlock then
				q.HoveredBlock.BackgroundColor3 = i._config.PlotHistogramColor;
				q.HoveredBlock.BackgroundTransparency = i._config.PlotHistogramTransparency;
				q.HoveredBlock = false;
				q.state.hovered:set(nil);
			end;
		end;
		local r = function(r)
			local s = r.Instance;
			local t = s.Background;
			local u = t.Plot;
			local v = j.getMouseLocation();
			local w = u.AbsolutePosition - j.GuiOffset;
			local x = (v.X - w.X) / u.AbsoluteSize.X;
			local y = math.ceil(x * (#r.Blocks));
			local z = r.Blocks[y];
			if z then
				if z ~= r.HoveredBlock then
					q(r);
				end;
				local A = r.state.values.value[y];
				if A then
					r.Tooltip.Text = (math.floor(A) == A and {
						("%d: %d"):format(y, A)
					} or {
						("%d: %.3f"):format(y, A)
					})[1];
				end;
				r.HoveredBlock = z;
				z.BackgroundColor3 = i._config.PlotHistogramHoveredColor;
				z.BackgroundTransparency = i._config.PlotHistogramHoveredTransparency;
				r.state.hovered:set(A);
			end;
		end;
		i.WidgetConstructor("PlotHistogram", {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				Height = 2,
				Min = 3,
				Max = 4,
				TextOverlay = 5,
				BaseLine = 6
			},
			Events = {
				hovered = j.EVENTS.hover(function(s)
					return s.Instance;
				end)
			},
			Generate = function(s)
				local t = Instance.new("Frame");
				t.Name = "Iris_PlotHistogram";
				t.Size = UDim2.fromScale(1, 0);
				t.BackgroundTransparency = 1;
				t.BorderSizePixel = 0;
				t.ZIndex = s.ZIndex;
				t.LayoutOrder = s.ZIndex;
				local u = j.UIListLayout(t, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X));
				u.VerticalAlignment = Enum.VerticalAlignment.Center;
				local v = Instance.new("Frame");
				v.Name = "Background";
				v.Size = UDim2.new(i._config.ContentWidth, UDim.new(1, 0));
				v.BackgroundColor3 = i._config.FrameBgColor;
				v.BackgroundTransparency = i._config.FrameBgTransparency;
				j.applyFrameStyle(v);
				local w = v.UIPadding;
				w.PaddingRight = UDim.new(0, i._config.FramePadding.X - 1);
				v.Parent = t;
				local x = Instance.new("Frame");
				x.Name = "Plot";
				x.Size = UDim2.fromScale(1, 1);
				x.BackgroundTransparency = 1;
				x.BorderSizePixel = 0;
				x.ClipsDescendants = true;
				local y = Instance.new("TextLabel");
				y.Name = "OverlayText";
				y.AutomaticSize = Enum.AutomaticSize.XY;
				y.AnchorPoint = Vector2.new(0.5, 0);
				y.Size = UDim2.fromOffset(0, 0);
				y.Position = UDim2.fromScale(0.5, 0);
				y.BackgroundTransparency = 1;
				y.BorderSizePixel = 0;
				y.ZIndex = 2;
				j.applyTextStyle(y);
				y.Parent = x;
				local z = Instance.new("TextLabel");
				z.Name = "Iris_Tooltip";
				z.AutomaticSize = Enum.AutomaticSize.XY;
				z.Size = UDim2.fromOffset(0, 0);
				z.BackgroundColor3 = i._config.PopupBgColor;
				z.BackgroundTransparency = i._config.PopupBgTransparency;
				z.BorderSizePixel = 0;
				z.Visible = false;
				j.applyTextStyle(z);
				j.UIStroke(z, i._config.PopupBorderSize, i._config.BorderActiveColor, i._config.BorderActiveTransparency);
				j.UIPadding(z, i._config.WindowPadding);
				if i._config.PopupRounding > 0 then
					j.UICorner(z, i._config.PopupRounding);
				end;
				local A = i._rootInstance and i._rootInstance:FindFirstChild("PopupScreenGui");
				z.Parent = A and A:FindFirstChild("TooltipContainer");
				s.Tooltip = z;
				j.applyMouseMoved(x, function()
					r(s);
				end);
				j.applyMouseLeave(x, function()
					q(s);
				end);
				x.Parent = v;
				s.Blocks = {};
				s.HoveredBlock = false;
				local B = Instance.new("TextLabel");
				B.Name = "TextLabel";
				B.AutomaticSize = Enum.AutomaticSize.XY;
				B.Size = UDim2.fromOffset(0, 0);
				B.BackgroundTransparency = 1;
				B.BorderSizePixel = 0;
				B.ZIndex = s.ZIndex + 3;
				B.LayoutOrder = s.ZIndex + 3;
				j.applyTextStyle(B);
				B.Parent = t;
				return t;
			end,
			GenerateState = function(s)
				if s.state.values == nil then
					s.state.values = i._widgetState(s, "values", {
						1
					});
				end;
				if s.state.hovered == nil then
					s.state.hovered = i._widgetState(s, "hovered", nil);
				end;
			end,
			Update = function(s)
				local t = s.Instance;
				local u = t.TextLabel;
				local v = t.Background;
				local w = v.Plot;
				local x = w.OverlayText;
				u.Text = s.arguments.Text or "Plot Histogram";
				x.Text = s.arguments.TextOverlay or "";
				t.Size = UDim2.new(1, 0, 0, s.arguments.Height or 0);
			end,
			UpdateState = function(s)
				if s.state.hovered.lastChangeTick == i._cycleTick then
					if s.state.hovered.value then
						s.Tooltip.Visible = true;
					else
						s.Tooltip.Visible = false;
					end;
				end;
				if s.state.values.lastChangeTick == i._cycleTick then
					local t = s.Instance;
					local u = t.Background;
					local v = u.Plot;
					local w = s.state.values.value;
					local x = #w;
					local y = #s.Blocks;
					local z = s.arguments.Min;
					local A = s.arguments.Max;
					local B = s.arguments.BaseLine or 0;
					if z == nil or A == nil then
						for C, D in w do
							z = math.min(z or D, D);
							A = math.max(A or D, D);
						end;
					end;
					if y < x then
						for C = y + 1, x do
							table.insert(s.Blocks, p(v, C));
						end;
					elseif y > x then
						for C = x + 1, y do
							local D = table.remove(s.Blocks);
							if D then
								D:Destroy();
							end;
						end;
					end;
					local C = A - z;
					local D = UDim.new(1 / x, -1);
					for E = 1, x do
						local F = w[E];
						if F >= 0 then
							s.Blocks[E].Size = UDim2.new(D, UDim.new((F - B) / C));
							s.Blocks[E].Position = UDim2.fromScale((E - 1) / x, (A - F) / C);
						else
							s.Blocks[E].Size = UDim2.new(D, UDim.new((B - F) / C));
							s.Blocks[E].Position = UDim2.fromScale((E - 1) / x, (A - B) / C);
						end;
					end;
					if s.HoveredBlock then
						r(s);
					end;
				end;
			end,
			Discard = function(s)
				s.Instance:Destroy();
				j.discardState(s);
			end
		});
	end;
end);
c("widgets/Combo", function(e, f, g, h)
	return function(i, j)
		i.WidgetConstructor("Selectable", {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				Index = 2,
				NoClick = 3
			},
			Events = {
				selected = {
					Init = function(k)
					end,
					Get = function(k)
						return k.lastSelectedTick == i._cycleTick;
					end
				},
				unselected = {
					Init = function(k)
					end,
					Get = function(k)
						return k.lastUnselectedTick == i._cycleTick;
					end
				},
				active = {
					Init = function(k)
					end,
					Get = function(k)
						return k.state.index.value == k.arguments.Index;
					end
				},
				clicked = j.EVENTS.click(function(k)
					local l = k.Instance;
					return l.SelectableButton;
				end),
				rightClicked = j.EVENTS.rightClick(function(k)
					local l = k.Instance;
					return l.SelectableButton;
				end),
				doubleClicked = j.EVENTS.doubleClick(function(k)
					local l = k.Instance;
					return l.SelectableButton;
				end),
				ctrlClicked = j.EVENTS.ctrlClick(function(k)
					local l = k.Instance;
					return l.SelectableButton;
				end),
				hovered = j.EVENTS.hover(function(k)
					local l = k.Instance;
					return l.SelectableButton;
				end)
			},
			Generate = function(k)
				local l = Instance.new("Frame");
				l.Name = "Iris_Selectable";
				l.Size = UDim2.new(i._config.ItemWidth, UDim.new(0, i._config.TextSize + 2 * i._config.FramePadding.Y - i._config.ItemSpacing.Y));
				l.BackgroundTransparency = 1;
				l.BorderSizePixel = 0;
				l.ZIndex = 0;
				l.LayoutOrder = k.ZIndex;
				local o = Instance.new("TextButton");
				o.Name = "SelectableButton";
				o.Size = UDim2.new(1, 0, 0, i._config.TextSize + 2 * i._config.FramePadding.Y);
				o.Position = UDim2.fromOffset(0, -bit32.rshift(i._config.ItemSpacing.Y, 1));
				o.BackgroundColor3 = i._config.HeaderColor;
				o.ClipsDescendants = true;
				j.applyFrameStyle(o);
				j.applyTextStyle(o);
				j.UISizeConstraint(o, Vector2.xAxis);
				k.ButtonColors = {
					Color = i._config.HeaderColor,
					Transparency = 1,
					HoveredColor = i._config.HeaderHoveredColor,
					HoveredTransparency = i._config.HeaderHoveredTransparency,
					ActiveColor = i._config.HeaderActiveColor,
					ActiveTransparency = i._config.HeaderActiveTransparency
				};
				j.applyInteractionHighlights("Background", o, o, k.ButtonColors);
				j.applyButtonClick(o, function()
					if k.arguments.NoClick ~= true then
						if type(k.state.index.value) == "boolean" then
							k.state.index:set(not k.state.index.value);
						else
							k.state.index:set(k.arguments.Index);
						end;
					end;
				end);
				o.Parent = l;
				return l;
			end,
			Update = function(k)
				local l = k.Instance;
				local o = l.SelectableButton;
				o.Text = k.arguments.Text or "Selectable";
			end,
			Discard = function(k)
				k.Instance:Destroy();
				j.discardState(k);
			end,
			GenerateState = function(k)
				if k.state.index == nil then
					if k.arguments.Index ~= nil then
						error("A shared state index is required for Iris.Selectables() with an Index argument.", 5);
					end;
					k.state.index = i._widgetState(k, "index", false);
				end;
			end,
			UpdateState = function(k)
				local l = k.Instance;
				local o = l.SelectableButton;
				if k.state.index.value == (k.arguments.Index or true) then
					k.ButtonColors.Transparency = i._config.HeaderTransparency;
					o.BackgroundTransparency = i._config.HeaderTransparency;
					k.lastSelectedTick = i._cycleTick + 1;
				else
					k.ButtonColors.Transparency = 1;
					o.BackgroundTransparency = 1;
					k.lastUnselectedTick = i._cycleTick + 1;
				end;
			end
		});
		local k = false;
		local l = -1;
		local o;
		local p = function(p)
			local q = p.Instance;
			local r = q.PreviewContainer;
			local s = p.ChildContainer;
			s.Size = UDim2.fromOffset(r.AbsoluteSize.X, 0);
			local t = r.AbsolutePosition - j.GuiOffset;
			local u = r.AbsoluteSize;
			local v = s.AbsoluteSize;
			local w = i._config.PopupBorderSize;
			local x = s.Parent.AbsoluteSize;
			local y = t.X;
			local z;
			local A = Vector2.zero;
			if t.Y + v.Y > x.Y then
				z = t.Y - w;
				A = Vector2.yAxis;
			else
				z = t.Y + u.Y + w;
			end;
			s.AnchorPoint = A;
			s.Position = UDim2.fromOffset(y, z);
		end;
		j.registerEvent("InputBegan", function(q)
			if not i._started then
				return;
			end;
			if q.UserInputType ~= Enum.UserInputType.MouseButton1 and q.UserInputType ~= Enum.UserInputType.MouseButton2 and q.UserInputType ~= Enum.UserInputType.Touch then
				return;
			end;
			if k == false or (not o) then
				return;
			end;
			if l == i._cycleTick then
				return;
			end;
			local r = j.getMouseLocation();
			local s = o.Instance;
			local t = s.PreviewContainer;
			local u = o.ChildContainer;
			local v = t.AbsolutePosition - j.GuiOffset;
			local w = t.AbsolutePosition - j.GuiOffset + t.AbsoluteSize;
			if j.isPosInsideRect(r, v, w) then
				return;
			end;
			v = u.AbsolutePosition - j.GuiOffset;
			w = u.AbsolutePosition - j.GuiOffset + u.AbsoluteSize;
			if j.isPosInsideRect(r, v, w) then
				return;
			end;
			o.state.isOpened:set(false);
		end);
		i.WidgetConstructor("Combo", {
			hasState = true,
			hasChildren = true,
			Args = {
				Text = 1,
				NoButton = 2,
				NoPreview = 3
			},
			Events = {
				opened = {
					Init = function(q)
					end,
					Get = function(q)
						return q.lastOpenedTick == i._cycleTick;
					end
				},
				closed = {
					Init = function(q)
					end,
					Get = function(q)
						return q.lastClosedTick == i._cycleTick;
					end
				},
				clicked = j.EVENTS.click(function(q)
					return q.Instance;
				end),
				hovered = j.EVENTS.hover(function(q)
					return q.Instance;
				end)
			},
			Generate = function(q)
				local r = i._config.TextSize + 2 * i._config.FramePadding.Y;
				local s = Instance.new("Frame");
				s.Name = "Iris_Combo";
				s.Size = UDim2.fromScale(1, 0);
				s.AutomaticSize = Enum.AutomaticSize.Y;
				s.BackgroundTransparency = 1;
				s.BorderSizePixel = 0;
				s.LayoutOrder = q.ZIndex;
				local t = j.UIListLayout(s, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X));
				t.VerticalAlignment = Enum.VerticalAlignment.Center;
				local u = Instance.new("TextButton");
				u.Name = "PreviewContainer";
				u.Size = UDim2.new(i._config.ContentWidth, UDim.new(0, 0));
				u.AutomaticSize = Enum.AutomaticSize.Y;
				u.BackgroundTransparency = 1;
				u.Text = "";
				u.ZIndex = q.ZIndex + 2;
				u.AutoButtonColor = false;
				j.applyFrameStyle(u, true);
				j.UIListLayout(u, Enum.FillDirection.Horizontal, UDim.new(0, 0));
				j.UISizeConstraint(u, Vector2.new(r + 1));
				u.Parent = s;
				local v = Instance.new("TextLabel");
				v.Name = "PreviewLabel";
				v.Size = UDim2.new(UDim.new(1, 0), i._config.ContentHeight);
				v.AutomaticSize = Enum.AutomaticSize.Y;
				v.BackgroundColor3 = i._config.FrameBgColor;
				v.BackgroundTransparency = i._config.FrameBgTransparency;
				v.BorderSizePixel = 0;
				v.ClipsDescendants = true;
				j.applyTextStyle(v);
				j.UIPadding(v, i._config.FramePadding);
				v.Parent = u;
				local w = Instance.new("TextLabel");
				w.Name = "DropdownButton";
				w.Size = UDim2.new(0, r, i._config.ContentHeight.Scale, math.max(i._config.ContentHeight.Offset, r));
				w.BorderSizePixel = 0;
				w.BackgroundColor3 = i._config.ButtonColor;
				w.BackgroundTransparency = i._config.ButtonTransparency;
				w.Text = "";
				local x = math.round(r * 0.2);
				local y = r - 2 * x;
				local z = Instance.new("ImageLabel");
				z.Name = "Dropdown";
				z.AnchorPoint = Vector2.new(0.5, 0.5);
				z.Size = UDim2.fromOffset(y, y);
				z.Position = UDim2.fromScale(0.5, 0.5);
				z.BackgroundTransparency = 1;
				z.BorderSizePixel = 0;
				z.ImageColor3 = i._config.TextColor;
				z.ImageTransparency = i._config.TextTransparency;
				z.Parent = w;
				w.Parent = u;
				j.applyInteractionHighlightsWithMultiHighlightee("Background", u, {
					{
						v,
						{
							Color = i._config.FrameBgColor,
							Transparency = i._config.FrameBgTransparency,
							HoveredColor = i._config.FrameBgHoveredColor,
							HoveredTransparency = i._config.FrameBgHoveredTransparency,
							ActiveColor = i._config.FrameBgActiveColor,
							ActiveTransparency = i._config.FrameBgActiveTransparency
						}
					},
					{
						w,
						{
							Color = i._config.ButtonColor,
							Transparency = i._config.ButtonTransparency,
							HoveredColor = i._config.ButtonHoveredColor,
							HoveredTransparency = i._config.ButtonHoveredTransparency,
							ActiveColor = i._config.ButtonHoveredColor,
							ActiveTransparency = i._config.ButtonHoveredTransparency
						}
					}
				});
				j.applyButtonClick(u, function()
					if k and o ~= q then
						return;
					end;
					q.state.isOpened:set(not q.state.isOpened.value);
				end);
				local A = Instance.new("TextLabel");
				A.Name = "TextLabel";
				A.Size = UDim2.fromOffset(0, r);
				A.AutomaticSize = Enum.AutomaticSize.X;
				A.BackgroundTransparency = 1;
				A.BorderSizePixel = 0;
				j.applyTextStyle(A);
				A.Parent = s;
				local B = Instance.new("ScrollingFrame");
				B.Name = "ComboContainer";
				B.AutomaticSize = Enum.AutomaticSize.Y;
				B.BackgroundColor3 = i._config.PopupBgColor;
				B.BackgroundTransparency = i._config.PopupBgTransparency;
				B.BorderSizePixel = 0;
				B.AutomaticCanvasSize = Enum.AutomaticSize.Y;
				B.ScrollBarImageTransparency = i._config.ScrollbarGrabTransparency;
				B.ScrollBarImageColor3 = i._config.ScrollbarGrabColor;
				B.ScrollBarThickness = i._config.ScrollbarSize;
				B.CanvasSize = UDim2.fromScale(0, 0);
				B.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
				B.ClipsDescendants = true;
				j.UIStroke(B, i._config.WindowBorderSize, i._config.BorderColor, i._config.BorderTransparency);
				j.UIPadding(B, Vector2.new(2, i._config.WindowPadding.Y));
				j.UISizeConstraint(B, Vector2.new(100));
				local C = j.UIListLayout(B, Enum.FillDirection.Vertical, UDim.new(0, i._config.ItemSpacing.Y));
				C.VerticalAlignment = Enum.VerticalAlignment.Top;
				local D = i._rootInstance and i._rootInstance:WaitForChild("PopupScreenGui");
				B.Parent = D;
				q.ChildContainer = B;
				return s;
			end,
			Update = function(q)
				local r = q.Instance;
				local s = r.PreviewContainer;
				local t = s.PreviewLabel;
				local u = s.DropdownButton;
				local v = r.TextLabel;
				v.Text = q.arguments.Text or "Combo";
				if q.arguments.NoButton then
					u.Visible = false;
					t.Size = UDim2.new(UDim.new(1, 0), t.Size.Height);
				else
					u.Visible = true;
					local w = i._config.TextSize + 2 * i._config.FramePadding.Y;
					t.Size = UDim2.new(UDim.new(1, -w), t.Size.Height);
				end;
				if q.arguments.NoPreview then
					t.Visible = false;
					s.Size = UDim2.new(0, 0, 0, 0);
					s.AutomaticSize = Enum.AutomaticSize.XY;
				else
					t.Visible = true;
					s.Size = UDim2.new(i._config.ContentWidth, i._config.ContentHeight);
					s.AutomaticSize = Enum.AutomaticSize.Y;
				end;
			end,
			ChildAdded = function(q, r)
				p(q);
				return q.ChildContainer;
			end,
			GenerateState = function(q)
				if q.state.index == nil then
					q.state.index = i._widgetState(q, "index", "No Selection");
				end;
				q.state.index:onChange(function()
					if q.state.isOpened.value then
						q.state.isOpened:set(false);
					end;
				end);
				if q.state.isOpened == nil then
					q.state.isOpened = i._widgetState(q, "isOpened", false);
				end;
			end,
			UpdateState = function(q)
				local r = q.Instance;
				local s = q.ChildContainer;
				local t = r.PreviewContainer;
				local u = t.PreviewLabel;
				local v = t.DropdownButton;
				local w = v.Dropdown;
				if q.state.isOpened.value then
					k = true;
					o = q;
					l = i._cycleTick;
					q.lastOpenedTick = i._cycleTick + 1;
					w.Image = j.ICONS.RIGHT_POINTING_TRIANGLE;
					s.Visible = true;
					p(q);
				else
					if k then
						k = false;
						o = nil;
						q.lastClosedTick = i._cycleTick + 1;
					end;
					w.Image = j.ICONS.DOWN_POINTING_TRIANGLE;
					s.Visible = false;
				end;
				local x = q.state.index.value;
				u.Text = (typeof(x) == "EnumItem" and {
					x.Name
				} or {
					tostring(x)
				})[1];
			end,
			Discard = function(q)
				q.Instance:Destroy();
				j.discardState(q);
			end
		});
	end;
end);
c("widgets/Input", function(e, f, g, h)
	return function(i, j)
		local k = {
			Init = function(k)
			end,
			Get = function(k)
				return k.lastNumberChangedTick == i._cycleTick;
			end
		};
		local l = function(l, o, p)
			local q = typeof(l);
			local r = l;
			if q == "number" then
				return r;
			elseif q == "Vector2" then
				if o == 1 then
					return r.X;
				elseif o == 2 then
					return r.Y;
				end;
			elseif q == "Vector3" then
				if o == 1 then
					return r.X;
				elseif o == 2 then
					return r.Y;
				elseif o == 3 then
					return r.Z;
				end;
			elseif q == "UDim" then
				if o == 1 then
					return r.Scale;
				elseif o == 2 then
					return r.Offset;
				end;
			elseif q == "UDim2" then
				if o == 1 then
					return r.X.Scale;
				elseif o == 2 then
					return r.X.Offset;
				elseif o == 3 then
					return r.Y.Scale;
				elseif o == 4 then
					return r.Y.Offset;
				end;
			elseif q == "Color3" then
				local s = p.UseHSV and {
					r:ToHSV()
				} or {
					r.R,
					r.G,
					r.B
				};
				if o == 1 then
					return s[1];
				elseif o == 2 then
					return s[2];
				elseif o == 3 then
					return s[3];
				end;
			elseif q == "Rect" then
				if o == 1 then
					return r.Min.X;
				elseif o == 2 then
					return r.Min.Y;
				elseif o == 3 then
					return r.Max.X;
				elseif o == 4 then
					return r.Max.Y;
				end;
			elseif q == "table" then
				return r[o];
			end;
			error(string.format("Incorrect datatype or value: %s %s %s.", tostring(l), tostring(typeof(l)), tostring(o)));
		end;
		local o = function(o, p, q, r)
			if typeof(o) == "number" then
				return q;
			elseif typeof(o) == "Vector2" then
				if p == 1 then
					return Vector2.new(q, o.Y);
				elseif p == 2 then
					return Vector2.new(o.X, q);
				end;
			elseif typeof(o) == "Vector3" then
				if p == 1 then
					return Vector3.new(q, o.Y, o.Z);
				elseif p == 2 then
					return Vector3.new(o.X, q, o.Z);
				elseif p == 3 then
					return Vector3.new(o.X, o.Y, q);
				end;
			elseif typeof(o) == "UDim" then
				if p == 1 then
					return UDim.new(q, o.Offset);
				elseif p == 2 then
					return UDim.new(o.Scale, q);
				end;
			elseif typeof(o) == "UDim2" then
				if p == 1 then
					return UDim2.new(UDim.new(q, o.X.Offset), o.Y);
				elseif p == 2 then
					return UDim2.new(UDim.new(o.X.Scale, q), o.Y);
				elseif p == 3 then
					return UDim2.new(o.X, UDim.new(q, o.Y.Offset));
				elseif p == 4 then
					return UDim2.new(o.X, UDim.new(o.Y.Scale, q));
				end;
			elseif typeof(o) == "Rect" then
				if p == 1 then
					return Rect.new(Vector2.new(q, o.Min.Y), o.Max);
				elseif p == 2 then
					return Rect.new(Vector2.new(o.Min.X, q), o.Max);
				elseif p == 3 then
					return Rect.new(o.Min, Vector2.new(q, o.Max.Y));
				elseif p == 4 then
					return Rect.new(o.Min, Vector2.new(o.Max.X, q));
				end;
			elseif typeof(o) == "Color3" then
				if r.UseHSV then
					local s, t, u = o:ToHSV();
					if p == 1 then
						return Color3.fromHSV(q, t, u);
					elseif p == 2 then
						return Color3.fromHSV(s, q, u);
					elseif p == 3 then
						return Color3.fromHSV(s, t, q);
					end;
				end;
				if p == 1 then
					return Color3.new(q, o.G, o.B);
				elseif p == 2 then
					return Color3.new(o.R, q, o.B);
				elseif p == 3 then
					return Color3.new(o.R, o.G, q);
				end;
			end;
			error(string.format("Incorrect datatype or value %s %s %s.", tostring(o), tostring(typeof(o)), tostring(p)));
		end;
		local p = {
			Num = {
				1
			},
			Vector2 = {
				1,
				1
			},
			Vector3 = {
				1,
				1,
				1
			},
			UDim = {
				0.01,
				1
			},
			UDim2 = {
				0.01,
				1,
				0.01,
				1
			},
			Color3 = {
				1,
				1,
				1
			},
			Color4 = {
				1,
				1,
				1,
				1
			},
			Rect = {
				1,
				1,
				1,
				1
			}
		};
		local q = {
			Num = {
				0
			},
			Vector2 = {
				0,
				0
			},
			Vector3 = {
				0,
				0,
				0
			},
			UDim = {
				0,
				0
			},
			UDim2 = {
				0,
				0,
				0,
				0
			},
			Rect = {
				0,
				0,
				0,
				0
			}
		};
		local r = {
			Num = {
				100
			},
			Vector2 = {
				100,
				100
			},
			Vector3 = {
				100,
				100,
				100
			},
			UDim = {
				1,
				960
			},
			UDim2 = {
				1,
				960,
				1,
				960
			},
			Rect = {
				960,
				960,
				960,
				960
			}
		};
		local s = {
			Num = {
				""
			},
			Vector2 = {
				"X: ",
				"Y: "
			},
			Vector3 = {
				"X: ",
				"Y: ",
				"Z: "
			},
			UDim = {
				"",
				""
			},
			UDim2 = {
				"",
				"",
				"",
				""
			},
			Color3_RGB = {
				"R: ",
				"G: ",
				"B: "
			},
			Color3_HSV = {
				"H: ",
				"S: ",
				"V: "
			},
			Color4_RGB = {
				"R: ",
				"G: ",
				"B: ",
				"T: "
			},
			Color4_HSV = {
				"H: ",
				"S: ",
				"V: ",
				"T: "
			},
			Rect = {
				"X: ",
				"Y: ",
				"X: ",
				"Y: "
			}
		};
		local t = {
			Num = {
				0
			},
			Vector2 = {
				0,
				0
			},
			Vector3 = {
				0,
				0,
				0
			},
			UDim = {
				3,
				0
			},
			UDim2 = {
				3,
				0,
				3,
				0
			},
			Color3 = {
				0,
				0,
				0
			},
			Color4 = {
				0,
				0,
				0,
				0
			},
			Rect = {
				0,
				0,
				0,
				0
			}
		};
		local u;
		do
			local v = function(v, w, x, y)
				x = x + (2 * i._config.ItemInnerSpacing.X + 2 * y);
				local z = j.abstractButton.Generate(v);
				z.Name = "SubButton";
				z.ZIndex = 5;
				z.LayoutOrder = 5;
				z.TextXAlignment = Enum.TextXAlignment.Center;
				z.Text = "-";
				z.Size = UDim2.fromOffset(i._config.TextSize + 2 * i._config.FramePadding.Y, i._config.TextSize);
				z.Parent = w;
				j.applyButtonClick(z, function()
					local A = j.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or j.UserInputService:IsKeyDown(Enum.KeyCode.RightControl);
					local B = (v.arguments.Increment and l(v.arguments.Increment, 1, v.arguments) or 1) * (A and 100 or 1);
					local C = v.state.number.value - B;
					if v.arguments.Min ~= nil then
						C = math.max(C, l(v.arguments.Min, 1, v.arguments));
					end;
					if v.arguments.Max ~= nil then
						C = math.min(C, l(v.arguments.Max, 1, v.arguments));
					end;
					v.state.number:set(C);
					v.lastNumberChangedTick = i._cycleTick + 1;
				end);
				local A = j.abstractButton.Generate(v);
				A.Name = "AddButton";
				A.ZIndex = 6;
				A.LayoutOrder = 6;
				A.TextXAlignment = Enum.TextXAlignment.Center;
				A.Text = "+";
				A.Size = UDim2.fromOffset(i._config.TextSize + 2 * i._config.FramePadding.Y, i._config.TextSize);
				A.Parent = w;
				j.applyButtonClick(A, function()
					local B = j.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or j.UserInputService:IsKeyDown(Enum.KeyCode.RightControl);
					local C = (v.arguments.Increment and l(v.arguments.Increment, 1, v.arguments) or 1) * (B and 100 or 1);
					local D = v.state.number.value + C;
					if v.arguments.Min ~= nil then
						D = math.max(D, l(v.arguments.Min, 1, v.arguments));
					end;
					if v.arguments.Max ~= nil then
						D = math.min(D, l(v.arguments.Max, 1, v.arguments));
					end;
					v.state.number:set(D);
					v.lastNumberChangedTick = i._cycleTick + 1;
				end);
				return x;
			end;
			function u(w, x, y)
				return {
					hasState = true,
					hasChildren = false,
					Args = {
						Text = 1,
						Increment = 2,
						Min = 3,
						Max = 4,
						Format = 5
					},
					Events = {
						numberChanged = k,
						hovered = j.EVENTS.hover(function(z)
							return z.Instance;
						end)
					},
					Generate = function(z)
						local A = Instance.new("Frame");
						A.Name = "Iris_Input" .. w;
						A.Size = UDim2.fromScale(1, 0);
						A.BackgroundTransparency = 1;
						A.BorderSizePixel = 0;
						A.LayoutOrder = z.ZIndex;
						A.AutomaticSize = Enum.AutomaticSize.Y;
						local B = j.UIListLayout(A, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X));
						B.VerticalAlignment = Enum.VerticalAlignment.Center;
						local C = 0;
						local D = i._config.TextSize + 2 * i._config.FramePadding.Y;
						if x == 1 then
							C = v(z, A, C, D);
						end;
						local E = UDim.new(i._config.ContentWidth.Scale / x, (i._config.ContentWidth.Offset - i._config.ItemInnerSpacing.X * (x - 1) - C) / x);
						local F = UDim.new(E.Scale * (x - 1), E.Offset * (x - 1) + i._config.ItemInnerSpacing.X * (x - 1) + C);
						local G = i._config.ContentWidth - F;
						for H = 1, x do
							local I = Instance.new("TextBox");
							I.Name = "InputField" .. tostring(H);
							I.LayoutOrder = H;
							if H == x then
								I.Size = UDim2.new(G, i._config.ContentHeight);
							else
								I.Size = UDim2.new(E, i._config.ContentHeight);
							end;
							I.AutomaticSize = Enum.AutomaticSize.Y;
							I.BackgroundColor3 = i._config.FrameBgColor;
							I.BackgroundTransparency = i._config.FrameBgTransparency;
							I.ClearTextOnFocus = false;
							I.TextTruncate = Enum.TextTruncate.AtEnd;
							I.ClipsDescendants = true;
							j.applyFrameStyle(I);
							j.applyTextStyle(I);
							j.UISizeConstraint(I, Vector2.xAxis);
							I.Parent = A;
							I.FocusLost:Connect(function()
								local J = tonumber(I.Text:match("-?%d*%.?%d*"));
								if J ~= nil then
									if z.arguments.Min ~= nil then
										J = math.max(J, l(z.arguments.Min, H, z.arguments));
									end;
									if z.arguments.Max ~= nil then
										J = math.min(J, l(z.arguments.Max, H, z.arguments));
									end;
									if z.arguments.Increment then
										J = math.round(J / l(z.arguments.Increment, H, z.arguments)) * l(z.arguments.Increment, H, z.arguments);
									end;
									z.state.number:set(o(z.state.number.value, H, J, z.arguments));
									z.lastNumberChangedTick = i._cycleTick + 1;
								end;
								local K = z.arguments.Format[H] or z.arguments.Format[1];
								if z.arguments.Prefix then
									K = z.arguments.Prefix[H] .. K;
								end;
								I.Text = string.format(K, l(z.state.number.value, H, z.arguments));
								z.state.editingText:set(0);
							end);
							I.Focused:Connect(function()
								I.CursorPosition = (#I.Text) + 1;
								I.SelectionStart = 1;
								z.state.editingText:set(H);
							end);
						end;
						local H = Instance.new("TextLabel");
						H.Name = "TextLabel";
						H.BackgroundTransparency = 1;
						H.BorderSizePixel = 0;
						H.LayoutOrder = 7;
						H.AutomaticSize = Enum.AutomaticSize.XY;
						j.applyTextStyle(H);
						H.Parent = A;
						return A;
					end,
					Update = function(z)
						local A = z.Instance;
						local B = A.TextLabel;
						B.Text = z.arguments.Text or string.format("Input %s", tostring(w));
						if x == 1 then
							A.SubButton.Visible = not z.arguments.NoButtons;
							A.AddButton.Visible = not z.arguments.NoButtons;
						end;
						if z.arguments.Format and typeof(z.arguments.Format) ~= "table" then
							z.arguments.Format = {
								z.arguments.Format
							};
						elseif not z.arguments.Format then
							local C = {};
							for D = 1, x do
								local E = t[w][D];
								if z.arguments.Increment then
									local F = l(z.arguments.Increment, D, z.arguments);
									E = math.max(E, math.ceil(-math.log10((F == 0 and 1 or F))), E);
								end;
								if z.arguments.Max then
									local F = l(z.arguments.Max, D, z.arguments);
									E = math.max(E, math.ceil(-math.log10((F == 0 and 1 or F))), E);
								end;
								if z.arguments.Min then
									local F = l(z.arguments.Min, D, z.arguments);
									E = math.max(E, math.ceil(-math.log10((F == 0 and 1 or F))), E);
								end;
								if E > 0 then
									C[D] = string.format("%%.%sf", tostring(E));
								else
									C[D] = "%d";
								end;
							end;
							z.arguments.Format = C;
							z.arguments.Prefix = s[w];
						end;
					end,
					Discard = function(z)
						z.Instance:Destroy();
						j.discardState(z);
					end,
					GenerateState = function(z)
						if z.state.number == nil then
							z.state.number = i._widgetState(z, "number", y);
						end;
						if z.state.editingText == nil then
							z.state.editingText = i._widgetState(z, "editingText", 0);
						end;
					end,
					UpdateState = function(z)
						local A = z.Instance;
						for B = 1, x do
							local C = A:FindFirstChild("InputField" .. tostring(B));
							local D = z.arguments.Format[B] or z.arguments.Format[1];
							if z.arguments.Prefix then
								D = z.arguments.Prefix[B] .. D;
							end;
							C.Text = string.format(D, l(z.state.number.value, B, z.arguments));
						end;
					end
				};
			end;
		end;
		local v;
		local w;
		do
			local x = 0;
			local y = false;
			local z;
			local A = 0;
			local B = "";
			local C = function()
				local C = (j.getMouseLocation()).X;
				local D = C - x;
				x = C;
				if y == false then
					return;
				end;
				if z == nil then
					return;
				end;
				local E = z.state.number;
				if B == "Color3" or B == "Color4" then
					local F = z;
					E = F.state.color;
					if A == 4 then
						E = F.state.transparency;
					end;
				end;
				local F = z.arguments.Increment and l(z.arguments.Increment, A, z.arguments) or p[B][A];
				F = F * ((j.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or j.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) and 10 or 1);
				F = F * ((j.UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or j.UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) and 0.1 or 1);
				F = F * ((B == "Color3" or B == "Color4") and 5 or 1);
				local G = l(E.value, A, z.arguments);
				local H = G + D * F;
				if z.arguments.Min ~= nil then
					H = math.max(H, l(z.arguments.Min, A, z.arguments));
				end;
				if z.arguments.Max ~= nil then
					H = math.min(H, l(z.arguments.Max, A, z.arguments));
				end;
				E:set(o(E.value, A, H, z.arguments));
				z.lastNumberChangedTick = i._cycleTick + 1;
			end;
			local D = function(D, E, F, G, H)
				local I = j.getTime();
				local J = I - D.lastClickedTime < i._config.MouseDoubleClickTime;
				local K = j.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or j.UserInputService:IsKeyDown(Enum.KeyCode.RightControl);
				if J and (Vector2.new(G, H) - D.lastClickedPosition).Magnitude < i._config.MouseDoubleClickMaxDist or K then
					D.state.editingText:set(F);
				else
					D.lastClickedTime = I;
					D.lastClickedPosition = Vector2.new(G, H);
					y = true;
					z = D;
					A = F;
					B = E;
					C();
				end;
			end;
			j.registerEvent("InputChanged", function()
				if not i._started then
					return;
				end;
				C();
			end);
			j.registerEvent("InputEnded", function(E)
				if not i._started then
					return;
				end;
				if E.UserInputType == Enum.UserInputType.MouseButton1 and y then
					y = false;
					z = nil;
					A = 0;
				end;
			end);
			function v(E, F, G)
				return {
					hasState = true,
					hasChildren = false,
					Args = {
						Text = 1,
						Increment = 2,
						Min = 3,
						Max = 4,
						Format = 5
					},
					Events = {
						numberChanged = k,
						hovered = j.EVENTS.hover(function(H)
							return H.Instance;
						end)
					},
					Generate = function(H)
						H.lastClickedTime = -1;
						H.lastClickedPosition = Vector2.zero;
						local I = Instance.new("Frame");
						I.Name = "Iris_Drag" .. E;
						I.Size = UDim2.fromScale(1, 0);
						I.BackgroundTransparency = 1;
						I.BorderSizePixel = 0;
						I.LayoutOrder = H.ZIndex;
						I.AutomaticSize = Enum.AutomaticSize.Y;
						local J = j.UIListLayout(I, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X));
						J.VerticalAlignment = Enum.VerticalAlignment.Center;
						local K = 0;
						local L = i._config.TextSize + 2 * i._config.FramePadding.Y;
						if E == "Color3" or E == "Color4" then
							K = K + (i._config.ItemInnerSpacing.X + L);
							local M = Instance.new("ImageLabel");
							M.Name = "ColorBox";
							M.BorderSizePixel = 0;
							M.Size = UDim2.fromOffset(L, L);
							M.LayoutOrder = 5;
							M.Image = j.ICONS.ALPHA_BACKGROUND_TEXTURE;
							M.ImageTransparency = 1;
							j.applyFrameStyle(M, true);
							M.Parent = I;
						end;
						local M = UDim.new(i._config.ContentWidth.Scale / F, (i._config.ContentWidth.Offset - i._config.ItemInnerSpacing.X * (F - 1) - K) / F);
						local N = UDim.new(M.Scale * (F - 1), M.Offset * (F - 1) + i._config.ItemInnerSpacing.X * (F - 1) + K);
						local O = i._config.ContentWidth - N;
						for P = 1, F do
							local Q = Instance.new("TextButton");
							Q.Name = "DragField" .. tostring(P);
							Q.LayoutOrder = P;
							if P == F then
								Q.Size = UDim2.new(O, i._config.ContentHeight);
							else
								Q.Size = UDim2.new(M, i._config.ContentHeight);
							end;
							Q.AutomaticSize = Enum.AutomaticSize.Y;
							Q.BackgroundColor3 = i._config.FrameBgColor;
							Q.BackgroundTransparency = i._config.FrameBgTransparency;
							Q.AutoButtonColor = false;
							Q.Text = "";
							Q.ClipsDescendants = true;
							j.applyFrameStyle(Q);
							j.applyTextStyle(Q);
							j.UISizeConstraint(Q, Vector2.xAxis);
							Q.TextXAlignment = Enum.TextXAlignment.Center;
							Q.Parent = I;
							j.applyInteractionHighlights("Background", Q, Q, {
								Color = i._config.FrameBgColor,
								Transparency = i._config.FrameBgTransparency,
								HoveredColor = i._config.FrameBgHoveredColor,
								HoveredTransparency = i._config.FrameBgHoveredTransparency,
								ActiveColor = i._config.FrameBgActiveColor,
								ActiveTransparency = i._config.FrameBgActiveTransparency
							});
							local R = Instance.new("TextBox");
							R.Name = "InputField";
							R.Size = UDim2.new(1, 0, 1, 0);
							R.BackgroundTransparency = 1;
							R.ClearTextOnFocus = false;
							R.TextTruncate = Enum.TextTruncate.AtEnd;
							R.ClipsDescendants = true;
							R.Visible = false;
							j.applyFrameStyle(R, true);
							j.applyTextStyle(R);
							R.Parent = Q;
							R.FocusLost:Connect(function()
								local S = tonumber(R.Text:match("-?%d*%.?%d*"));
								local T = H.state.number;
								local U = H;
								if E == "Color4" and P == 4 then
									T = U.state.transparency;
								elseif E == "Color3" or E == "Color4" then
									T = U.state.color;
								end;
								if S ~= nil then
									if E == "Color3" or E == "Color4" and (not U.arguments.UseFloats) then
										S = S / 255;
									end;
									if H.arguments.Min ~= nil then
										S = math.max(S, l(H.arguments.Min, P, H.arguments));
									end;
									if H.arguments.Max ~= nil then
										S = math.min(S, l(H.arguments.Max, P, H.arguments));
									end;
									if H.arguments.Increment then
										S = math.round(S / l(H.arguments.Increment, P, H.arguments)) * l(H.arguments.Increment, P, H.arguments);
									end;
									T:set(o(T.value, P, S, H.arguments));
									H.lastNumberChangedTick = i._cycleTick + 1;
								end;
								local V = l(T.value, P, H.arguments);
								if E == "Color3" or E == "Color4" and (not U.arguments.UseFloats) then
									V = math.round(V * 255);
								end;
								local W = H.arguments.Format[P] or H.arguments.Format[1];
								if H.arguments.Prefix then
									W = H.arguments.Prefix[P] .. W;
								end;
								R.Text = string.format(W, V);
								H.state.editingText:set(0);
								R:ReleaseFocus(true);
							end);
							R.Focused:Connect(function()
								R.CursorPosition = (#R.Text) + 1;
								R.SelectionStart = 1;
								H.state.editingText:set(P);
							end);
							j.applyButtonDown(Q, function(S, T)
								D(H, E, P, S, T);
							end);
						end;
						local P = Instance.new("TextLabel");
						P.Name = "TextLabel";
						P.BackgroundTransparency = 1;
						P.BorderSizePixel = 0;
						P.LayoutOrder = 6;
						P.AutomaticSize = Enum.AutomaticSize.XY;
						j.applyTextStyle(P);
						P.Parent = I;
						return I;
					end,
					Update = function(H)
						local I = H.Instance;
						local J = I.TextLabel;
						J.Text = H.arguments.Text or string.format("Drag %s", tostring(E));
						if H.arguments.Format and typeof(H.arguments.Format) ~= "table" then
							H.arguments.Format = {
								H.arguments.Format
							};
						elseif not H.arguments.Format then
							local K = {};
							for L = 1, F do
								local M = t[E][L];
								if H.arguments.Increment then
									local N = l(H.arguments.Increment, L, H.arguments);
									M = math.max(M, math.ceil(-math.log10((N == 0 and 1 or N))), M);
								end;
								if H.arguments.Max then
									local N = l(H.arguments.Max, L, H.arguments);
									M = math.max(M, math.ceil(-math.log10((N == 0 and 1 or N))), M);
								end;
								if H.arguments.Min then
									local N = l(H.arguments.Min, L, H.arguments);
									M = math.max(M, math.ceil(-math.log10((N == 0 and 1 or N))), M);
								end;
								if M > 0 then
									K[L] = string.format("%%.%sf", tostring(M));
								else
									K[L] = "%d";
								end;
							end;
							H.arguments.Format = K;
							H.arguments.Prefix = s[E];
						end;
					end,
					Discard = function(H)
						H.Instance:Destroy();
						j.discardState(H);
					end,
					GenerateState = function(H)
						if H.state.number == nil then
							H.state.number = i._widgetState(H, "number", G);
						end;
						if H.state.editingText == nil then
							H.state.editingText = i._widgetState(H, "editingText", false);
						end;
					end,
					UpdateState = function(H)
						local I = H.Instance;
						local J = H;
						for K = 1, F do
							local L = H.state.number;
							if E == "Color3" or E == "Color4" then
								L = J.state.color;
								if K == 4 then
									L = J.state.transparency;
								end;
							end;
							local M = I:FindFirstChild("DragField" .. tostring(K));
							local N = M.InputField;
							local O = l(L.value, K, H.arguments);
							if (E == "Color3" or E == "Color4") and (not J.arguments.UseFloats) then
								O = math.round(O * 255);
							end;
							local P = H.arguments.Format[K] or H.arguments.Format[1];
							if H.arguments.Prefix then
								P = H.arguments.Prefix[K] .. P;
							end;
							M.Text = string.format(P, O);
							N.Text = tostring(O);
							if H.state.editingText.value == K then
								N.Visible = true;
								N:CaptureFocus();
								M.TextTransparency = 1;
							else
								N.Visible = false;
								M.TextTransparency = i._config.TextTransparency;
							end;
						end;
						if E == "Color3" or E == "Color4" then
							local K = I.ColorBox;
							K.BackgroundColor3 = J.state.color.value;
							if E == "Color4" then
								K.ImageTransparency = 1 - J.state.transparency.value;
							end;
						end;
					end
				};
			end;
			function w(E, ...)
				local F = {
					...
				};
				local G = v(E, E == "Color4" and 4 or 3, F[1]);
				return j.extend(G, {
					Args = {
						Text = 1,
						UseFloats = 2,
						UseHSV = 3,
						Format = 4
					},
					Update = function(H)
						local I = H.Instance;
						local J = I.TextLabel;
						J.Text = H.arguments.Text or string.format("Drag %s", tostring(E));
						if H.arguments.Format and typeof(H.arguments.Format) ~= "table" then
							H.arguments.Format = {
								H.arguments.Format
							};
						elseif not H.arguments.Format then
							if H.arguments.UseFloats then
								H.arguments.Format = {
									"%.3f"
								};
							else
								H.arguments.Format = {
									"%d"
								};
							end;
							H.arguments.Prefix = s[E .. (H.arguments.UseHSV and "_HSV" or "_RGB")];
						end;
						H.arguments.Min = {
							0,
							0,
							0,
							0
						};
						H.arguments.Max = {
							1,
							1,
							1,
							1
						};
						H.arguments.Increment = {
							0.001,
							0.001,
							0.001,
							0.001
						};
						if H.state then
							H.state.color.lastChangeTick = i._cycleTick;
							if E == "Color4" then
								H.state.transparency.lastChangeTick = i._cycleTick;
							end;
							i._widgets[H.type].UpdateState(H);
						end;
					end,
					GenerateState = function(H)
						if H.state.color == nil then
							H.state.color = i._widgetState(H, "color", F[1]);
						end;
						if E == "Color4" then
							if H.state.transparency == nil then
								H.state.transparency = i._widgetState(H, "transparency", F[2]);
							end;
						end;
						if H.state.editingText == nil then
							H.state.editingText = i._widgetState(H, "editingText", false);
						end;
					end
				});
			end;
		end;
		local x;
		local y;
		do
			local z = false;
			local A;
			local B = 0;
			local C = "";
			local D = function()
				if z == false then
					return;
				end;
				if A == nil then
					return;
				end;
				local D = A.Instance;
				local E = D:FindFirstChild("SliderField" .. tostring(B));
				local F = E.GrabBar;
				local G = A.arguments.Increment and l(A.arguments.Increment, B, A.arguments) or p[C][B];
				local H = A.arguments.Min and l(A.arguments.Min, B, A.arguments) or q[C][B];
				local I = A.arguments.Max and l(A.arguments.Max, B, A.arguments) or r[C][B];
				local J = F.AbsoluteSize.X;
				local K = (j.getMouseLocation()).X - (E.AbsolutePosition.X - j.GuiOffset.X + J / 2);
				local L = K / (E.AbsoluteSize.X - J);
				local M = math.floor((I - H) / G);
				local N = math.clamp(math.round(L * M) * G + H, H, I);
				A.state.number:set(o(A.state.number.value, B, N, A.arguments));
				A.lastNumberChangedTick = i._cycleTick + 1;
			end;
			local E = function(E, F, G)
				local H = j.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or j.UserInputService:IsKeyDown(Enum.KeyCode.RightControl);
				if H then
					E.state.editingText:set(G);
				else
					z = true;
					A = E;
					B = G;
					C = F;
					D();
				end;
			end;
			j.registerEvent("InputChanged", function()
				if not i._started then
					return;
				end;
				D();
			end);
			j.registerEvent("InputEnded", function(F)
				if not i._started then
					return;
				end;
				if F.UserInputType == Enum.UserInputType.MouseButton1 and z then
					z = false;
					A = nil;
					B = 0;
					C = "";
				end;
			end);
			function x(F, G, H)
				return {
					hasState = true,
					hasChildren = false,
					Args = {
						Text = 1,
						Increment = 2,
						Min = 3,
						Max = 4,
						Format = 5
					},
					Events = {
						numberChanged = k,
						hovered = j.EVENTS.hover(function(I)
							return I.Instance;
						end)
					},
					Generate = function(I)
						local J = Instance.new("Frame");
						J.Name = "Iris_Slider" .. F;
						J.Size = UDim2.fromScale(1, 0);
						J.BackgroundTransparency = 1;
						J.BorderSizePixel = 0;
						J.LayoutOrder = I.ZIndex;
						J.AutomaticSize = Enum.AutomaticSize.Y;
						local K = j.UIListLayout(J, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X));
						K.VerticalAlignment = Enum.VerticalAlignment.Center;
						local L = UDim.new(i._config.ContentWidth.Scale / G, (i._config.ContentWidth.Offset - i._config.ItemInnerSpacing.X * (G - 1)) / G);
						local M = UDim.new(L.Scale * (G - 1), L.Offset * (G - 1) + i._config.ItemInnerSpacing.X * (G - 1));
						local N = i._config.ContentWidth - M;
						for O = 1, G do
							local P = Instance.new("TextButton");
							P.Name = "SliderField" .. tostring(O);
							P.LayoutOrder = O;
							if O == G then
								P.Size = UDim2.new(N, i._config.ContentHeight);
							else
								P.Size = UDim2.new(L, i._config.ContentHeight);
							end;
							P.AutomaticSize = Enum.AutomaticSize.Y;
							P.BackgroundColor3 = i._config.FrameBgColor;
							P.BackgroundTransparency = i._config.FrameBgTransparency;
							P.AutoButtonColor = false;
							P.Text = "";
							P.ClipsDescendants = true;
							j.applyFrameStyle(P);
							j.applyTextStyle(P);
							j.UISizeConstraint(P, Vector2.xAxis);
							P.Parent = J;
							local Q = Instance.new("TextLabel");
							Q.Name = "OverlayText";
							Q.Size = UDim2.fromScale(1, 1);
							Q.BackgroundTransparency = 1;
							Q.BorderSizePixel = 0;
							Q.ZIndex = 10;
							Q.ClipsDescendants = true;
							j.applyTextStyle(Q);
							Q.TextXAlignment = Enum.TextXAlignment.Center;
							Q.Parent = P;
							j.applyInteractionHighlights("Background", P, P, {
								Color = i._config.FrameBgColor,
								Transparency = i._config.FrameBgTransparency,
								HoveredColor = i._config.FrameBgHoveredColor,
								HoveredTransparency = i._config.FrameBgHoveredTransparency,
								ActiveColor = i._config.FrameBgActiveColor,
								ActiveTransparency = i._config.FrameBgActiveTransparency
							});
							local R = Instance.new("TextBox");
							R.Name = "InputField";
							R.Size = UDim2.new(1, 0, 1, 0);
							R.BackgroundTransparency = 1;
							R.ClearTextOnFocus = false;
							R.TextTruncate = Enum.TextTruncate.AtEnd;
							R.ClipsDescendants = true;
							R.Visible = false;
							j.applyFrameStyle(R, true);
							j.applyTextStyle(R);
							R.Parent = P;
							R.FocusLost:Connect(function()
								local S = tonumber(R.Text:match("-?%d*%.?%d*"));
								if S ~= nil then
									if I.arguments.Min ~= nil then
										S = math.max(S, l(I.arguments.Min, O, I.arguments));
									end;
									if I.arguments.Max ~= nil then
										S = math.min(S, l(I.arguments.Max, O, I.arguments));
									end;
									if I.arguments.Increment then
										S = math.round(S / l(I.arguments.Increment, O, I.arguments)) * l(I.arguments.Increment, O, I.arguments);
									end;
									I.state.number:set(o(I.state.number.value, O, S, I.arguments));
									I.lastNumberChangedTick = i._cycleTick + 1;
								end;
								local T = I.arguments.Format[O] or I.arguments.Format[1];
								if I.arguments.Prefix then
									T = I.arguments.Prefix[O] .. T;
								end;
								R.Text = string.format(T, l(I.state.number.value, O, I.arguments));
								I.state.editingText:set(0);
								R:ReleaseFocus(true);
							end);
							R.Focused:Connect(function()
								R.CursorPosition = (#R.Text) + 1;
								R.SelectionStart = 1;
								I.state.editingText:set(O);
							end);
							j.applyButtonDown(P, function()
								E(I, F, O);
							end);
							local S = Instance.new("Frame");
							S.Name = "GrabBar";
							S.ZIndex = 5;
							S.AnchorPoint = Vector2.new(0.5, 0.5);
							S.Position = UDim2.new(0, 0, 0.5, 0);
							S.BorderSizePixel = 0;
							S.BackgroundColor3 = i._config.SliderGrabColor;
							S.Transparency = i._config.SliderGrabTransparency;
							if i._config.GrabRounding > 0 then
								j.UICorner(S, i._config.GrabRounding);
							end;
							j.UISizeConstraint(S, Vector2.new(i._config.GrabMinSize, 0));
							S.Parent = P;
						end;
						local O = Instance.new("TextLabel");
						O.Name = "TextLabel";
						O.BackgroundTransparency = 1;
						O.BorderSizePixel = 0;
						O.LayoutOrder = 5;
						O.AutomaticSize = Enum.AutomaticSize.XY;
						j.applyTextStyle(O);
						O.Parent = J;
						return J;
					end,
					Update = function(I)
						local J = I.Instance;
						local K = J.TextLabel;
						K.Text = I.arguments.Text or string.format("Slider %s", tostring(F));
						if I.arguments.Format and typeof(I.arguments.Format) ~= "table" then
							I.arguments.Format = {
								I.arguments.Format
							};
						elseif not I.arguments.Format then
							local L = {};
							for M = 1, G do
								local N = t[F][M];
								if I.arguments.Increment then
									local O = l(I.arguments.Increment, M, I.arguments);
									N = math.max(N, math.ceil(-math.log10((O == 0 and 1 or O))), N);
								end;
								if I.arguments.Max then
									local O = l(I.arguments.Max, M, I.arguments);
									N = math.max(N, math.ceil(-math.log10((O == 0 and 1 or O))), N);
								end;
								if I.arguments.Min then
									local O = l(I.arguments.Min, M, I.arguments);
									N = math.max(N, math.ceil(-math.log10((O == 0 and 1 or O))), N);
								end;
								if N > 0 then
									L[M] = string.format("%%.%sf", tostring(N));
								else
									L[M] = "%d";
								end;
							end;
							I.arguments.Format = L;
							I.arguments.Prefix = s[F];
						end;
						for L = 1, G do
							local M = J:FindFirstChild("SliderField" .. tostring(L));
							local N = M.GrabBar;
							local O = I.arguments.Increment and l(I.arguments.Increment, L, I.arguments) or p[F][L];
							local P = I.arguments.Min and l(I.arguments.Min, L, I.arguments) or q[F][L];
							local Q = I.arguments.Max and l(I.arguments.Max, L, I.arguments) or r[F][L];
							local R = 1 / math.floor(((1 + Q - P) / O));
							N.Size = UDim2.new(R, 0, 1, 0);
						end;
						local L = (#i._postCycleCallbacks) + 1;
						local M = i._cycleTick + 1;
						i._postCycleCallbacks[L] = function()
							if i._cycleTick >= M then
								if I.lastCycleTick ~= (-1) then
									I.state.number.lastChangeTick = i._cycleTick;
									i._widgets[string.format("Slider%s", tostring(F))].UpdateState(I);
								end;
								i._postCycleCallbacks[L] = nil;
							end;
						end;
					end,
					Discard = function(I)
						I.Instance:Destroy();
						j.discardState(I);
					end,
					GenerateState = function(I)
						if I.state.number == nil then
							I.state.number = i._widgetState(I, "number", H);
						end;
						if I.state.editingText == nil then
							I.state.editingText = i._widgetState(I, "editingText", false);
						end;
					end,
					UpdateState = function(I)
						local J = I.Instance;
						for K = 1, G do
							local L = J:FindFirstChild("SliderField" .. tostring(K));
							local M = L.InputField;
							local N = L.OverlayText;
							local O = L.GrabBar;
							local P = l(I.state.number.value, K, I.arguments);
							local Q = I.arguments.Format[K] or I.arguments.Format[1];
							if I.arguments.Prefix then
								Q = I.arguments.Prefix[K] .. Q;
							end;
							N.Text = string.format(Q, P);
							M.Text = tostring(P);
							local R = I.arguments.Increment and l(I.arguments.Increment, K, I.arguments) or p[F][K];
							local S = I.arguments.Min and l(I.arguments.Min, K, I.arguments) or q[F][K];
							local T = I.arguments.Max and l(I.arguments.Max, K, I.arguments) or r[F][K];
							local U = L.AbsoluteSize.X;
							local V = U - O.AbsoluteSize.X;
							local W = (P - S) / (T - S);
							local X = math.floor((T - S) / R);
							local Y = math.clamp(math.floor(W * X) / X, 0, 1);
							local Z = V / U * Y + (1 - V / U) / 2;
							O.Position = UDim2.new(Z, 0, 0.5, 0);
							if I.state.editingText.value == K then
								M.Visible = true;
								N.Visible = false;
								O.Visible = false;
								M:CaptureFocus();
							else
								M.Visible = false;
								N.Visible = true;
								O.Visible = true;
							end;
						end;
					end
				};
			end;
			function y(F, G)
				local H = x("Enum", 1, G.Value);
				local I = {
					string
				};
				for J, K in F:GetEnumItems() do
					I[K.Value] = K.Name;
				end;
				return j.extend(H, {
					Args = {
						Text = 1
					},
					Update = function(J)
						local K = J.Instance;
						local L = K.TextLabel;
						L.Text = J.arguments.Text or "Input Enum";
						J.arguments.Increment = 1;
						J.arguments.Min = 0;
						J.arguments.Max = (#F:GetEnumItems()) - 1;
						local M = K:FindFirstChild("SliderField1");
						local N = M.GrabBar;
						local O = 1 / math.floor((#F:GetEnumItems()));
						N.Size = UDim2.new(O, 0, 1, 0);
					end,
					GenerateState = function(J)
						if J.state.number == nil then
							J.state.number = i._widgetState(J, "number", G.Value);
						end;
						if J.state.enumItem == nil then
							J.state.enumItem = i._widgetState(J, "enumItem", G);
						end;
						if J.state.editingText == nil then
							J.state.editingText = i._widgetState(J, "editingText", false);
						end;
					end
				});
			end;
		end;
		do
			local z = u("Num", 1, 0);
			z.Args.NoButtons = 6;
			i.WidgetConstructor("InputNum", z);
		end;
		i.WidgetConstructor("InputVector2", u("Vector2", 2, Vector2.zero));
		i.WidgetConstructor("InputVector3", u("Vector3", 3, Vector3.zero));
		i.WidgetConstructor("InputUDim", u("UDim", 2, UDim.new()));
		i.WidgetConstructor("InputUDim2", u("UDim2", 4, UDim2.new()));
		i.WidgetConstructor("InputRect", u("Rect", 4, Rect.new(0, 0, 0, 0)));
		i.WidgetConstructor("DragNum", v("Num", 1, 0));
		i.WidgetConstructor("DragVector2", v("Vector2", 2, Vector2.zero));
		i.WidgetConstructor("DragVector3", v("Vector3", 3, Vector3.zero));
		i.WidgetConstructor("DragUDim", v("UDim", 2, UDim.new()));
		i.WidgetConstructor("DragUDim2", v("UDim2", 4, UDim2.new()));
		i.WidgetConstructor("DragRect", v("Rect", 4, Rect.new(0, 0, 0, 0)));
		i.WidgetConstructor("InputColor3", w("Color3", Color3.fromRGB(0, 0, 0)));
		i.WidgetConstructor("InputColor4", w("Color4", Color3.fromRGB(0, 0, 0), 0));
		i.WidgetConstructor("SliderNum", x("Num", 1, 0));
		i.WidgetConstructor("SliderVector2", x("Vector2", 2, Vector2.zero));
		i.WidgetConstructor("SliderVector3", x("Vector3", 3, Vector3.zero));
		i.WidgetConstructor("SliderUDim", x("UDim", 2, UDim.new()));
		i.WidgetConstructor("SliderUDim2", x("UDim2", 4, UDim2.new()));
		i.WidgetConstructor("SliderRect", x("Rect", 4, Rect.new(0, 0, 0, 0)));
		i.WidgetConstructor("InputText", {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				TextHint = 2,
				ReadOnly = 3,
				MultiLine = 4
			},
			Events = {
				textChanged = {
					Init = function(z)
						z.lastTextChangedTick = 0;
					end,
					Get = function(z)
						return z.lastTextChangedTick == i._cycleTick;
					end
				},
				hovered = j.EVENTS.hover(function(z)
					return z.Instance;
				end)
			},
			Generate = function(z)
				local A = Instance.new("Frame");
				A.Name = "Iris_InputText";
				A.AutomaticSize = Enum.AutomaticSize.Y;
				A.Size = UDim2.fromScale(1, 0);
				A.BackgroundTransparency = 1;
				A.BorderSizePixel = 0;
				A.ZIndex = z.ZIndex;
				A.LayoutOrder = z.ZIndex;
				local B = j.UIListLayout(A, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X));
				B.VerticalAlignment = Enum.VerticalAlignment.Center;
				local C = Instance.new("TextBox");
				C.Name = "InputField";
				C.Size = UDim2.new(i._config.ContentWidth, i._config.ContentHeight);
				C.AutomaticSize = Enum.AutomaticSize.Y;
				C.BackgroundColor3 = i._config.FrameBgColor;
				C.BackgroundTransparency = i._config.FrameBgTransparency;
				C.Text = "";
				C.TextYAlignment = Enum.TextYAlignment.Top;
				C.PlaceholderColor3 = i._config.TextDisabledColor;
				C.ClearTextOnFocus = false;
				C.ClipsDescendants = true;
				j.applyFrameStyle(C);
				j.applyTextStyle(C);
				j.UISizeConstraint(C, Vector2.xAxis);
				C.Parent = A;
				C.FocusLost:Connect(function()
					z.state.text:set(C.Text);
					z.lastTextChangedTick = i._cycleTick + 1;
				end);
				local D = i._config.TextSize + 2 * i._config.FramePadding.Y;
				local E = Instance.new("TextLabel");
				E.Name = "TextLabel";
				E.Size = UDim2.fromOffset(0, D);
				E.AutomaticSize = Enum.AutomaticSize.X;
				E.BackgroundTransparency = 1;
				E.BorderSizePixel = 0;
				E.LayoutOrder = 1;
				j.applyTextStyle(E);
				E.Parent = A;
				return A;
			end,
			Update = function(z)
				local A = z.Instance;
				local B = A.TextLabel;
				local C = A.InputField;
				B.Text = z.arguments.Text or "Input Text";
				C.PlaceholderText = z.arguments.TextHint or "";
				C.TextEditable = not z.arguments.ReadOnly;
				C.MultiLine = z.arguments.MultiLine or false;
			end,
			Discard = function(z)
				z.Instance:Destroy();
				j.discardState(z);
			end,
			GenerateState = function(z)
				if z.state.text == nil then
					z.state.text = i._widgetState(z, "text", "");
				end;
			end,
			UpdateState = function(z)
				local A = z.Instance;
				local B = A.InputField;
				B.Text = z.state.text.value;
			end
		});
	end;
end);
c("widgets/Tab", function(e, f, g, h)
	return function(i, j)
		local k = function(k, l)
			if k.state.index.value > 0 then
				return;
			end;
			k.state.index:set(l);
		end;
		local l = function(l, o)
			if l.state.index.value ~= o then
				return;
			end;
			for p = o - 1, 1, -1 do
				if l.Tabs[p].state.isOpened.value == true then
					l.state.index:set(p);
					return;
				end;
			end;
			for p = o, #l.Tabs do
				if l.Tabs[p].state.isOpened.value == true then
					l.state.index:set(p);
					return;
				end;
			end;
			l.state.index:set(0);
		end;
		i.WidgetConstructor("TabBar", {
			hasState = true,
			hasChildren = true,
			Args = {},
			Events = {},
			Generate = function(o)
				local p = Instance.new("Frame");
				p.Name = "Iris_TabBar";
				p.AutomaticSize = Enum.AutomaticSize.Y;
				p.Size = UDim2.fromScale(1, 0);
				p.BackgroundTransparency = 1;
				p.BorderSizePixel = 0;
				p.LayoutOrder = o.ZIndex;
				(j.UIListLayout(p, Enum.FillDirection.Vertical, UDim.new())).VerticalAlignment = Enum.VerticalAlignment.Bottom;
				local q = Instance.new("Frame");
				q.Name = "Bar";
				q.AutomaticSize = Enum.AutomaticSize.Y;
				q.Size = UDim2.fromScale(1, 0);
				q.BackgroundTransparency = 1;
				q.BorderSizePixel = 0;
				j.UIListLayout(q, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X));
				q.Parent = p;
				local r = Instance.new("Frame");
				r.Name = "Underline";
				r.Size = UDim2.new(1, 0, 0, 1);
				r.BackgroundColor3 = i._config.TabActiveColor;
				r.BackgroundTransparency = i._config.TabActiveTransparency;
				r.BorderSizePixel = 0;
				r.LayoutOrder = 1;
				r.Parent = p;
				local s = Instance.new("Frame");
				s.Name = "TabContainer";
				s.AutomaticSize = Enum.AutomaticSize.Y;
				s.Size = UDim2.fromScale(1, 0);
				s.BackgroundTransparency = 1;
				s.BorderSizePixel = 0;
				s.LayoutOrder = 2;
				s.ClipsDescendants = true;
				s.Parent = p;
				o.ChildContainer = s;
				o.Tabs = {};
				return p;
			end,
			Update = function(o)
			end,
			ChildAdded = function(o, p)
				local q = p.type == "Tab";
				local r = o.Instance;
				p.ChildContainer.Parent = o.ChildContainer;
				p.Index = (#o.Tabs) + 1;
				o.state.index.ConnectedWidgets[p.ID] = p;
				table.insert(o.Tabs, p);
				return r.Bar;
			end,
			ChildDiscarded = function(o, p)
				local q = p.Index;
				table.remove(o.Tabs, q);
				for r = q, #o.Tabs do
					o.Tabs[r].Index = r;
				end;
				l(o, q);
			end,
			GenerateState = function(o)
				if o.state.index == nil then
					o.state.index = i._widgetState(o, "index", 1);
				end;
			end,
			UpdateState = function(o)
			end,
			Discard = function(o)
				o.Instance:Destroy();
			end
		});
		i.WidgetConstructor("Tab", {
			hasState = true,
			hasChildren = true,
			Args = {
				Text = 1,
				Hideable = 2
			},
			Events = {
				clicked = j.EVENTS.click(function(o)
					return o.Instance;
				end),
				hovered = j.EVENTS.hover(function(o)
					return o.Instance;
				end),
				selected = {
					Init = function(o)
					end,
					Get = function(o)
						return o.lastSelectedTick == i._cycleTick;
					end
				},
				unselected = {
					Init = function(o)
					end,
					Get = function(o)
						return o.lastUnselectedTick == i._cycleTick;
					end
				},
				active = {
					Init = function(o)
					end,
					Get = function(o)
						return o.state.index.value == o.Index;
					end
				},
				opened = {
					Init = function(o)
					end,
					Get = function(o)
						return o.lastOpenedTick == i._cycleTick;
					end
				},
				closed = {
					Init = function(o)
					end,
					Get = function(o)
						return o.lastClosedTick == i._cycleTick;
					end
				}
			},
			Generate = function(o)
				local p = Instance.new("TextButton");
				p.Name = "Iris_Tab";
				p.AutomaticSize = Enum.AutomaticSize.XY;
				p.BackgroundColor3 = i._config.TabColor;
				p.BackgroundTransparency = i._config.TabTransparency;
				p.BorderSizePixel = 0;
				p.Text = "";
				p.AutoButtonColor = false;
				o.ButtonColors = {
					Color = i._config.TabColor,
					Transparency = i._config.TabTransparency,
					HoveredColor = i._config.TabHoveredColor,
					HoveredTransparency = i._config.TabHoveredTransparency,
					ActiveColor = i._config.TabActiveColor,
					ActiveTransparency = i._config.TabActiveTransparency
				};
				j.UIPadding(p, Vector2.new(i._config.FramePadding.X, 0));
				j.applyFrameStyle(p, true, true);
				(j.UIListLayout(p, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X))).VerticalAlignment = Enum.VerticalAlignment.Center;
				j.applyInteractionHighlights("Background", p, p, o.ButtonColors);
				j.applyButtonClick(p, function()
					o.state.index:set(o.Index);
				end);
				local q = Instance.new("TextLabel");
				q.Name = "TextLabel";
				q.AutomaticSize = Enum.AutomaticSize.XY;
				q.BackgroundTransparency = 1;
				q.BorderSizePixel = 0;
				j.applyTextStyle(q);
				j.UIPadding(q, Vector2.new(0, i._config.FramePadding.Y));
				q.Parent = p;
				local r = i._config.TextSize + (i._config.FramePadding.Y - 1) * 2;
				local s = Instance.new("TextButton");
				s.Name = "CloseButton";
				s.BackgroundTransparency = 1;
				s.BorderSizePixel = 0;
				s.LayoutOrder = 1;
				s.Size = UDim2.fromOffset(r, r);
				s.Text = "";
				s.AutoButtonColor = false;
				j.UICorner(s);
				j.applyButtonClick(s, function()
					o.state.isOpened:set(false);
					l(o.parentWidget, o.Index);
				end);
				j.applyInteractionHighlights("Background", s, s, {
					Color = i._config.TabColor,
					Transparency = 1,
					HoveredColor = i._config.ButtonHoveredColor,
					HoveredTransparency = i._config.ButtonHoveredTransparency,
					ActiveColor = i._config.ButtonActiveColor,
					ActiveTransparency = i._config.ButtonActiveTransparency
				});
				s.Parent = p;
				local t = Instance.new("ImageLabel");
				t.Name = "Icon";
				t.AnchorPoint = Vector2.new(0.5, 0.5);
				t.BackgroundTransparency = 1;
				t.BorderSizePixel = 0;
				t.Image = j.ICONS.MULTIPLICATION_SIGN;
				t.ImageTransparency = 1;
				t.Position = UDim2.fromScale(0.5, 0.5);
				t.Size = UDim2.fromOffset(math.floor(0.7 * r), math.floor(0.7 * r));
				j.applyInteractionHighlights("Image", p, t, {
					Color = i._config.TextColor,
					Transparency = 1,
					HoveredColor = i._config.TextColor,
					HoveredTransparency = i._config.TextTransparency,
					ActiveColor = i._config.TextColor,
					ActiveTransparency = i._config.TextTransparency
				});
				t.Parent = s;
				local u = Instance.new("Frame");
				u.Name = "TabContainer";
				u.AutomaticSize = Enum.AutomaticSize.Y;
				u.Size = UDim2.fromScale(1, 0);
				u.BackgroundTransparency = 1;
				u.BorderSizePixel = 0;
				u.ClipsDescendants = true;
				j.UIListLayout(u, Enum.FillDirection.Vertical, UDim.new(0, i._config.ItemSpacing.Y));
				(j.UIPadding(u, Vector2.new(0, i._config.ItemSpacing.Y))).PaddingBottom = UDim.new();
				o.ChildContainer = u;
				return p;
			end,
			Update = function(o)
				local p = o.Instance;
				local q = p.TextLabel;
				local r = p.CloseButton;
				q.Text = o.arguments.Text;
				r.Visible = o.arguments.Hideable == true and true or false;
			end,
			ChildAdded = function(o, p)
				return o.ChildContainer;
			end,
			GenerateState = function(o)
				o.state.index = o.parentWidget.state.index;
				o.state.index.ConnectedWidgets[o.ID] = o;
				if o.state.isOpened == nil then
					o.state.isOpened = i._widgetState(o, "isOpened", true);
				end;
			end,
			UpdateState = function(o)
				local p = o.Instance;
				local q = o.ChildContainer;
				if o.state.isOpened.lastChangeTick == i._cycleTick then
					if o.state.isOpened.value == true then
						o.lastOpenedTick = i._cycleTick + 1;
						k(o.parentWidget, o.Index);
						p.Visible = true;
					else
						o.lastClosedTick = i._cycleTick + 1;
						l(o.parentWidget, o.Index);
						p.Visible = false;
					end;
				end;
				if o.state.index.lastChangeTick == i._cycleTick then
					if o.state.index.value == o.Index then
						o.ButtonColors.Color = i._config.TabActiveColor;
						o.ButtonColors.Transparency = i._config.TabActiveTransparency;
						p.BackgroundColor3 = i._config.TabActiveColor;
						p.BackgroundTransparency = i._config.TabActiveTransparency;
						q.Visible = true;
						o.lastSelectedTick = i._cycleTick + 1;
					else
						o.ButtonColors.Color = i._config.TabColor;
						o.ButtonColors.Transparency = i._config.TabTransparency;
						p.BackgroundColor3 = i._config.TabColor;
						p.BackgroundTransparency = i._config.TabTransparency;
						q.Visible = false;
						o.lastUnselectedTick = i._cycleTick + 1;
					end;
				end;
			end,
			Discard = function(o)
				o.Instance:Destroy();
			end
		});
	end;
end);
c("widgets/Tree", function(e, f, g, h)
	return function(i, j)
		local k = {
			hasState = true,
			hasChildren = true,
			Events = {
				collapsed = {
					Init = function(k)
					end,
					Get = function(k)
						return k.lastCollapsedTick == i._cycleTick;
					end
				},
				uncollapsed = {
					Init = function(k)
					end,
					Get = function(k)
						return k.lastUncollapsedTick == i._cycleTick;
					end
				},
				hovered = j.EVENTS.hover(function(k)
					return k.Instance;
				end)
			},
			Discard = function(k)
				k.Instance:Destroy();
				j.discardState(k);
			end,
			ChildAdded = function(k, l)
				local o = k.ChildContainer;
				o.Visible = k.state.isUncollapsed.value;
				return o;
			end,
			UpdateState = function(k)
				local l = k.state.isUncollapsed.value;
				local o = k.Instance;
				local p = k.ChildContainer;
				local q = o.Header;
				local r = q.Button;
				local s = r.Arrow;
				s.Image = l and j.ICONS.DOWN_POINTING_TRIANGLE or j.ICONS.RIGHT_POINTING_TRIANGLE;
				if l then
					k.lastUncollapsedTick = i._cycleTick + 1;
				else
					k.lastCollapsedTick = i._cycleTick + 1;
				end;
				p.Visible = l;
			end,
			GenerateState = function(k)
				if k.state.isUncollapsed == nil then
					k.state.isUncollapsed = i._widgetState(k, "isUncollapsed", false);
				end;
			end
		};
		i.WidgetConstructor("Tree", j.extend(k, {
			Args = {
				Text = 1,
				SpanAvailWidth = 2,
				NoIndent = 3
			},
			Generate = function(l)
				local o = Instance.new("Frame");
				o.Name = "Iris_Tree";
				o.Size = UDim2.new(i._config.ItemWidth, UDim.new(0, 0));
				o.AutomaticSize = Enum.AutomaticSize.Y;
				o.BackgroundTransparency = 1;
				o.BorderSizePixel = 0;
				o.LayoutOrder = l.ZIndex;
				j.UIListLayout(o, Enum.FillDirection.Vertical, UDim.new(0, 0));
				local p = Instance.new("Frame");
				p.Name = "TreeContainer";
				p.Size = UDim2.fromScale(1, 0);
				p.AutomaticSize = Enum.AutomaticSize.Y;
				p.BackgroundTransparency = 1;
				p.BorderSizePixel = 0;
				p.LayoutOrder = 1;
				p.Visible = false;
				j.UIListLayout(p, Enum.FillDirection.Vertical, UDim.new(0, i._config.ItemSpacing.Y));
				local q = j.UIPadding(p, Vector2.zero);
				q.PaddingTop = UDim.new(0, i._config.ItemSpacing.Y);
				p.Parent = o;
				local r = Instance.new("Frame");
				r.Name = "Header";
				r.Size = UDim2.fromScale(1, 0);
				r.AutomaticSize = Enum.AutomaticSize.Y;
				r.BackgroundTransparency = 1;
				r.BorderSizePixel = 0;
				r.Parent = o;
				local s = Instance.new("TextButton");
				s.Name = "Button";
				s.BackgroundTransparency = 1;
				s.BorderSizePixel = 0;
				s.Text = "";
				s.AutoButtonColor = false;
				j.applyInteractionHighlights("Background", s, r, {
					Color = Color3.fromRGB(0, 0, 0),
					Transparency = 1,
					HoveredColor = i._config.HeaderHoveredColor,
					HoveredTransparency = i._config.HeaderHoveredTransparency,
					ActiveColor = i._config.HeaderActiveColor,
					ActiveTransparency = i._config.HeaderActiveTransparency
				});
				local t = j.UIPadding(s, Vector2.zero);
				t.PaddingLeft = UDim.new(0, i._config.FramePadding.X);
				local u = j.UIListLayout(s, Enum.FillDirection.Horizontal, UDim.new(0, i._config.FramePadding.X));
				u.VerticalAlignment = Enum.VerticalAlignment.Center;
				s.Parent = r;
				local v = Instance.new("ImageLabel");
				v.Name = "Arrow";
				v.Size = UDim2.fromOffset(i._config.TextSize, math.floor(i._config.TextSize * 0.7));
				v.BackgroundTransparency = 1;
				v.BorderSizePixel = 0;
				v.ImageColor3 = i._config.TextColor;
				v.ImageTransparency = i._config.TextTransparency;
				v.ScaleType = Enum.ScaleType.Fit;
				v.Parent = s;
				local w = Instance.new("TextLabel");
				w.Name = "TextLabel";
				w.Size = UDim2.fromOffset(0, 0);
				w.AutomaticSize = Enum.AutomaticSize.XY;
				w.BackgroundTransparency = 1;
				w.BorderSizePixel = 0;
				local x = j.UIPadding(w, Vector2.zero);
				x.PaddingRight = UDim.new(0, 21);
				j.applyTextStyle(w);
				w.Parent = s;
				j.applyButtonClick(s, function()
					l.state.isUncollapsed:set(not l.state.isUncollapsed.value);
				end);
				l.ChildContainer = p;
				return o;
			end,
			Update = function(l)
				local o = l.Instance;
				local p = l.ChildContainer;
				local q = o.Header;
				local r = q.Button;
				local s = r.TextLabel;
				local t = p.UIPadding;
				s.Text = l.arguments.Text or "Tree";
				if l.arguments.SpanAvailWidth then
					r.AutomaticSize = Enum.AutomaticSize.Y;
					r.Size = UDim2.fromScale(1, 0);
				else
					r.AutomaticSize = Enum.AutomaticSize.XY;
					r.Size = UDim2.fromScale(0, 0);
				end;
				if l.arguments.NoIndent then
					t.PaddingLeft = UDim.new(0, 0);
				else
					t.PaddingLeft = UDim.new(0, i._config.IndentSpacing);
				end;
			end
		}));
		i.WidgetConstructor("CollapsingHeader", j.extend(k, {
			Args = {
				Text = 1
			},
			Generate = function(l)
				local o = Instance.new("Frame");
				o.Name = "Iris_CollapsingHeader";
				o.Size = UDim2.new(i._config.ItemWidth, UDim.new(0, 0));
				o.AutomaticSize = Enum.AutomaticSize.Y;
				o.BackgroundTransparency = 1;
				o.BorderSizePixel = 0;
				o.LayoutOrder = l.ZIndex;
				j.UIListLayout(o, Enum.FillDirection.Vertical, UDim.new(0, 0));
				local p = Instance.new("Frame");
				p.Name = "CollapsingHeaderContainer";
				p.Size = UDim2.fromScale(1, 0);
				p.AutomaticSize = Enum.AutomaticSize.Y;
				p.BackgroundTransparency = 1;
				p.BorderSizePixel = 0;
				p.LayoutOrder = 1;
				p.Visible = false;
				j.UIListLayout(p, Enum.FillDirection.Vertical, UDim.new(0, i._config.ItemSpacing.Y));
				local q = j.UIPadding(p, Vector2.zero);
				q.PaddingTop = UDim.new(0, i._config.ItemSpacing.Y);
				p.Parent = o;
				local r = Instance.new("Frame");
				r.Name = "Header";
				r.Size = UDim2.fromScale(1, 0);
				r.AutomaticSize = Enum.AutomaticSize.Y;
				r.BackgroundTransparency = 1;
				r.BorderSizePixel = 0;
				r.Parent = o;
				local s = Instance.new("TextButton");
				s.Name = "Button";
				s.Size = UDim2.new(1, 0, 0, 0);
				s.AutomaticSize = Enum.AutomaticSize.Y;
				s.BackgroundColor3 = i._config.HeaderColor;
				s.BackgroundTransparency = i._config.HeaderTransparency;
				s.BorderSizePixel = 0;
				s.Text = "";
				s.AutoButtonColor = false;
				s.ClipsDescendants = true;
				j.UIPadding(s, i._config.FramePadding);
				j.applyFrameStyle(s, true);
				local t = j.UIListLayout(s, Enum.FillDirection.Horizontal, UDim.new(0, 2 * i._config.FramePadding.X));
				t.VerticalAlignment = Enum.VerticalAlignment.Center;
				j.applyInteractionHighlights("Background", s, s, {
					Color = i._config.HeaderColor,
					Transparency = i._config.HeaderTransparency,
					HoveredColor = i._config.HeaderHoveredColor,
					HoveredTransparency = i._config.HeaderHoveredTransparency,
					ActiveColor = i._config.HeaderActiveColor,
					ActiveTransparency = i._config.HeaderActiveTransparency
				});
				s.Parent = r;
				local u = Instance.new("ImageLabel");
				u.Name = "Arrow";
				u.Size = UDim2.fromOffset(i._config.TextSize, math.ceil(i._config.TextSize * 0.8));
				u.AutomaticSize = Enum.AutomaticSize.Y;
				u.BackgroundTransparency = 1;
				u.BorderSizePixel = 0;
				u.ImageColor3 = i._config.TextColor;
				u.ImageTransparency = i._config.TextTransparency;
				u.ScaleType = Enum.ScaleType.Fit;
				u.Parent = s;
				local v = Instance.new("TextLabel");
				v.Name = "TextLabel";
				v.Size = UDim2.fromOffset(0, 0);
				v.AutomaticSize = Enum.AutomaticSize.XY;
				v.BackgroundTransparency = 1;
				v.BorderSizePixel = 0;
				local w = j.UIPadding(v, Vector2.zero);
				w.PaddingRight = UDim.new(0, 21);
				j.applyTextStyle(v);
				v.Parent = s;
				j.applyButtonClick(s, function()
					l.state.isUncollapsed:set(not l.state.isUncollapsed.value);
				end);
				l.ChildContainer = p;
				return o;
			end,
			Update = function(l)
				local o = l.Instance;
				local p = o.Header;
				local q = p.Button;
				local r = q.TextLabel;
				r.Text = l.arguments.Text or "Collapsing Header";
			end
		}));
	end;
end);
c("widgets/Image", function(e, f, g, h)
	return function(i, j)
		local k = {
			hasState = false,
			hasChildren = false,
			Args = {
				Image = 1,
				Size = 2,
				Rect = 3,
				ScaleType = 4,
				ResampleMode = 5,
				TileSize = 6,
				SliceCenter = 7,
				SliceScale = 8
			},
			Discard = function(k)
				k.Instance:Destroy();
			end
		};
		i.WidgetConstructor("Image", j.extend(k, {
			Events = {
				hovered = j.EVENTS.hover(function(l)
					return l.Instance;
				end)
			},
			Generate = function(l)
				local o = Instance.new("ImageLabel");
				o.Name = "Iris_Image";
				o.BackgroundTransparency = 1;
				o.BorderSizePixel = 0;
				o.ImageColor3 = i._config.ImageColor;
				o.ImageTransparency = i._config.ImageTransparency;
				o.LayoutOrder = l.ZIndex;
				j.applyFrameStyle(o, true);
				return o;
			end,
			Update = function(l)
				local o = l.Instance;
				o.Image = l.arguments.Image or j.ICONS.UNKNOWN_TEXTURE;
				o.Size = l.arguments.Size;
				if l.arguments.ScaleType then
					o.ScaleType = l.arguments.ScaleType;
					if l.arguments.ScaleType == Enum.ScaleType.Tile and l.arguments.TileSize then
						o.TileSize = l.arguments.TileSize;
					elseif l.arguments.ScaleType == Enum.ScaleType.Slice then
						if l.arguments.SliceCenter then
							o.SliceCenter = l.arguments.SliceCenter;
						end;
						if l.arguments.SliceScale then
							o.SliceScale = l.arguments.SliceScale;
						end;
					end;
				end;
				if l.arguments.Rect then
					o.ImageRectOffset = l.arguments.Rect.Min;
					o.ImageRectSize = Vector2.new(l.arguments.Rect.Width, l.arguments.Rect.Height);
				end;
				if l.arguments.ResampleMode then
					o.ResampleMode = l.arguments.ResampleMode;
				end;
			end
		}));
		i.WidgetConstructor("ImageButton", j.extend(k, {
			Events = {
				clicked = j.EVENTS.click(function(l)
					return l.Instance;
				end),
				rightClicked = j.EVENTS.rightClick(function(l)
					return l.Instance;
				end),
				doubleClicked = j.EVENTS.doubleClick(function(l)
					return l.Instance;
				end),
				ctrlClicked = j.EVENTS.ctrlClick(function(l)
					return l.Instance;
				end),
				hovered = j.EVENTS.hover(function(l)
					return l.Instance;
				end)
			},
			Generate = function(l)
				local o = Instance.new("ImageButton");
				o.Name = "Iris_ImageButton";
				o.AutomaticSize = Enum.AutomaticSize.XY;
				o.BackgroundColor3 = i._config.FrameBgColor;
				o.BackgroundTransparency = i._config.FrameBgTransparency;
				o.BorderSizePixel = 0;
				o.Image = "";
				o.ImageTransparency = 1;
				o.LayoutOrder = l.ZIndex;
				o.AutoButtonColor = false;
				j.applyFrameStyle(o, true);
				j.UIPadding(o, Vector2.new(i._config.ImageBorderSize, i._config.ImageBorderSize));
				local p = Instance.new("ImageLabel");
				p.Name = "ImageLabel";
				p.BackgroundTransparency = 1;
				p.BorderSizePixel = 0;
				p.ImageColor3 = i._config.ImageColor;
				p.ImageTransparency = i._config.ImageTransparency;
				p.Parent = o;
				j.applyInteractionHighlights("Background", o, o, {
					Color = i._config.FrameBgColor,
					Transparency = i._config.FrameBgTransparency,
					HoveredColor = i._config.FrameBgHoveredColor,
					HoveredTransparency = i._config.FrameBgHoveredTransparency,
					ActiveColor = i._config.FrameBgActiveColor,
					ActiveTransparency = i._config.FrameBgActiveTransparency
				});
				return o;
			end,
			Update = function(l)
				local o = l.Instance;
				local p = o.ImageLabel;
				p.Image = l.arguments.Image or j.ICONS.UNKNOWN_TEXTURE;
				p.Size = l.arguments.Size;
				if l.arguments.ScaleType then
					p.ScaleType = l.arguments.ScaleType;
					if l.arguments.ScaleType == Enum.ScaleType.Tile and l.arguments.TileSize then
						p.TileSize = l.arguments.TileSize;
					elseif l.arguments.ScaleType == Enum.ScaleType.Slice then
						if l.arguments.SliceCenter then
							p.SliceCenter = l.arguments.SliceCenter;
						end;
						if l.arguments.SliceScale then
							p.SliceScale = l.arguments.SliceScale;
						end;
					end;
				end;
				if l.arguments.Rect then
					p.ImageRectOffset = l.arguments.Rect.Min;
					p.ImageRectSize = Vector2.new(l.arguments.Rect.Width, l.arguments.Rect.Height);
				end;
				if l.arguments.ResampleMode then
					p.ResampleMode = l.arguments.ResampleMode;
				end;
			end
		}));
	end;
end);
c("widgets/RadioButton", function(e, f, g, h)
	return function(i, j)
		i.WidgetConstructor("RadioButton", {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				Index = 2
			},
			Events = {
				selected = {
					Init = function(k)
					end,
					Get = function(k)
						return k.lastSelectedTick == i._cycleTick;
					end
				},
				unselected = {
					Init = function(k)
					end,
					Get = function(k)
						return k.lastUnselectedTick == i._cycleTick;
					end
				},
				active = {
					Init = function(k)
					end,
					Get = function(k)
						return k.state.index.value == k.arguments.Index;
					end
				},
				hovered = j.EVENTS.hover(function(k)
					return k.Instance;
				end)
			},
			Generate = function(k)
				local l = Instance.new("TextButton");
				l.Name = "Iris_RadioButton";
				l.AutomaticSize = Enum.AutomaticSize.XY;
				l.Size = UDim2.fromOffset(0, 0);
				l.BackgroundTransparency = 1;
				l.BorderSizePixel = 0;
				l.Text = "";
				l.LayoutOrder = k.ZIndex;
				l.AutoButtonColor = false;
				l.ZIndex = k.ZIndex;
				l.LayoutOrder = k.ZIndex;
				local o = j.UIListLayout(l, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X));
				o.VerticalAlignment = Enum.VerticalAlignment.Center;
				local p = i._config.TextSize + 2 * (i._config.FramePadding.Y - 1);
				local q = Instance.new("Frame");
				q.Name = "Button";
				q.Size = UDim2.fromOffset(p, p);
				q.Parent = l;
				q.BackgroundColor3 = i._config.FrameBgColor;
				q.BackgroundTransparency = i._config.FrameBgTransparency;
				j.UICorner(q);
				j.UIPadding(q, Vector2.new(math.max(1, math.floor(p / 5)), math.max(1, math.floor(p / 5))));
				local r = Instance.new("Frame");
				r.Name = "Circle";
				r.Size = UDim2.fromScale(1, 1);
				r.Parent = q;
				r.BackgroundColor3 = i._config.CheckMarkColor;
				r.BackgroundTransparency = i._config.CheckMarkTransparency;
				j.UICorner(r);
				j.applyInteractionHighlights("Background", l, q, {
					Color = i._config.FrameBgColor,
					Transparency = i._config.FrameBgTransparency,
					HoveredColor = i._config.FrameBgHoveredColor,
					HoveredTransparency = i._config.FrameBgHoveredTransparency,
					ActiveColor = i._config.FrameBgActiveColor,
					ActiveTransparency = i._config.FrameBgActiveTransparency
				});
				j.applyButtonClick(l, function()
					k.state.index:set(k.arguments.Index);
				end);
				local s = Instance.new("TextLabel");
				s.Name = "TextLabel";
				s.AutomaticSize = Enum.AutomaticSize.XY;
				s.BackgroundTransparency = 1;
				s.BorderSizePixel = 0;
				s.LayoutOrder = 1;
				j.applyTextStyle(s);
				s.Parent = l;
				return l;
			end,
			Update = function(k)
				local l = k.Instance;
				local o = l.TextLabel;
				o.Text = k.arguments.Text or "Radio Button";
				if k.state then
					k.state.index.lastChangeTick = i._cycleTick;
					i._widgets[k.type].UpdateState(k);
				end;
			end,
			Discard = function(k)
				k.Instance:Destroy();
				j.discardState(k);
			end,
			GenerateState = function(k)
				if k.state.index == nil then
					k.state.index = i._widgetState(k, "index", k.arguments.Index);
				end;
			end,
			UpdateState = function(k)
				local l = k.Instance;
				local o = l.Button;
				local p = o.Circle;
				if k.state.index.value == k.arguments.Index then
					p.BackgroundTransparency = i._config.CheckMarkTransparency;
					k.lastSelectedTick = i._cycleTick + 1;
				else
					p.BackgroundTransparency = 1;
					k.lastUnselectedTick = i._cycleTick + 1;
				end;
			end
		});
	end;
end);
c("widgets/Checkbox", function(e, f, g, h)
	return function(i, j)
		i.WidgetConstructor("Checkbox", {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1
			},
			Events = {
				checked = {
					Init = function(k)
					end,
					Get = function(k)
						return k.lastCheckedTick == i._cycleTick;
					end
				},
				unchecked = {
					Init = function(k)
					end,
					Get = function(k)
						return k.lastUncheckedTick == i._cycleTick;
					end
				},
				hovered = j.EVENTS.hover(function(k)
					return k.Instance;
				end)
			},
			Generate = function(k)
				local l = Instance.new("TextButton");
				l.Name = "Iris_Checkbox";
				l.AutomaticSize = Enum.AutomaticSize.XY;
				l.Size = UDim2.fromOffset(0, 0);
				l.BackgroundTransparency = 1;
				l.BorderSizePixel = 0;
				l.Text = "";
				l.AutoButtonColor = false;
				l.ZIndex = k.ZIndex;
				l.LayoutOrder = k.ZIndex;
				local o = j.UIListLayout(l, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X));
				o.VerticalAlignment = Enum.VerticalAlignment.Center;
				local p = i._config.TextSize + 2 * i._config.FramePadding.Y;
				local q = Instance.new("Frame");
				q.Name = "Box";
				q.Size = UDim2.fromOffset(p, p);
				q.BackgroundColor3 = i._config.FrameBgColor;
				q.BackgroundTransparency = i._config.FrameBgTransparency;
				j.applyFrameStyle(q, true);
				j.UIPadding(q, Vector2.new(math.floor(p / 10), math.floor(p / 10)));
				j.applyInteractionHighlights("Background", l, q, {
					Color = i._config.FrameBgColor,
					Transparency = i._config.FrameBgTransparency,
					HoveredColor = i._config.FrameBgHoveredColor,
					HoveredTransparency = i._config.FrameBgHoveredTransparency,
					ActiveColor = i._config.FrameBgActiveColor,
					ActiveTransparency = i._config.FrameBgActiveTransparency
				});
				q.Parent = l;
				local r = Instance.new("ImageLabel");
				r.Name = "Checkmark";
				r.Size = UDim2.fromScale(1, 1);
				r.BackgroundTransparency = 1;
				r.ImageColor3 = i._config.CheckMarkColor;
				r.ImageTransparency = i._config.CheckMarkTransparency;
				r.ScaleType = Enum.ScaleType.Fit;
				r.Parent = q;
				j.applyButtonClick(l, function()
					local s = k.state.isChecked.value;
					k.state.isChecked:set(not s);
				end);
				local s = Instance.new("TextLabel");
				s.Name = "TextLabel";
				s.AutomaticSize = Enum.AutomaticSize.XY;
				s.BackgroundTransparency = 1;
				s.BorderSizePixel = 0;
				s.LayoutOrder = 1;
				j.applyTextStyle(s);
				s.Parent = l;
				return l;
			end,
			Update = function(k)
				local l = k.Instance;
				l.TextLabel.Text = k.arguments.Text or "Checkbox";
			end,
			Discard = function(k)
				k.Instance:Destroy();
				j.discardState(k);
			end,
			GenerateState = function(k)
				if k.state.isChecked == nil then
					k.state.isChecked = i._widgetState(k, "checked", false);
				end;
			end,
			UpdateState = function(k)
				local l = k.Instance;
				local o = l.Box;
				local p = o.Checkmark;
				if k.state.isChecked.value then
					p.Image = j.ICONS.CHECK_MARK;
					k.lastCheckedTick = i._cycleTick + 1;
				else
					p.Image = "";
					k.lastUncheckedTick = i._cycleTick + 1;
				end;
			end
		});
	end;
end);
c("widgets/Button", function(e, f, g, h)
	return function(i, j)
		local k = {
			hasState = false,
			hasChildren = false,
			Args = {
				Text = 1,
				Size = 2
			},
			Events = {
				clicked = j.EVENTS.click(function(k)
					return k.Instance;
				end),
				rightClicked = j.EVENTS.rightClick(function(k)
					return k.Instance;
				end),
				doubleClicked = j.EVENTS.doubleClick(function(k)
					return k.Instance;
				end),
				ctrlClicked = j.EVENTS.ctrlClick(function(k)
					return k.Instance;
				end),
				hovered = j.EVENTS.hover(function(k)
					return k.Instance;
				end)
			},
			Generate = function(k)
				local l = Instance.new("TextButton");
				l.Size = UDim2.fromOffset(0, 0);
				l.BackgroundColor3 = i._config.ButtonColor;
				l.BackgroundTransparency = i._config.ButtonTransparency;
				l.AutoButtonColor = false;
				l.AutomaticSize = Enum.AutomaticSize.XY;
				j.applyTextStyle(l);
				l.TextXAlignment = Enum.TextXAlignment.Center;
				j.applyFrameStyle(l);
				j.applyInteractionHighlights("Background", l, l, {
					Color = i._config.ButtonColor,
					Transparency = i._config.ButtonTransparency,
					HoveredColor = i._config.ButtonHoveredColor,
					HoveredTransparency = i._config.ButtonHoveredTransparency,
					ActiveColor = i._config.ButtonActiveColor,
					ActiveTransparency = i._config.ButtonActiveTransparency
				});
				l.ZIndex = k.ZIndex;
				l.LayoutOrder = k.ZIndex;
				return l;
			end,
			Update = function(k)
				local l = k.Instance;
				l.Text = k.arguments.Text or "Button";
				l.Size = k.arguments.Size or UDim2.fromOffset(0, 0);
			end,
			Discard = function(k)
				k.Instance:Destroy();
			end
		};
		j.abstractButton = k;
		i.WidgetConstructor("Button", j.extend(k, {
			Generate = function(l)
				local o = k.Generate(l);
				o.Name = "Iris_Button";
				return o;
			end
		}));
		i.WidgetConstructor("SmallButton", j.extend(k, {
			Generate = function(l)
				local o = k.Generate(l);
				o.Name = "Iris_SmallButton";
				local p = o.UIPadding;
				p.PaddingLeft = UDim.new(0, 2);
				p.PaddingRight = UDim.new(0, 2);
				p.PaddingTop = UDim.new(0, 0);
				p.PaddingBottom = UDim.new(0, 0);
				return o;
			end
		}));
	end;
end);
c("widgets/Text", function(e, f, g, h)
	return function(i, j)
		i.WidgetConstructor("Text", {
			hasState = false,
			hasChildren = false,
			Args = {
				Text = 1,
				Wrapped = 2,
				Color = 3,
				RichText = 4
			},
			Events = {
				hovered = j.EVENTS.hover(function(k)
					return k.Instance;
				end)
			},
			Generate = function(k)
				local l = Instance.new("TextLabel");
				l.Name = "Iris_Text";
				l.Size = UDim2.fromOffset(0, 0);
				l.BackgroundTransparency = 1;
				l.BorderSizePixel = 0;
				l.LayoutOrder = k.ZIndex;
				l.AutomaticSize = Enum.AutomaticSize.XY;
				j.applyTextStyle(l);
				j.UIPadding(l, Vector2.new(0, 2));
				return l;
			end,
			Update = function(k)
				local l = k.Instance;
				if k.arguments.Text == nil then
					error("Text argument is required for Iris.Text().", 5);
				end;
				if k.arguments.Wrapped ~= nil then
					l.TextWrapped = k.arguments.Wrapped;
				else
					l.TextWrapped = i._config.TextWrapped;
				end;
				if k.arguments.Color then
					l.TextColor3 = k.arguments.Color;
				else
					l.TextColor3 = i._config.TextColor;
				end;
				if k.arguments.RichText ~= nil then
					l.RichText = k.arguments.RichText;
				else
					l.RichText = i._config.RichText;
				end;
				l.Text = k.arguments.Text;
			end,
			Discard = function(k)
				k.Instance:Destroy();
			end
		});
		i.WidgetConstructor("SeparatorText", {
			hasState = false,
			hasChildren = false,
			Args = {
				Text = 1
			},
			Events = {
				hovered = j.EVENTS.hover(function(k)
					return k.Instance;
				end)
			},
			Generate = function(k)
				local l = Instance.new("Frame");
				l.Name = "Iris_SeparatorText";
				l.Size = UDim2.fromScale(1, 0);
				l.BackgroundTransparency = 1;
				l.BorderSizePixel = 0;
				l.AutomaticSize = Enum.AutomaticSize.Y;
				l.LayoutOrder = k.ZIndex;
				l.ClipsDescendants = true;
				j.UIPadding(l, Vector2.new(0, i._config.SeparatorTextPadding.Y));
				j.UIListLayout(l, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemSpacing.X));
				l.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center;
				local o = Instance.new("TextLabel");
				o.Name = "TextLabel";
				o.BackgroundTransparency = 1;
				o.BorderSizePixel = 0;
				o.AutomaticSize = Enum.AutomaticSize.XY;
				o.LayoutOrder = 1;
				j.applyTextStyle(o);
				o.Parent = l;
				local p = Instance.new("Frame");
				p.Name = "Left";
				p.AnchorPoint = Vector2.new(1, 0.5);
				p.BackgroundColor3 = i._config.SeparatorColor;
				p.BackgroundTransparency = i._config.SeparatorTransparency;
				p.BorderSizePixel = 0;
				p.Size = UDim2.fromOffset(i._config.SeparatorTextPadding.X - i._config.ItemSpacing.X, i._config.SeparatorTextBorderSize);
				p.Parent = l;
				local q = Instance.new("Frame");
				q.Name = "Right";
				q.AnchorPoint = Vector2.new(1, 0.5);
				q.BackgroundColor3 = i._config.SeparatorColor;
				q.BackgroundTransparency = i._config.SeparatorTransparency;
				q.BorderSizePixel = 0;
				q.Size = UDim2.new(1, 0, 0, i._config.SeparatorTextBorderSize);
				q.LayoutOrder = 2;
				q.Parent = l;
				return l;
			end,
			Update = function(k)
				local l = k.Instance;
				local o = l.TextLabel;
				if k.arguments.Text == nil then
					error("Text argument is required for Iris.SeparatorText().", 5);
				end;
				o.Text = k.arguments.Text;
			end,
			Discard = function(k)
				k.Instance:Destroy();
			end
		});
	end;
end);
c("widgets/Format", function(e, f, g, h)
	return function(i, j)
		i.WidgetConstructor("Separator", {
			hasState = false,
			hasChildren = false,
			Args = {},
			Events = {},
			Generate = function(k)
				local l = Instance.new("Frame");
				l.Name = "Iris_Separator";
				l.BackgroundColor3 = i._config.SeparatorColor;
				l.BackgroundTransparency = i._config.SeparatorTransparency;
				l.BorderSizePixel = 0;
				if k.parentWidget.type == "SameLine" then
					l.Size = UDim2.new(0, 1, 1, 0);
				else
					l.Size = UDim2.new(1, 0, 0, 1);
				end;
				l.LayoutOrder = k.ZIndex;
				j.UIListLayout(l, Enum.FillDirection.Vertical, UDim.new(0, 0));
				return l;
			end,
			Update = function(k)
			end,
			Discard = function(k)
				k.Instance:Destroy();
			end
		});
		i.WidgetConstructor("Indent", {
			hasState = false,
			hasChildren = true,
			Args = {
				Width = 1
			},
			Events = {},
			Generate = function(k)
				local l = Instance.new("Frame");
				l.Name = "Iris_Indent";
				l.BackgroundTransparency = 1;
				l.BorderSizePixel = 0;
				l.Size = UDim2.fromScale(1, 0);
				l.AutomaticSize = Enum.AutomaticSize.Y;
				l.LayoutOrder = k.ZIndex;
				j.UIListLayout(l, Enum.FillDirection.Vertical, UDim.new(0, i._config.ItemSpacing.Y));
				j.UIPadding(l, Vector2.zero);
				return l;
			end,
			Update = function(k)
				local l = k.Instance;
				local o;
				if k.arguments.Width then
					o = k.arguments.Width;
				else
					o = i._config.IndentSpacing;
				end;
				l.UIPadding.PaddingLeft = UDim.new(0, o);
			end,
			Discard = function(k)
				k.Instance:Destroy();
			end,
			ChildAdded = function(k, l)
				return k.Instance;
			end
		});
		i.WidgetConstructor("SameLine", {
			hasState = false,
			hasChildren = true,
			Args = {
				Width = 1,
				VerticalAlignment = 2,
				HorizontalAlignment = 3
			},
			Events = {},
			Generate = function(k)
				local l = Instance.new("Frame");
				l.Name = "Iris_SameLine";
				l.BackgroundTransparency = 1;
				l.BorderSizePixel = 0;
				l.Size = UDim2.fromScale(1, 0);
				l.AutomaticSize = Enum.AutomaticSize.Y;
				l.LayoutOrder = k.ZIndex;
				j.UIListLayout(l, Enum.FillDirection.Horizontal, UDim.new(0, 0));
				return l;
			end,
			Update = function(k)
				local l = k.Instance;
				local o = l.UIListLayout;
				local p;
				if k.arguments.Width then
					p = k.arguments.Width;
				else
					p = i._config.ItemSpacing.X;
				end;
				o.Padding = UDim.new(0, p);
				if k.arguments.VerticalAlignment then
					o.VerticalAlignment = k.arguments.VerticalAlignment;
				else
					o.VerticalAlignment = Enum.VerticalAlignment.Top;
				end;
				if k.arguments.HorizontalAlignment then
					o.HorizontalAlignment = k.arguments.HorizontalAlignment;
				else
					o.HorizontalAlignment = Enum.HorizontalAlignment.Left;
				end;
			end,
			Discard = function(k)
				k.Instance:Destroy();
			end,
			ChildAdded = function(k, l)
				return k.Instance;
			end
		});
		i.WidgetConstructor("Group", {
			hasState = false,
			hasChildren = true,
			Args = {},
			Events = {},
			Generate = function(k)
				local l = Instance.new("Frame");
				l.Name = "Iris_Group";
				l.AutomaticSize = Enum.AutomaticSize.XY;
				l.Size = UDim2.fromOffset(0, 0);
				l.BackgroundTransparency = 1;
				l.BorderSizePixel = 0;
				l.LayoutOrder = k.ZIndex;
				l.ClipsDescendants = false;
				j.UIListLayout(l, Enum.FillDirection.Vertical, UDim.new(0, i._config.ItemSpacing.Y));
				return l;
			end,
			Update = function(k)
			end,
			Discard = function(k)
				k.Instance:Destroy();
			end,
			ChildAdded = function(k, l)
				return k.Instance;
			end
		});
	end;
end);
c("widgets/Menu", function(e, f, g, h)
	return function(i, j)
		local k = false;
		local l;
		local o = {};
		local p = function(p)
			for q = #o, p and p + 1 or 1, -1 do
				local r = o[q];
				r.state.isOpened:set(false);
				r.Instance.BackgroundColor3 = i._config.HeaderColor;
				r.Instance.BackgroundTransparency = 1;
				table.remove(o, q);
			end;
			if #o == 0 then
				k = false;
				l = nil;
			end;
		end;
		local q = function(q)
			local r = q.parentWidget.type == "Menu";
			local s = q.Instance;
			local t = q.ChildContainer;
			t.Size = UDim2.fromOffset(s.AbsoluteSize.X, 0);
			if t.Parent == nil then
				return;
			end;
			local u = s.AbsolutePosition - j.GuiOffset;
			local v = s.AbsoluteSize;
			local w = t.AbsoluteSize;
			local x = i._config.PopupBorderSize;
			local y = t.Parent.AbsoluteSize;
			local z = u.X;
			local A;
			local B = Vector2.zero;
			if r then
				if u.X + w.X > y.X then
					B = Vector2.xAxis;
				else
					z = u.X + v.X;
				end;
			end;
			if u.Y + w.Y > y.Y then
				A = u.Y - x + (r and v.Y or 0);
				B = B + Vector2.yAxis;
			else
				A = u.Y + x + (r and 0 or v.Y);
			end;
			t.Position = UDim2.fromOffset(z, A);
			t.AnchorPoint = B;
		end;
		j.registerEvent("InputBegan", function(r)
			if not i._started then
				return;
			end;
			if r.UserInputType ~= Enum.UserInputType.MouseButton1 and r.UserInputType ~= Enum.UserInputType.MouseButton2 then
				return;
			end;
			if k == false then
				return;
			end;
			if l == nil then
				return;
			end;
			local s = false;
			local t = j.getMouseLocation();
			for u, v in o do
				for w, x in {
					v.ChildContainer,
					v.Instance
				} do
					local y = x.AbsolutePosition - j.GuiOffset;
					local z = y + x.AbsoluteSize;
					if j.isPosInsideRect(t, y, z) then
						s = true;
						break;
					end;
				end;
				if s then
					break;
				end;
			end;
			if not s then
				p();
			end;
		end);
		i.WidgetConstructor("MenuBar", {
			hasState = false,
			hasChildren = true,
			Args = {},
			Events = {},
			Generate = function(r)
				local s = Instance.new("Frame");
				s.Name = "Iris_MenuBar";
				s.Size = UDim2.fromScale(1, 0);
				s.AutomaticSize = Enum.AutomaticSize.Y;
				s.BackgroundColor3 = i._config.MenubarBgColor;
				s.BackgroundTransparency = i._config.MenubarBgTransparency;
				s.BorderSizePixel = 0;
				s.LayoutOrder = r.ZIndex;
				s.ClipsDescendants = true;
				j.UIPadding(s, Vector2.new(i._config.WindowPadding.X, 1));
				(j.UIListLayout(s, Enum.FillDirection.Horizontal, UDim.new())).VerticalAlignment = Enum.VerticalAlignment.Center;
				j.applyFrameStyle(s, true, true);
				return s;
			end,
			Update = function(r)
			end,
			ChildAdded = function(r, s)
				return r.Instance;
			end,
			Discard = function(r)
				r.Instance:Destroy();
			end
		});
		i.WidgetConstructor("Menu", {
			hasState = true,
			hasChildren = true,
			Args = {
				Text = 1
			},
			Events = {
				clicked = j.EVENTS.click(function(r)
					return r.Instance;
				end),
				hovered = j.EVENTS.hover(function(r)
					return r.Instance;
				end),
				opened = {
					Init = function(r)
					end,
					Get = function(r)
						return r.lastOpenedTick == i._cycleTick;
					end
				},
				closed = {
					Init = function(r)
					end,
					Get = function(r)
						return r.lastClosedTick == i._cycleTick;
					end
				}
			},
			Generate = function(r)
				local s;
				r.ButtonColors = {
					Color = i._config.HeaderColor,
					Transparency = 1,
					HoveredColor = i._config.HeaderHoveredColor,
					HoveredTransparency = i._config.HeaderHoveredTransparency,
					ActiveColor = i._config.HeaderHoveredColor,
					ActiveTransparency = i._config.HeaderHoveredTransparency
				};
				if r.parentWidget.type == "Menu" then
					s = Instance.new("TextButton");
					s.Name = "Menu";
					s.BackgroundColor3 = i._config.HeaderColor;
					s.BackgroundTransparency = 1;
					s.BorderSizePixel = 0;
					s.Size = UDim2.fromScale(1, 0);
					s.Text = "";
					s.AutomaticSize = Enum.AutomaticSize.Y;
					s.LayoutOrder = r.ZIndex;
					s.AutoButtonColor = false;
					local t = j.UIPadding(s, i._config.FramePadding);
					t.PaddingTop = t.PaddingTop - UDim.new(0, 1);
					(j.UIListLayout(s, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X))).VerticalAlignment = Enum.VerticalAlignment.Center;
					local u = Instance.new("TextLabel");
					u.Name = "TextLabel";
					u.BackgroundTransparency = 1;
					u.BorderSizePixel = 0;
					u.AutomaticSize = Enum.AutomaticSize.XY;
					j.applyTextStyle(u);
					u.Parent = s;
					local v = i._config.TextSize + 2 * i._config.FramePadding.Y;
					local w = math.round(0.2 * v);
					local x = v - 2 * w;
					local y = Instance.new("ImageLabel");
					y.Name = "Icon";
					y.Size = UDim2.fromOffset(x, x);
					y.BackgroundTransparency = 1;
					y.BorderSizePixel = 0;
					y.ImageColor3 = i._config.TextColor;
					y.ImageTransparency = i._config.TextTransparency;
					y.Image = j.ICONS.RIGHT_POINTING_TRIANGLE;
					y.LayoutOrder = 1;
					y.Parent = s;
				else
					s = Instance.new("TextButton");
					s.Name = "Menu";
					s.AutomaticSize = Enum.AutomaticSize.XY;
					s.Size = UDim2.fromScale(0, 0);
					s.BackgroundColor3 = i._config.HeaderColor;
					s.BackgroundTransparency = 1;
					s.BorderSizePixel = 0;
					s.Text = "";
					s.LayoutOrder = r.ZIndex;
					s.AutoButtonColor = false;
					s.ClipsDescendants = true;
					j.applyTextStyle(s);
					j.UIPadding(s, Vector2.new(i._config.ItemSpacing.X, i._config.FramePadding.Y));
				end;
				j.applyInteractionHighlights("Background", s, s, r.ButtonColors);
				j.applyButtonClick(s, function()
					local t = (#o <= 1 and {
						(not r.state.isOpened.value)
					} or {
						true
					})[1];
					r.state.isOpened:set(t);
					k = t;
					l = t and r or nil;
					if #o <= 1 then
						if t then
							table.insert(o, r);
						else
							table.remove(o);
						end;
					end;
				end);
				j.applyMouseEnter(s, function()
					if k and l and l ~= r then
						local t = r.parentWidget;
						local u = table.find(o, t);
						p(u);
						r.state.isOpened:set(true);
						l = r;
						k = true;
						table.insert(o, r);
					end;
				end);
				local t = Instance.new("ScrollingFrame");
				t.Name = "MenuContainer";
				t.BackgroundColor3 = i._config.PopupBgColor;
				t.BackgroundTransparency = i._config.PopupBgTransparency;
				t.BorderSizePixel = 0;
				t.Size = UDim2.fromOffset(0, 0);
				t.AutomaticSize = Enum.AutomaticSize.XY;
				t.AutomaticCanvasSize = Enum.AutomaticSize.Y;
				t.ScrollBarImageTransparency = i._config.ScrollbarGrabTransparency;
				t.ScrollBarImageColor3 = i._config.ScrollbarGrabColor;
				t.ScrollBarThickness = i._config.ScrollbarSize;
				t.CanvasSize = UDim2.fromScale(0, 0);
				t.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
				t.ZIndex = 6;
				t.LayoutOrder = 6;
				t.ClipsDescendants = true;
				j.UIStroke(t, i._config.WindowBorderSize, i._config.BorderColor, i._config.BorderTransparency);
				j.UIPadding(t, Vector2.new(2, i._config.WindowPadding.Y - i._config.ItemSpacing.Y));
				local u = j.UIListLayout(t, Enum.FillDirection.Vertical, UDim.new(0, 1));
				u.VerticalAlignment = Enum.VerticalAlignment.Top;
				local v = i._rootInstance and i._rootInstance:FindFirstChild("PopupScreenGui");
				t.Parent = v;
				r.ChildContainer = t;
				return s;
			end,
			Update = function(r)
				local s = r.Instance;
				local t;
				if r.parentWidget.type == "Menu" then
					t = s.TextLabel;
				else
					t = s;
				end;
				t.Text = r.arguments.Text or "Menu";
			end,
			ChildAdded = function(r, s)
				q(r);
				return r.ChildContainer;
			end,
			ChildDiscarded = function(r, s)
				q(r);
			end,
			GenerateState = function(r)
				if r.state.isOpened == nil then
					r.state.isOpened = i._widgetState(r, "isOpened", false);
				end;
			end,
			UpdateState = function(r)
				local s = r.ChildContainer;
				if r.state.isOpened.value then
					r.lastOpenedTick = i._cycleTick + 1;
					r.ButtonColors.Transparency = i._config.HeaderTransparency;
					s.Visible = true;
					q(r);
				else
					r.lastClosedTick = i._cycleTick + 1;
					r.ButtonColors.Transparency = 1;
					s.Visible = false;
				end;
			end,
			Discard = function(r)
				r.Instance:Destroy();
				j.discardState(r);
			end
		});
		i.WidgetConstructor("MenuItem", {
			hasState = false,
			hasChildren = false,
			Args = {
				Text = 1,
				KeyCode = 2,
				ModifierKey = 3
			},
			Events = {
				clicked = j.EVENTS.click(function(r)
					return r.Instance;
				end),
				hovered = j.EVENTS.hover(function(r)
					return r.Instance;
				end)
			},
			Generate = function(r)
				local s = Instance.new("TextButton");
				s.Name = "MenuItem";
				s.BackgroundTransparency = 1;
				s.BorderSizePixel = 0;
				s.Size = UDim2.fromScale(1, 0);
				s.Text = "";
				s.AutomaticSize = Enum.AutomaticSize.Y;
				s.LayoutOrder = r.ZIndex;
				s.AutoButtonColor = false;
				local t = j.UIPadding(s, i._config.FramePadding);
				t.PaddingTop = t.PaddingTop - UDim.new(0, 1);
				j.UIListLayout(s, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X));
				j.applyInteractionHighlights("Background", s, s, {
					Color = i._config.HeaderColor,
					Transparency = 1,
					HoveredColor = i._config.HeaderHoveredColor,
					HoveredTransparency = i._config.HeaderHoveredTransparency,
					ActiveColor = i._config.HeaderHoveredColor,
					ActiveTransparency = i._config.HeaderHoveredTransparency
				});
				j.applyButtonClick(s, function()
					p();
				end);
				j.applyMouseEnter(s, function()
					local u = r.parentWidget;
					if k and l and l ~= u then
						local v = table.find(o, u);
						p(v);
						l = u;
						k = true;
					end;
				end);
				local u = Instance.new("TextLabel");
				u.Name = "TextLabel";
				u.BackgroundTransparency = 1;
				u.BorderSizePixel = 0;
				u.AutomaticSize = Enum.AutomaticSize.XY;
				j.applyTextStyle(u);
				u.Parent = s;
				local v = Instance.new("TextLabel");
				v.Name = "Shortcut";
				v.BackgroundTransparency = 1;
				v.BorderSizePixel = 0;
				v.LayoutOrder = 1;
				v.AutomaticSize = Enum.AutomaticSize.XY;
				j.applyTextStyle(v);
				v.Text = "";
				v.TextColor3 = i._config.TextDisabledColor;
				v.TextTransparency = i._config.TextDisabledTransparency;
				v.Parent = s;
				return s;
			end,
			Update = function(r)
				local s = r.Instance;
				local t = s.TextLabel;
				local u = s.Shortcut;
				t.Text = r.arguments.Text;
				if r.arguments.KeyCode then
					if r.arguments.ModifierKey then
						u.Text = r.arguments.ModifierKey.Name .. " + " .. r.arguments.KeyCode.Name;
					else
						u.Text = r.arguments.KeyCode.Name;
					end;
				end;
			end,
			Discard = function(r)
				r.Instance:Destroy();
			end
		});
		i.WidgetConstructor("MenuToggle", {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				KeyCode = 2,
				ModifierKey = 3
			},
			Events = {
				checked = {
					Init = function(r)
					end,
					Get = function(r)
						return r.lastCheckedTick == i._cycleTick;
					end
				},
				unchecked = {
					Init = function(r)
					end,
					Get = function(r)
						return r.lastUncheckedTick == i._cycleTick;
					end
				},
				hovered = j.EVENTS.hover(function(r)
					return r.Instance;
				end)
			},
			Generate = function(r)
				local s = Instance.new("TextButton");
				s.Name = "MenuItem";
				s.BackgroundTransparency = 1;
				s.BorderSizePixel = 0;
				s.Size = UDim2.fromScale(1, 0);
				s.Text = "";
				s.AutomaticSize = Enum.AutomaticSize.Y;
				s.LayoutOrder = r.ZIndex;
				s.AutoButtonColor = false;
				local t = j.UIPadding(s, i._config.FramePadding);
				t.PaddingTop = t.PaddingTop - UDim.new(0, 1);
				(j.UIListLayout(s, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X))).VerticalAlignment = Enum.VerticalAlignment.Center;
				j.applyInteractionHighlights("Background", s, s, {
					Color = i._config.HeaderColor,
					Transparency = 1,
					HoveredColor = i._config.HeaderHoveredColor,
					HoveredTransparency = i._config.HeaderHoveredTransparency,
					ActiveColor = i._config.HeaderHoveredColor,
					ActiveTransparency = i._config.HeaderHoveredTransparency
				});
				j.applyButtonClick(s, function()
					local u = r.state.isChecked.value;
					r.state.isChecked:set(not u);
					p();
				end);
				j.applyMouseEnter(s, function()
					local u = r.parentWidget;
					if k and l and l ~= u then
						local v = table.find(o, u);
						p(v);
						l = u;
						k = true;
					end;
				end);
				local u = Instance.new("TextLabel");
				u.Name = "TextLabel";
				u.BackgroundTransparency = 1;
				u.BorderSizePixel = 0;
				u.AutomaticSize = Enum.AutomaticSize.XY;
				j.applyTextStyle(u);
				u.Parent = s;
				local v = Instance.new("TextLabel");
				v.Name = "Shortcut";
				v.BackgroundTransparency = 1;
				v.BorderSizePixel = 0;
				v.LayoutOrder = 1;
				v.AutomaticSize = Enum.AutomaticSize.XY;
				j.applyTextStyle(v);
				v.Text = "";
				v.TextColor3 = i._config.TextDisabledColor;
				v.TextTransparency = i._config.TextDisabledTransparency;
				v.Parent = s;
				local w = i._config.TextSize + 2 * i._config.FramePadding.Y;
				local x = math.round(0.2 * w);
				local y = w - 2 * x;
				local z = Instance.new("ImageLabel");
				z.Name = "Icon";
				z.Size = UDim2.fromOffset(y, y);
				z.BackgroundTransparency = 1;
				z.BorderSizePixel = 0;
				z.ImageColor3 = i._config.TextColor;
				z.ImageTransparency = i._config.TextTransparency;
				z.Image = j.ICONS.CHECK_MARK;
				z.LayoutOrder = 2;
				z.Parent = s;
				return s;
			end,
			GenerateState = function(r)
				if r.state.isChecked == nil then
					r.state.isChecked = i._widgetState(r, "isChecked", false);
				end;
			end,
			Update = function(r)
				local s = r.Instance;
				local t = s.TextLabel;
				local u = s.Shortcut;
				t.Text = r.arguments.Text;
				if r.arguments.KeyCode then
					if r.arguments.ModifierKey then
						u.Text = r.arguments.ModifierKey.Name .. " + " .. r.arguments.KeyCode.Name;
					else
						u.Text = r.arguments.KeyCode.Name;
					end;
				end;
			end,
			UpdateState = function(r)
				local s = r.Instance;
				local t = s.Icon;
				if r.state.isChecked.value then
					t.Image = j.ICONS.CHECK_MARK;
					r.lastCheckedTick = i._cycleTick + 1;
				else
					t.Image = "";
					r.lastUncheckedTick = i._cycleTick + 1;
				end;
			end,
			Discard = function(r)
				r.Instance:Destroy();
				j.discardState(r);
			end
		});
	end;
end);
c("widgets/Window", function(e, f, g, h)
	return function(i, j)
		local k = function()
			if i._rootInstance == nil then
				return;
			end;
			local k = i._rootInstance:FindFirstChild("PopupScreenGui");
			local l = k.TooltipContainer;
			local o = j.getMouseLocation();
			local p = j.findBestWindowPosForPopup(o, l.AbsoluteSize, i._config.DisplaySafeAreaPadding, k.AbsoluteSize);
			l.Position = UDim2.fromOffset(p.X, p.Y);
		end;
		j.registerEvent("InputChanged", function()
			if not i._started then
				return;
			end;
			k();
		end);
		i.WidgetConstructor("Tooltip", {
			hasState = false,
			hasChildren = false,
			Args = {
				Text = 1
			},
			Events = {},
			Generate = function(l)
				l.parentWidget = i._rootWidget;
				local o = Instance.new("Frame");
				o.Name = "Iris_Tooltip";
				o.Size = UDim2.new(i._config.ContentWidth, UDim.new(0, 0));
				o.AutomaticSize = Enum.AutomaticSize.Y;
				o.BorderSizePixel = 0;
				o.BackgroundTransparency = 1;
				o.ZIndex = 1;
				local p = Instance.new("TextLabel");
				p.Name = "TooltipText";
				p.Size = UDim2.fromOffset(0, 0);
				p.AutomaticSize = Enum.AutomaticSize.XY;
				p.BackgroundColor3 = i._config.PopupBgColor;
				p.BackgroundTransparency = i._config.PopupBgTransparency;
				p.TextWrapped = i._config.TextWrapped;
				j.applyTextStyle(p);
				j.UIStroke(p, i._config.PopupBorderSize, i._config.BorderActiveColor, i._config.BorderActiveTransparency);
				j.UIPadding(p, i._config.WindowPadding);
				if i._config.PopupRounding > 0 then
					j.UICorner(p, i._config.PopupRounding);
				end;
				p.Parent = o;
				return o;
			end,
			Update = function(l)
				local o = l.Instance;
				local p = o.TooltipText;
				if l.arguments.Text == nil then
					error("Text argument is required for Iris.Tooltip().", 5);
				end;
				p.Text = l.arguments.Text;
				k();
			end,
			Discard = function(l)
				l.Instance:Destroy();
			end
		});
		local l = 0;
		local o;
		local p = false;
		local q;
		local r;
		local s = false;
		local t = false;
		local u = false;
		local v = Enum.TopBottom.Top;
		local w = Enum.LeftRight.Left;
		local x;
		local y;
		local z = false;
		local A = {};
		local B = function()
			if i._config.UseScreenGUIs == false then
				return;
			end;
			local B = 65535;
			local C;
			for D, E in A do
				if E.state.isOpened.value and (not E.arguments.NoNav) then
					if E.Instance:IsA("ScreenGui") then
						local F = E.Instance.DisplayOrder;
						if F < B then
							B = F;
							C = E;
						end;
					end;
				end;
			end;
			if not C then
				return;
			end;
			if C.state.isUncollapsed.value == false then
				C.state.isUncollapsed:set(true);
			end;
			i.SetFocusedWindow(C);
		end;
		local C = function(C, D)
			local E = Vector2.new(C.state.position.value.X, C.state.position.value.Y);
			local F = (i._config.TextSize + 2 * i._config.FramePadding.Y) * 2;
			local G = j.getScreenSizeForWindow(C);
			local H = Vector2.new(i._config.WindowBorderSize + i._config.DisplaySafeAreaPadding.X, i._config.WindowBorderSize + i._config.DisplaySafeAreaPadding.Y);
			local I = G - E - H;
			return Vector2.new(math.clamp(D.X, F, math.max(I.X, F)), math.clamp(D.Y, F, math.max(I.Y, F)));
		end;
		local D = function(D, E)
			local F = D.Instance;
			local G = j.getScreenSizeForWindow(D);
			local H = Vector2.new(i._config.WindowBorderSize + i._config.DisplaySafeAreaPadding.X, i._config.WindowBorderSize + i._config.DisplaySafeAreaPadding.Y);
			return Vector2.new(math.clamp(E.X, H.X, math.max(H.X, G.X - F.WindowButton.AbsoluteSize.X - H.X)), math.clamp(E.Y, H.Y, math.max(H.Y, G.Y - F.WindowButton.AbsoluteSize.Y - H.Y)));
		end;
		i.SetFocusedWindow = function(E)
			if y == E then
				return;
			end;
			if z and y ~= nil then
				if A[y.ID] then
					local F = y.Instance;
					local G = F.WindowButton;
					local H = G.Content;
					local I = H.TitleBar;
					if y.state.isUncollapsed.value then
						I.BackgroundColor3 = i._config.TitleBgColor;
						I.BackgroundTransparency = i._config.TitleBgTransparency;
					else
						I.BackgroundColor3 = i._config.TitleBgCollapsedColor;
						I.BackgroundTransparency = i._config.TitleBgCollapsedTransparency;
					end;
					G.UIStroke.Color = i._config.BorderColor;
				end;
				z = false;
				y = nil;
			end;
			if E ~= nil then
				z = true;
				y = E;
				local F = E.Instance;
				local G = F.WindowButton;
				local H = G.Content;
				local I = H.TitleBar;
				I.BackgroundColor3 = i._config.TitleBgActiveColor;
				I.BackgroundTransparency = i._config.TitleBgActiveTransparency;
				G.UIStroke.Color = i._config.BorderActiveColor;
				l = l + 1;
				if E.usesScreenGuis then
					F.DisplayOrder = l + i._config.DisplayOrderOffset;
				else
					F.ZIndex = l + i._config.DisplayOrderOffset;
				end;
				if E.state.isUncollapsed.value == false then
					E.state.isUncollapsed:set(true);
				end;
				local J = j.GuiService.SelectedObject;
				if J then
					if I.Visible then
						j.GuiService:Select(I);
					else
						j.GuiService:Select(E.ChildContainer);
					end;
				end;
			end;
		end;
		j.registerEvent("InputBegan", function(E)
			if not i._started then
				return;
			end;
			if E.UserInputType == Enum.UserInputType.MouseButton1 then
				local F = false;
				local G = j.getMouseLocation();
				for H, I in A do
					local J = false;
					repeat
						local K = I.Instance;
						if not K then
							J = true;
							break;
						end;
						local L = K.WindowButton;
						local M = L.ResizeBorder;
						if M and j.isPosInsideRect(G, M.AbsolutePosition - j.GuiOffset, M.AbsolutePosition - j.GuiOffset + M.AbsoluteSize) then
							F = true;
							break;
						end;
						J = true;
					until true;
					if not J then
						break;
					end;
				end;
				if not F then
					i.SetFocusedWindow(nil);
				end;
			end;
			if E.KeyCode == Enum.KeyCode.Tab and (j.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or j.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
				B();
			end;
			if E.UserInputType == Enum.UserInputType.MouseButton1 and t and (not u) and z and y then
				local F = y.state.position.value + y.state.size.value / 2;
				local G = j.getMouseLocation() - F;
				if math.abs(G.X) * y.state.size.value.Y >= math.abs(G.Y) * y.state.size.value.X then
					v = Enum.TopBottom.Center;
					w = (math.sign(G.X) == (-1) and {
						Enum.LeftRight.Left
					} or {
						Enum.LeftRight.Right
					})[1];
				else
					w = Enum.LeftRight.Center;
					v = (math.sign(G.Y) == (-1) and {
						Enum.TopBottom.Top
					} or {
						Enum.TopBottom.Bottom
					})[1];
				end;
				s = true;
				r = y;
			end;
		end);
		j.registerEvent("TouchTapInWorld", function(E, F)
			if not i._started then
				return;
			end;
			if not F then
				i.SetFocusedWindow(nil);
			end;
		end);
		j.registerEvent("InputChanged", function(E)
			if not i._started then
				return;
			end;
			if p and o then
				local F;
				if E.UserInputType == Enum.UserInputType.Touch then
					local G = E.Position;
					F = Vector2.new(G.X, G.Y);
				else
					F = j.getMouseLocation();
				end;
				local G = o.Instance;
				local H = G.WindowButton;
				local I = F - q;
				local J = D(o, I);
				H.Position = UDim2.fromOffset(J.X, J.Y);
				o.state.position.value = J;
			end;
			if s and r and r.arguments.NoResize ~= true then
				local F = r.Instance;
				local G = F.WindowButton;
				local H = Vector2.new(G.Position.X.Offset, G.Position.Y.Offset);
				local I = Vector2.new(G.Size.X.Offset, G.Size.Y.Offset);
				local J;
				if E.UserInputType == Enum.UserInputType.Touch then
					J = E.Delta;
				else
					J = j.getMouseLocation() - x;
				end;
				local K = H + Vector2.new(((w == Enum.LeftRight.Left and {
					J.X
				} or {
					0
				}))[1], ((v == Enum.TopBottom.Top and {
					J.Y
				} or {
					0
				}))[1]);
				local L = I + Vector2.new(((w == Enum.LeftRight.Left and {
					(-J.X)
				} or {
					((w == Enum.LeftRight.Right and {
						J.X
					} or {
						0
					}))[1]
				}))[1], ((v == Enum.TopBottom.Top and {
					(-J.Y)
				} or {
					((v == Enum.TopBottom.Bottom and {
						J.Y
					} or {
						0
					}))[1]
				}))[1]);
				local M = C(r, L);
				local N = D(r, K);
				G.Size = UDim2.fromOffset(M.X, M.Y);
				r.state.size.value = M;
				G.Position = UDim2.fromOffset(N.X, N.Y);
				r.state.position.value = N;
			end;
			x = j.getMouseLocation();
		end);
		j.registerEvent("InputEnded", function(E, F)
			if not i._started then
				return;
			end;
			if (E.UserInputType == Enum.UserInputType.MouseButton1 or E.UserInputType == Enum.UserInputType.Touch) and p and o then
				local G = o.Instance;
				local H = G.WindowButton;
				p = false;
				o.state.position:set(Vector2.new(H.Position.X.Offset, H.Position.Y.Offset));
			end;
			if (E.UserInputType == Enum.UserInputType.MouseButton1 or E.UserInputType == Enum.UserInputType.Touch) and s and r then
				local G = r.Instance;
				s = false;
				r.state.size:set(G.WindowButton.AbsoluteSize);
			end;
			if E.KeyCode == Enum.KeyCode.ButtonX then
				B();
			end;
		end);
		i.WidgetConstructor("Window", {
			hasState = true,
			hasChildren = true,
			Args = {
				Title = 1,
				NoTitleBar = 2,
				NoBackground = 3,
				NoCollapse = 4,
				NoClose = 5,
				NoMove = 6,
				NoScrollbar = 7,
				NoResize = 8,
				NoNav = 9,
				NoMenu = 10
			},
			Events = {
				closed = {
					Init = function(E)
					end,
					Get = function(E)
						return E.lastClosedTick == i._cycleTick;
					end
				},
				opened = {
					Init = function(E)
					end,
					Get = function(E)
						return E.lastOpenedTick == i._cycleTick;
					end
				},
				collapsed = {
					Init = function(E)
					end,
					Get = function(E)
						return E.lastCollapsedTick == i._cycleTick;
					end
				},
				uncollapsed = {
					Init = function(E)
					end,
					Get = function(E)
						return E.lastUncollapsedTick == i._cycleTick;
					end
				},
				hovered = j.EVENTS.hover(function(E)
					local F = E.Instance;
					return F.WindowButton;
				end)
			},
			Generate = function(E)
				E.parentWidget = i._rootWidget;
				E.usesScreenGuis = i._config.UseScreenGUIs;
				A[E.ID] = E;
				local F;
				if E.usesScreenGuis then
					F = Instance.new("ScreenGui");
					F.ResetOnSpawn = false;
					F.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
					F.DisplayOrder = i._config.DisplayOrderOffset;
					F.IgnoreGuiInset = i._config.IgnoreGuiInset;
				else
					F = Instance.new("Frame");
					F.AnchorPoint = Vector2.new(0.5, 0.5);
					F.Position = UDim2.new(0.5, 0, 0.5, 0);
					F.Size = UDim2.new(1, 0, 1, 0);
					F.BackgroundTransparency = 1;
					F.ZIndex = i._config.DisplayOrderOffset;
				end;
				F.Name = "Iris_Window";
				local G = Instance.new("TextButton");
				G.Name = "WindowButton";
				G.Size = UDim2.fromOffset(0, 0);
				G.BackgroundTransparency = 1;
				G.BorderSizePixel = 0;
				G.Text = "";
				G.ClipsDescendants = false;
				G.AutoButtonColor = false;
				G.Selectable = false;
				G.SelectionImageObject = i.SelectionImageObject;
				G.SelectionGroup = true;
				G.SelectionBehaviorUp = Enum.SelectionBehavior.Stop;
				G.SelectionBehaviorDown = Enum.SelectionBehavior.Stop;
				G.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop;
				G.SelectionBehaviorRight = Enum.SelectionBehavior.Stop;
				j.UIStroke(G, i._config.WindowBorderSize, i._config.BorderColor, i._config.BorderTransparency);
				G.Parent = F;
				j.applyInputBegan(G, function(H)
					if H.UserInputType == Enum.UserInputType.MouseMovement or H.UserInputType == Enum.UserInputType.Keyboard then
						return;
					end;
					if E.state.isUncollapsed.value then
						i.SetFocusedWindow(E);
					end;
					if not E.arguments.NoMove and H.UserInputType == Enum.UserInputType.MouseButton1 then
						o = E;
						p = true;
						q = j.getMouseLocation() - E.state.position.value;
					end;
				end);
				local H = Instance.new("Frame");
				H.Name = "Content";
				H.AnchorPoint = Vector2.new(0.5, 0.5);
				H.Position = UDim2.fromScale(0.5, 0.5);
				H.Size = UDim2.fromScale(1, 1);
				H.BackgroundTransparency = 1;
				H.ClipsDescendants = true;
				H.Parent = G;
				local I = j.UIListLayout(H, Enum.FillDirection.Vertical, UDim.new(0, 0));
				I.HorizontalAlignment = Enum.HorizontalAlignment.Center;
				I.VerticalAlignment = Enum.VerticalAlignment.Top;
				local J = Instance.new("ScrollingFrame");
				J.Name = "WindowContainer";
				J.Size = UDim2.fromScale(1, 1);
				J.BackgroundColor3 = i._config.WindowBgColor;
				J.BackgroundTransparency = i._config.WindowBgTransparency;
				J.BorderSizePixel = 0;
				J.AutomaticCanvasSize = Enum.AutomaticSize.Y;
				J.ScrollBarImageTransparency = i._config.ScrollbarGrabTransparency;
				J.ScrollBarImageColor3 = i._config.ScrollbarGrabColor;
				J.CanvasSize = UDim2.fromScale(0, 0);
				J.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
				J.LayoutOrder = E.ZIndex + 65535;
				J.ClipsDescendants = true;
				j.UIPadding(J, i._config.WindowPadding);
				J.Parent = H;
				local K = Instance.new("UIFlexItem");
				K.FlexMode = Enum.UIFlexMode.Fill;
				K.ItemLineAlignment = Enum.ItemLineAlignment.End;
				K.Parent = J;
				(J:GetPropertyChangedSignal("CanvasPosition")):Connect(function()
					E.state.scrollDistance.value = J.CanvasPosition.Y;
				end);
				j.applyInputBegan(J, function(L)
					if L.UserInputType == Enum.UserInputType.MouseMovement or L.UserInputType == Enum.UserInputType.Keyboard then
						return;
					end;
					if E.state.isUncollapsed.value then
						i.SetFocusedWindow(E);
					end;
				end);
				local L = Instance.new("Frame");
				L.Name = "TerminatingFrame";
				L.Size = UDim2.fromOffset(0, i._config.WindowPadding.Y + i._config.FramePadding.Y);
				L.BackgroundTransparency = 1;
				L.BorderSizePixel = 0;
				L.LayoutOrder = 2147483632;
				local M = j.UIListLayout(J, Enum.FillDirection.Vertical, UDim.new(0, i._config.ItemSpacing.Y));
				M.VerticalAlignment = Enum.VerticalAlignment.Top;
				L.Parent = J;
				local N = Instance.new("Frame");
				N.Name = "TitleBar";
				N.AutomaticSize = Enum.AutomaticSize.Y;
				N.Size = UDim2.fromScale(1, 0);
				N.BorderSizePixel = 0;
				N.ClipsDescendants = true;
				N.Parent = H;
				j.UIPadding(N, Vector2.new(i._config.FramePadding.X));
				(j.UIListLayout(N, Enum.FillDirection.Horizontal, UDim.new(0, i._config.ItemInnerSpacing.X))).VerticalAlignment = Enum.VerticalAlignment.Center;
				j.applyInputBegan(N, function(O)
					if O.UserInputType == Enum.UserInputType.Touch then
						if not E.arguments.NoMove then
							o = E;
							p = true;
							local P = O.Position;
							q = Vector2.new(P.X, P.Y) - E.state.position.value;
						end;
					end;
				end);
				local O = i._config.TextSize + (i._config.FramePadding.Y - 1) * 2;
				local P = Instance.new("TextButton");
				P.Name = "CollapseButton";
				P.AnchorPoint = Vector2.new(0, 0.5);
				P.Size = UDim2.fromOffset(O, O);
				P.Position = UDim2.new(0, 0, 0.5, 0);
				P.AutomaticSize = Enum.AutomaticSize.None;
				P.BackgroundTransparency = 1;
				P.BorderSizePixel = 0;
				P.AutoButtonColor = false;
				P.Text = "";
				j.UICorner(P);
				P.Parent = N;
				j.applyButtonClick(P, function()
					E.state.isUncollapsed:set(not E.state.isUncollapsed.value);
				end);
				j.applyInteractionHighlights("Background", P, P, {
					Color = i._config.ButtonColor,
					Transparency = 1,
					HoveredColor = i._config.ButtonHoveredColor,
					HoveredTransparency = i._config.ButtonHoveredTransparency,
					ActiveColor = i._config.ButtonActiveColor,
					ActiveTransparency = i._config.ButtonActiveTransparency
				});
				local Q = Instance.new("ImageLabel");
				Q.Name = "Arrow";
				Q.AnchorPoint = Vector2.new(0.5, 0.5);
				Q.Size = UDim2.fromOffset(math.floor(0.7 * O), math.floor(0.7 * O));
				Q.Position = UDim2.fromScale(0.5, 0.5);
				Q.BackgroundTransparency = 1;
				Q.BorderSizePixel = 0;
				Q.Image = j.ICONS.MULTIPLICATION_SIGN;
				Q.ImageColor3 = i._config.TextColor;
				Q.ImageTransparency = i._config.TextTransparency;
				Q.Parent = P;
				local R = Instance.new("TextButton");
				R.Name = "CloseButton";
				R.AnchorPoint = Vector2.new(1, 0.5);
				R.Size = UDim2.fromOffset(O, O);
				R.Position = UDim2.new(1, 0, 0.5, 0);
				R.AutomaticSize = Enum.AutomaticSize.None;
				R.BackgroundTransparency = 1;
				R.BorderSizePixel = 0;
				R.Text = "";
				R.LayoutOrder = 2;
				R.AutoButtonColor = false;
				j.UICorner(R);
				j.applyButtonClick(R, function()
					E.state.isOpened:set(false);
				end);
				j.applyInteractionHighlights("Background", R, R, {
					Color = i._config.ButtonColor,
					Transparency = 1,
					HoveredColor = i._config.ButtonHoveredColor,
					HoveredTransparency = i._config.ButtonHoveredTransparency,
					ActiveColor = i._config.ButtonActiveColor,
					ActiveTransparency = i._config.ButtonActiveTransparency
				});
				R.Parent = N;
				local S = Instance.new("ImageLabel");
				S.Name = "Icon";
				S.AnchorPoint = Vector2.new(0.5, 0.5);
				S.Size = UDim2.fromOffset(math.floor(0.7 * O), math.floor(0.7 * O));
				S.Position = UDim2.fromScale(0.5, 0.5);
				S.BackgroundTransparency = 1;
				S.BorderSizePixel = 0;
				S.Image = j.ICONS.MULTIPLICATION_SIGN;
				S.ImageColor3 = i._config.TextColor;
				S.ImageTransparency = i._config.TextTransparency;
				S.Parent = R;
				local T = Instance.new("TextLabel");
				T.Name = "Title";
				T.AutomaticSize = Enum.AutomaticSize.XY;
				T.BorderSizePixel = 0;
				T.BackgroundTransparency = 1;
				T.LayoutOrder = 1;
				T.ClipsDescendants = true;
				j.UIPadding(T, Vector2.new(0, i._config.FramePadding.Y));
				j.applyTextStyle(T);
				T.TextXAlignment = Enum.TextXAlignment[i._config.WindowTitleAlign.Name];
				local U = Instance.new("UIFlexItem");
				U.FlexMode = Enum.UIFlexMode.Fill;
				U.ItemLineAlignment = Enum.ItemLineAlignment.Center;
				U.Parent = T;
				T.Parent = N;
				local V = i._config.TextSize + i._config.FramePadding.X;
				local W = Instance.new("ImageButton");
				W.Name = "LeftResizeGrip";
				W.AnchorPoint = Vector2.yAxis;
				W.Rotation = 180;
				W.Size = UDim2.fromOffset(V, V);
				W.Position = UDim2.fromScale(0, 1);
				W.BackgroundTransparency = 1;
				W.BorderSizePixel = 0;
				W.Image = j.ICONS.BOTTOM_RIGHT_CORNER;
				W.ImageColor3 = i._config.ResizeGripColor;
				W.ImageTransparency = 1;
				W.AutoButtonColor = false;
				W.ZIndex = 3;
				W.Parent = G;
				j.applyInteractionHighlights("Image", W, W, {
					Color = i._config.ResizeGripColor,
					Transparency = 1,
					HoveredColor = i._config.ResizeGripHoveredColor,
					HoveredTransparency = i._config.ResizeGripHoveredTransparency,
					ActiveColor = i._config.ResizeGripActiveColor,
					ActiveTransparency = i._config.ResizeGripActiveTransparency
				});
				j.applyButtonDown(W, function()
					if not z or (not (y == E)) then
						i.SetFocusedWindow(E);
					end;
					s = true;
					v = Enum.TopBottom.Bottom;
					w = Enum.LeftRight.Left;
					r = E;
				end);
				local X = Instance.new("ImageButton");
				X.Name = "RightResizeGrip";
				X.AnchorPoint = Vector2.one;
				X.Rotation = 90;
				X.Size = UDim2.fromOffset(V, V);
				X.Position = UDim2.fromScale(1, 1);
				X.BackgroundTransparency = 1;
				X.BorderSizePixel = 0;
				X.Image = j.ICONS.BOTTOM_RIGHT_CORNER;
				X.ImageColor3 = i._config.ResizeGripColor;
				X.ImageTransparency = i._config.ResizeGripTransparency;
				X.AutoButtonColor = false;
				X.ZIndex = 3;
				X.Parent = G;
				j.applyInteractionHighlights("Image", X, X, {
					Color = i._config.ResizeGripColor,
					Transparency = i._config.ResizeGripTransparency,
					HoveredColor = i._config.ResizeGripHoveredColor,
					HoveredTransparency = i._config.ResizeGripHoveredTransparency,
					ActiveColor = i._config.ResizeGripActiveColor,
					ActiveTransparency = i._config.ResizeGripActiveTransparency
				});
				j.applyButtonDown(X, function()
					if not z or (not (y == E)) then
						i.SetFocusedWindow(E);
					end;
					s = true;
					v = Enum.TopBottom.Bottom;
					w = Enum.LeftRight.Right;
					r = E;
				end);
				local Y = Instance.new("ImageButton");
				Y.Name = "LeftResizeBorder";
				Y.AnchorPoint = Vector2.new(1, 0.5);
				Y.Position = UDim2.fromScale(0, 0.5);
				Y.Size = UDim2.new(0, i._config.WindowResizePadding.X, 1, 2 * i._config.WindowBorderSize);
				Y.Transparency = 1;
				Y.Image = j.ICONS.BORDER;
				Y.ResampleMode = Enum.ResamplerMode.Pixelated;
				Y.ScaleType = Enum.ScaleType.Slice;
				Y.SliceCenter = Rect.new(0, 0, 1, 1);
				Y.ImageRectOffset = Vector2.new(2, 2);
				Y.ImageRectSize = Vector2.new(2, 1);
				Y.ImageTransparency = 1;
				Y.ZIndex = 4;
				Y.AutoButtonColor = false;
				Y.Parent = G;
				local Z = Instance.new("ImageButton");
				Z.Name = "RightResizeBorder";
				Z.AnchorPoint = Vector2.new(0, 0.5);
				Z.Position = UDim2.fromScale(1, 0.5);
				Z.Size = UDim2.new(0, i._config.WindowResizePadding.X, 1, 2 * i._config.WindowBorderSize);
				Z.Transparency = 1;
				Z.Image = j.ICONS.BORDER;
				Z.ResampleMode = Enum.ResamplerMode.Pixelated;
				Z.ScaleType = Enum.ScaleType.Slice;
				Z.SliceCenter = Rect.new(1, 0, 2, 1);
				Z.ImageRectOffset = Vector2.new(1, 2);
				Z.ImageRectSize = Vector2.new(2, 1);
				Z.ImageTransparency = 1;
				Z.ZIndex = 4;
				Z.AutoButtonColor = false;
				Z.Parent = G;
				local _ = Instance.new("ImageButton");
				_.Name = "TopResizeBorder";
				_.AnchorPoint = Vector2.new(0.5, 1);
				_.Position = UDim2.fromScale(0.5, 0);
				_.Size = UDim2.new(1, 2 * i._config.WindowBorderSize, 0, i._config.WindowResizePadding.Y);
				_.Transparency = 1;
				_.Image = j.ICONS.BORDER;
				_.ResampleMode = Enum.ResamplerMode.Pixelated;
				_.ScaleType = Enum.ScaleType.Slice;
				_.SliceCenter = Rect.new(0, 0, 1, 1);
				_.ImageRectOffset = Vector2.new(2, 2);
				_.ImageRectSize = Vector2.new(1, 2);
				_.ImageTransparency = 1;
				_.ZIndex = 4;
				_.AutoButtonColor = false;
				_.Parent = G;
				local aa = Instance.new("ImageButton");
				aa.Name = "BottomResizeBorder";
				aa.AnchorPoint = Vector2.new(0.5, 0);
				aa.Position = UDim2.fromScale(0.5, 1);
				aa.Size = UDim2.new(1, 2 * i._config.WindowBorderSize, 0, i._config.WindowResizePadding.Y);
				aa.Transparency = 1;
				aa.Image = j.ICONS.BORDER;
				aa.ResampleMode = Enum.ResamplerMode.Pixelated;
				aa.ScaleType = Enum.ScaleType.Slice;
				aa.SliceCenter = Rect.new(0, 1, 1, 2);
				aa.ImageRectOffset = Vector2.new(2, 1);
				aa.ImageRectSize = Vector2.new(1, 2);
				aa.ImageTransparency = 1;
				aa.ZIndex = 4;
				aa.AutoButtonColor = false;
				aa.Parent = G;
				j.applyInteractionHighlights("Image", Y, Y, {
					Color = i._config.ResizeGripColor,
					Transparency = 1,
					HoveredColor = i._config.ResizeGripHoveredColor,
					HoveredTransparency = i._config.ResizeGripHoveredTransparency,
					ActiveColor = i._config.ResizeGripActiveColor,
					ActiveTransparency = i._config.ResizeGripActiveTransparency
				});
				j.applyInteractionHighlights("Image", Z, Z, {
					Color = i._config.ResizeGripColor,
					Transparency = 1,
					HoveredColor = i._config.ResizeGripHoveredColor,
					HoveredTransparency = i._config.ResizeGripHoveredTransparency,
					ActiveColor = i._config.ResizeGripActiveColor,
					ActiveTransparency = i._config.ResizeGripActiveTransparency
				});
				j.applyInteractionHighlights("Image", _, _, {
					Color = i._config.ResizeGripColor,
					Transparency = 1,
					HoveredColor = i._config.ResizeGripHoveredColor,
					HoveredTransparency = i._config.ResizeGripHoveredTransparency,
					ActiveColor = i._config.ResizeGripActiveColor,
					ActiveTransparency = i._config.ResizeGripActiveTransparency
				});
				j.applyInteractionHighlights("Image", aa, aa, {
					Color = i._config.ResizeGripColor,
					Transparency = 1,
					HoveredColor = i._config.ResizeGripHoveredColor,
					HoveredTransparency = i._config.ResizeGripHoveredTransparency,
					ActiveColor = i._config.ResizeGripActiveColor,
					ActiveTransparency = i._config.ResizeGripActiveTransparency
				});
				local ab = Instance.new("Frame");
				ab.Name = "ResizeBorder";
				ab.Size = UDim2.new(1, i._config.WindowResizePadding.X * 2, 1, i._config.WindowResizePadding.Y * 2);
				ab.Position = UDim2.fromOffset(-i._config.WindowResizePadding.X, -i._config.WindowResizePadding.Y);
				ab.BackgroundTransparency = 1;
				ab.BorderSizePixel = 0;
				ab.Active = true;
				ab.Selectable = false;
				ab.ClipsDescendants = false;
				ab.Parent = G;
				j.applyMouseEnter(ab, function()
					if y == E then
						t = true;
					end;
				end);
				j.applyMouseLeave(ab, function()
					if y == E then
						t = false;
					end;
				end);
				j.applyInputBegan(ab, function(ac)
					if ac.UserInputType == Enum.UserInputType.MouseMovement or ac.UserInputType == Enum.UserInputType.Keyboard then
						return;
					end;
					if E.state.isUncollapsed.value then
						i.SetFocusedWindow(E);
					end;
				end);
				j.applyMouseEnter(G, function()
					if y == E then
						u = true;
					end;
				end);
				j.applyMouseLeave(G, function()
					if y == E then
						u = false;
					end;
				end);
				E.ChildContainer = J;
				return F;
			end,
			Update = function(aa)
				local ab = aa.Instance;
				local ac = aa.ChildContainer;
				local E = ab.WindowButton;
				local F = E.Content;
				local G = F.TitleBar;
				local H = G.Title;
				local I = F:FindFirstChild("MenuBar");
				local J = E.LeftResizeGrip;
				local K = E.RightResizeGrip;
				local L = E.LeftResizeBorder;
				local M = E.RightResizeBorder;
				local N = E.TopResizeBorder;
				local O = E.BottomResizeBorder;
				if aa.arguments.NoResize ~= true then
					J.Visible = true;
					K.Visible = true;
					L.Visible = true;
					M.Visible = true;
					N.Visible = true;
					O.Visible = true;
				else
					J.Visible = false;
					K.Visible = false;
					L.Visible = false;
					M.Visible = false;
					N.Visible = false;
					O.Visible = false;
				end;
				if aa.arguments.NoScrollbar then
					ac.ScrollBarThickness = 0;
				else
					ac.ScrollBarThickness = i._config.ScrollbarSize;
				end;
				if aa.arguments.NoTitleBar then
					G.Visible = false;
				else
					G.Visible = true;
				end;
				if I then
					if aa.arguments.NoMenu then
						I.Visible = false;
					else
						I.Visible = true;
					end;
				end;
				if aa.arguments.NoBackground then
					ac.BackgroundTransparency = 1;
				else
					ac.BackgroundTransparency = i._config.WindowBgTransparency;
				end;
				if aa.arguments.NoCollapse then
					G.CollapseButton.Visible = false;
				else
					G.CollapseButton.Visible = true;
				end;
				if aa.arguments.NoClose then
					G.CloseButton.Visible = false;
				else
					G.CloseButton.Visible = true;
				end;
				H.Text = aa.arguments.Title or "";
			end,
			Discard = function(aa)
				if y == aa then
					y = nil;
					z = false;
				end;
				if o == aa then
					o = nil;
					p = false;
				end;
				if r == aa then
					r = nil;
					s = false;
				end;
				A[aa.ID] = nil;
				aa.Instance:Destroy();
				j.discardState(aa);
			end,
			ChildAdded = function(aa, ab)
				local ac = aa.Instance;
				local E = ac.WindowButton;
				local F = E.Content;
				if ab.type == "MenuBar" then
					local G = aa.ChildContainer;
					ab.Instance.ZIndex = G.ZIndex + 1;
					ab.Instance.LayoutOrder = G.LayoutOrder - 1;
					return F;
				end;
				return aa.ChildContainer;
			end,
			UpdateState = function(aa)
				local ab = aa.state.size.value;
				local ac = aa.state.position.value;
				local E = aa.state.isUncollapsed.value;
				local F = aa.state.isOpened.value;
				local G = aa.state.scrollDistance.value;
				local H = aa.Instance;
				local I = aa.ChildContainer;
				local J = H.WindowButton;
				local K = J.Content;
				local L = K.TitleBar;
				local M = K:FindFirstChild("MenuBar");
				local N = J.LeftResizeGrip;
				local O = J.RightResizeGrip;
				local P = J.LeftResizeBorder;
				local Q = J.RightResizeBorder;
				local R = J.TopResizeBorder;
				local S = J.BottomResizeBorder;
				J.Size = UDim2.fromOffset(ab.X, ab.Y);
				J.Position = UDim2.fromOffset(ac.X, ac.Y);
				if F then
					if aa.usesScreenGuis then
						H.Enabled = true;
						J.Visible = true;
					else
						H.Visible = true;
						J.Visible = true;
					end;
					aa.lastOpenedTick = i._cycleTick + 1;
				else
					if aa.usesScreenGuis then
						H.Enabled = false;
						J.Visible = false;
					else
						H.Visible = false;
						J.Visible = false;
					end;
					aa.lastClosedTick = i._cycleTick + 1;
				end;
				if E then
					L.CollapseButton.Arrow.Image = j.ICONS.DOWN_POINTING_TRIANGLE;
					if M then
						M.Visible = not aa.arguments.NoMenu;
					end;
					I.Visible = true;
					if aa.arguments.NoResize ~= true then
						N.Visible = true;
						O.Visible = true;
						P.Visible = true;
						Q.Visible = true;
						R.Visible = true;
						S.Visible = true;
					end;
					J.AutomaticSize = Enum.AutomaticSize.None;
					aa.lastUncollapsedTick = i._cycleTick + 1;
				else
					local T = L.AbsoluteSize.Y;
					L.CollapseButton.Arrow.Image = j.ICONS.RIGHT_POINTING_TRIANGLE;
					if M then
						M.Visible = false;
					end;
					I.Visible = false;
					N.Visible = false;
					O.Visible = false;
					P.Visible = false;
					Q.Visible = false;
					R.Visible = false;
					S.Visible = false;
					J.Size = UDim2.fromOffset(ab.X, T);
					aa.lastCollapsedTick = i._cycleTick + 1;
				end;
				if F and E then
					i.SetFocusedWindow(aa);
				else
					L.BackgroundColor3 = i._config.TitleBgCollapsedColor;
					L.BackgroundTransparency = i._config.TitleBgCollapsedTransparency;
					J.UIStroke.Color = i._config.BorderColor;
					i.SetFocusedWindow(nil);
				end;
				if G and G ~= 0 then
					local T = (#i._postCycleCallbacks) + 1;
					local U = i._cycleTick + 1;
					i._postCycleCallbacks[T] = function()
						if i._cycleTick >= U then
							if aa.lastCycleTick ~= (-1) then
								I.CanvasPosition = Vector2.new(0, G);
							end;
							i._postCycleCallbacks[T] = nil;
						end;
					end;
				end;
			end,
			GenerateState = function(aa)
				if aa.state.size == nil then
					aa.state.size = i._widgetState(aa, "size", Vector2.new(400, 300));
				end;
				if aa.state.position == nil then
					aa.state.position = i._widgetState(aa, "position", (z and y and {
						y.state.position.value + Vector2.new(15, 45)
					} or {
						Vector2.new(150, 250)
					})[1]);
				end;
				aa.state.position.value = D(aa, aa.state.position.value);
				aa.state.size.value = C(aa, aa.state.size.value);
				if aa.state.isUncollapsed == nil then
					aa.state.isUncollapsed = i._widgetState(aa, "isUncollapsed", true);
				end;
				if aa.state.isOpened == nil then
					aa.state.isOpened = i._widgetState(aa, "isOpened", true);
				end;
				if aa.state.scrollDistance == nil then
					aa.state.scrollDistance = i._widgetState(aa, "scrollDistance", 0);
				end;
			end
		});
	end;
end);
c("widgets/Root", function(aa, ab, ac, e)
	return function(f, g)
		local h = 0;
		f.WidgetConstructor("Root", {
			hasState = false,
			hasChildren = true,
			Args = {},
			Events = {},
			Generate = function(i)
				local j = Instance.new("Folder");
				j.Name = "Iris_Root";
				local k;
				if f._config.UseScreenGUIs then
					k = Instance.new("ScreenGui");
					k.ResetOnSpawn = false;
					k.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
					k.DisplayOrder = f._config.DisplayOrderOffset;
					k.IgnoreGuiInset = f._config.IgnoreGuiInset;
				else
					k = Instance.new("Frame");
					k.AnchorPoint = Vector2.new(0.5, 0.5);
					k.Position = UDim2.new(0.5, 0, 0.5, 0);
					k.Size = UDim2.new(1, 0, 1, 0);
					k.BackgroundTransparency = 1;
					k.ZIndex = f._config.DisplayOrderOffset;
				end;
				k.Name = "PseudoWindowScreenGui";
				k.Parent = j;
				local l;
				if f._config.UseScreenGUIs then
					l = Instance.new("ScreenGui");
					l.ResetOnSpawn = false;
					l.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
					l.DisplayOrder = f._config.DisplayOrderOffset + 1024;
					l.IgnoreGuiInset = f._config.IgnoreGuiInset;
				else
					l = Instance.new("Frame");
					l.AnchorPoint = Vector2.new(0.5, 0.5);
					l.Position = UDim2.new(0.5, 0, 0.5, 0);
					l.Size = UDim2.new(1, 0, 1, 0);
					l.BackgroundTransparency = 1;
					l.ZIndex = f._config.DisplayOrderOffset + 1024;
				end;
				l.Name = "PopupScreenGui";
				l.Parent = j;
				local o = Instance.new("Frame");
				o.Name = "TooltipContainer";
				o.AutomaticSize = Enum.AutomaticSize.XY;
				o.Size = UDim2.fromOffset(0, 0);
				o.BackgroundTransparency = 1;
				o.BorderSizePixel = 0;
				g.UIListLayout(o, Enum.FillDirection.Vertical, UDim.new(0, f._config.PopupBorderSize));
				o.Parent = l;
				local p = Instance.new("Frame");
				p.Name = "MenuBarContainer";
				p.AutomaticSize = Enum.AutomaticSize.Y;
				p.Size = UDim2.fromScale(1, 0);
				p.BackgroundTransparency = 1;
				p.BorderSizePixel = 0;
				p.Parent = l;
				local q = Instance.new("Frame");
				q.Name = "PseudoWindow";
				q.Size = UDim2.new(0, 0, 0, 0);
				q.Position = UDim2.fromOffset(0, 22);
				q.AutomaticSize = Enum.AutomaticSize.XY;
				q.BackgroundTransparency = f._config.WindowBgTransparency;
				q.BackgroundColor3 = f._config.WindowBgColor;
				q.BorderSizePixel = f._config.WindowBorderSize;
				q.BorderColor3 = f._config.BorderColor;
				q.Selectable = false;
				q.SelectionGroup = true;
				q.SelectionBehaviorUp = Enum.SelectionBehavior.Stop;
				q.SelectionBehaviorDown = Enum.SelectionBehavior.Stop;
				q.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop;
				q.SelectionBehaviorRight = Enum.SelectionBehavior.Stop;
				q.Visible = false;
				g.UIPadding(q, f._config.WindowPadding);
				g.UIListLayout(q, Enum.FillDirection.Vertical, UDim.new(0, f._config.ItemSpacing.Y));
				q.Parent = k;
				return j;
			end,
			Update = function(i)
				if h > 0 then
					local j = i.Instance;
					local k = j.PseudoWindowScreenGui;
					local l = k.PseudoWindow;
					l.Visible = true;
				end;
			end,
			Discard = function(i)
				h = 0;
				i.Instance:Destroy();
			end,
			ChildAdded = function(i, j)
				local k = i.Instance;
				if j.type == "Window" then
					return i.Instance;
				elseif j.type == "Tooltip" then
					return k.PopupScreenGui.TooltipContainer;
				elseif j.type == "MenuBar" then
					return k.PopupScreenGui.MenuBarContainer;
				else
					local l = k.PseudoWindowScreenGui;
					local o = l.PseudoWindow;
					h = h + 1;
					o.Visible = true;
					return o;
				end;
			end,
			ChildDiscarded = function(i, j)
				if j.type ~= "Window" and j.type ~= "Tooltip" and j.type ~= "MenuBar" then
					h = h - 1;
					if h == 0 then
						local k = i.Instance;
						local l = k.PseudoWindowScreenGui;
						local o = l.PseudoWindow;
						o.Visible = false;
					end;
				end;
			end
		});
	end;
end);
c("demoWindow", function(aa, ab, ac, e)
	return function(f)
		local g = f.State(true);
		local h = f.State(false);
		local i = f.State(false);
		local j = f.State(false);
		local k = f.State(false);
		local l = f.State(false);
		local o = f.State(false);
		local p = function(p)
			f.PushConfig({
				TextColor = f._config.TextDisabledColor
			});
			local q = f.Text({
				"(?)"
			});
			f.PopConfig();
			f.PushConfig({
				ContentWidth = UDim.new(0, 350)
			});
			if q.hovered() then
				f.Tooltip({
					p
				});
			end;
			f.PopConfig();
		end;
		local q = function(q, r)
			f.SameLine();
			do
				f.Text({
					q
				});
				p(r);
			end;
			f.End();
		end;
		local r = {
			Basic = function()
				f.Tree({
					"Basic"
				});
				do
					f.SeparatorText({
						"Basic"
					});
					local r = f.State(1);
					f.Button({
						"Button"
					});
					f.SmallButton({
						"SmallButton"
					});
					f.Text({
						"Text"
					});
					f.TextWrapped({
						string.rep("Text Wrapped ", 5)
					});
					f.TextColored({
						"Colored Text",
						Color3.fromRGB(255, 128, 0)
					});
					f.Text({
						"Rich Text: <b>bold text</b> <i>italic text</i> <u>underline text</u> <s>strikethrough text</s> <font color= \"rgb(240, 40, 10)\">red text</font> <font size=\"32\">bigger text</font>",
						true,
						nil,
						true
					});
					f.SameLine();
					do
						f.RadioButton({
							"Index '1'",
							1
						}, {
							index = r
						});
						f.RadioButton({
							"Index 'two'",
							"two"
						}, {
							index = r
						});
						if (f.RadioButton({
							"Index 'false'",
							false
						}, {
							index = r
						})).active() == false then
							if (f.SmallButton({
								"Select last"
							})).clicked() then
								r:set(false);
							end;
						end;
					end;
					f.End();
					f.Text({
						"The Index is: " .. tostring(r.value)
					});
					f.SeparatorText({
						"Inputs"
					});
					f.InputNum({});
					f.DragNum({});
					f.SliderNum({});
				end;
				f.End();
			end,
			Image = function()
				f.Tree({
					"Image"
				});
				do
					f.SeparatorText({
						"Image Controls"
					});
					local r = f.State("rbxasset://textures/ui/common/robux.png");
					local s = f.State(UDim2.fromOffset(100, 100));
					local t = f.State(Rect.new(0, 0, 0, 0));
					local u = f.State(Enum.ScaleType.Stretch);
					local v = f.State(false);
					local w = f.ComputedState(v, function(w)
						return w and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default;
					end);
					local x = f.State(f._config.ImageColor);
					local y = f.State(f._config.ImageTransparency);
					f.InputColor4({
						"Image Tint"
					}, {
						color = x,
						transparency = y
					});
					f.Combo({
						"Asset"
					}, {
						index = r
					});
					do
						f.Selectable({
							"Robux Small",
							"rbxasset://textures/ui/common/robux.png"
						}, {
							index = r
						});
						f.Selectable({
							"Robux Large",
							"rbxasset://textures//ui/common/robux@3x.png"
						}, {
							index = r
						});
						f.Selectable({
							"Loading Texture",
							"rbxasset://textures//loading/darkLoadingTexture.png"
						}, {
							index = r
						});
						f.Selectable({
							"Hue-Saturation Gradient",
							"rbxasset://textures//TagEditor/huesatgradient.png"
						}, {
							index = r
						});
						f.Selectable({
							"famfamfam.png (WHY?)",
							"rbxasset://textures//TagEditor/famfamfam.png"
						}, {
							index = r
						});
					end;
					f.End();
					f.SliderUDim2({
						"Image Size",
						nil,
						nil,
						UDim2.new(1, 240, 1, 240)
					}, {
						number = s
					});
					f.SliderRect({
						"Image Rect",
						nil,
						nil,
						Rect.new(256, 256, 256, 256)
					}, {
						number = t
					});
					f.Combo({
						"Scale Type"
					}, {
						index = u
					});
					do
						f.Selectable({
							"Stretch",
							Enum.ScaleType.Stretch
						}, {
							index = u
						});
						f.Selectable({
							"Fit",
							Enum.ScaleType.Fit
						}, {
							index = u
						});
						f.Selectable({
							"Crop",
							Enum.ScaleType.Crop
						}, {
							index = u
						});
					end;
					f.End();
					f.Checkbox({
						"Pixelated"
					}, {
						isChecked = v
					});
					f.PushConfig({
						ImageColor = x:get(),
						ImageTransparency = y:get()
					});
					f.Image({
						r:get(),
						s:get(),
						t:get(),
						u:get(),
						w:get()
					});
					f.PopConfig();
					f.SeparatorText({
						"Tile"
					});
					local z = f.State(UDim2.fromScale(0.5, 0.5));
					f.SliderUDim2({
						"Tile Size",
						nil,
						nil,
						UDim2.new(1, 240, 1, 240)
					}, {
						number = z
					});
					f.PushConfig({
						ImageColor = x:get(),
						ImageTransparency = y:get()
					});
					f.Image({
						"rbxasset://textures/grid2.png",
						s:get(),
						nil,
						Enum.ScaleType.Tile,
						w:get(),
						z:get()
					});
					f.PopConfig();
					f.SeparatorText({
						"Slice"
					});
					local A = f.State(1);
					f.SliderNum({
						"Image Slice Scale",
						0.1,
						0.1,
						5
					}, {
						number = A
					});
					f.PushConfig({
						ImageColor = x:get(),
						ImageTransparency = y:get()
					});
					f.Image({
						"rbxasset://textures/ui/chatBubble_blue_notify_bkg.png",
						s:get(),
						nil,
						Enum.ScaleType.Slice,
						w:get(),
						nil,
						Rect.new(12, 12, 56, 56),
						1
					}, A:get());
					f.PopConfig();
					f.SeparatorText({
						"Image Button"
					});
					local B = f.State(0);
					f.SameLine();
					do
						f.PushConfig({
							ImageColor = x:get(),
							ImageTransparency = y:get()
						});
						if (f.ImageButton({
							"rbxasset://textures/AvatarCompatibilityPreviewer/add.png",
							UDim2.fromOffset(20, 20)
						})).clicked() then
							B:set(B.value + 1);
						end;
						f.PopConfig();
						f.Text({
							string.format("Click count: %s", tostring(B.value))
						});
					end;
					f.End();
				end;
				f.End();
			end,
			Selectable = function()
				f.Tree({
					"Selectable"
				});
				do
					local r = f.State(2);
					f.Selectable({
						"Selectable #1",
						1
					}, {
						index = r
					});
					f.Selectable({
						"Selectable #2",
						2
					}, {
						index = r
					});
					if (f.Selectable({
						"Double click Selectable",
						3,
						true
					}, {
						index = r
					})).doubleClicked() then
						r:set(3);
					end;
					f.Selectable({
						"Impossible to select",
						4,
						true
					}, {
						index = r
					});
					if (f.Button({
						"Select last"
					})).clicked() then
						r:set(4);
					end;
					f.Selectable({
						"Independent Selectable"
					});
				end;
				f.End();
			end,
			Combo = function()
				f.Tree({
					"Combo"
				});
				do
					f.PushConfig({
						ContentWidth = UDim.new(1, -200)
					});
					local r = f.State("No Selection");
					local s, t;
					f.SameLine();
					do
						s = f.Checkbox({
							"No Preview"
						});
						t = f.Checkbox({
							"No Button"
						});
						if s.checked() and t.isChecked.value == true then
							t.isChecked:set(false);
						end;
						if t.checked() and s.isChecked.value == true then
							s.isChecked:set(false);
						end;
					end;
					f.End();
					f.Combo({
						"Basic Usage",
						t.isChecked:get(),
						s.isChecked:get()
					}, {
						index = r
					});
					do
						f.Selectable({
							"Select 1",
							"One"
						}, {
							index = r
						});
						f.Selectable({
							"Select 2",
							"Two"
						}, {
							index = r
						});
						f.Selectable({
							"Select 3",
							"Three"
						}, {
							index = r
						});
					end;
					f.End();
					f.ComboArray({
						"Using ComboArray"
					}, {
						index = "No Selection"
					}, {
						"Red",
						"Green",
						"Blue"
					});
					local u = f.State("7 AM");
					f.Combo({
						"Combo with Inner widgets"
					}, {
						index = u
					});
					do
						f.Tree({
							"Morning Shifts"
						});
						do
							f.Selectable({
								"Shift at 7 AM",
								"7 AM"
							}, {
								index = u
							});
							f.Selectable({
								"Shift at 11 AM",
								"11 AM"
							}, {
								index = u
							});
							f.Selectable({
								"Shift at 3 PM",
								"3 PM"
							}, {
								index = u
							});
						end;
						f.End();
						f.Tree({
							"Night Shifts"
						});
						do
							f.Selectable({
								"Shift at 6 PM",
								"6 PM"
							}, {
								index = u
							});
							f.Selectable({
								"Shift at 9 PM",
								"9 PM"
							}, {
								index = u
							});
						end;
						f.End();
					end;
					f.End();
					local v = f.ComboEnum({
						"Using ComboEnum"
					}, {
						index = Enum.UserInputState.Begin
					}, Enum.UserInputState);
					f.Text({
						"Selected: " .. (v.index:get()).Name
					});
					f.PopConfig();
				end;
				f.End();
			end,
			Tree = function()
				f.Tree({
					"Trees"
				});
				do
					f.Tree({
						"Tree using SpanAvailWidth",
						true
					});
					do
						p("SpanAvailWidth determines if the Tree is selectable from its entire with, or only the text area");
					end;
					f.End();
					local r = f.Tree({
						"Tree with Children"
					});
					do
						f.Text({
							"Im inside the first tree!"
						});
						f.Button({
							"Im a button inside the first tree!"
						});
						f.Tree({
							"Im a tree inside the first tree!"
						});
						do
							f.Text({
								"I am the innermost text!"
							});
						end;
						f.End();
					end;
					f.End();
					f.Checkbox({
						"Toggle above tree"
					}, {
						isChecked = r.state.isUncollapsed
					});
				end;
				f.End();
			end,
			CollapsingHeader = function()
				f.Tree({
					"Collapsing Headers"
				});
				do
					f.CollapsingHeader({
						"A header"
					});
					do
						f.Text({
							"This is under the first header!"
						});
					end;
					f.End();
					local r = f.State(false);
					f.CollapsingHeader({
						"Another header"
					}, {
						isUncollapsed = r
					});
					do
						if (f.Button({
							"Shhh... secret button!"
						})).clicked() then
							r:set(true);
						end;
					end;
					f.End();
				end;
				f.End();
			end,
			Group = function()
				f.Tree({
					"Groups"
				});
				do
					f.SameLine();
					do
						f.Group();
						do
							f.Text({
								"I am in group A"
							});
							f.Button({
								"Im also in A"
							});
						end;
						f.End();
						f.Separator();
						f.Group();
						do
							f.Text({
								"I am in group B"
							});
							f.Button({
								"Im also in B"
							});
							f.Button({
								"Also group B"
							});
						end;
						f.End();
					end;
					f.End();
				end;
				f.End();
			end,
			Tab = function()
				f.Tree({
					"Tabs"
				});
				do
					f.Tree({
						"Simple"
					});
					do
						f.TabBar();
						do
							f.Tab({
								"Apples"
							});
							do
								f.Text({
									"Who loves apples?"
								});
							end;
							f.End();
							f.Tab({
								"Broccoli"
							});
							do
								f.Text({
									"And what about broccoli?"
								});
							end;
							f.End();
							f.Tab({
								"Carrots"
							});
							do
								f.Text({
									"But carrots are the best."
								});
							end;
							f.End();
						end;
						f.End();
						f.Separator();
						f.Text({
							"Very important questions."
						});
					end;
					f.End();
					f.Tree({
						"Closable"
					});
					do
						local r = f.State(true);
						local s = f.State(true);
						local t = f.State(true);
						f.TabBar();
						do
							f.Tab({
								"🍎",
								true
							}, {
								isOpened = r
							});
							do
								f.Text({
									"Who loves apples?"
								});
								if (f.Button({
									"I don't like apples."
								})).clicked() then
									r:set(false);
								end;
							end;
							f.End();
							f.Tab({
								"🥦",
								true
							}, {
								isOpened = s
							});
							do
								f.Text({
									"And what about broccoli?"
								});
								if (f.Button({
									"Not for me."
								})).clicked() then
									s:set(false);
								end;
							end;
							f.End();
							f.Tab({
								"🥕",
								true
							}, {
								isOpened = t
							});
							do
								f.Text({
									"But carrots are the best."
								});
								if (f.Button({
									"I disagree with you."
								})).clicked() then
									t:set(false);
								end;
							end;
							f.End();
						end;
						f.End();
						f.Separator();
						if (f.Button({
							"Actually, let me reconsider it."
						})).clicked() then
							r:set(true);
							s:set(true);
							t:set(true);
						end;
					end;
					f.End();
				end;
				f.End();
			end,
			Indent = function()
				f.Tree({
					"Indents"
				});
				f.Text({
					"Not Indented"
				});
				f.Indent();
				do
					f.Text({
						"Indented"
					});
					f.Indent({
						7
					});
					do
						f.Text({
							"Indented by 7 more pixels"
						});
						f.End();
						f.Indent({
							-7
						});
						do
							f.Text({
								"Indented by 7 less pixels"
							});
						end;
						f.End();
					end;
					f.End();
				end;
				f.End();
			end,
			Input = function()
				f.Tree({
					"Input"
				});
				do
					local r, s, t, u, v, w = f.State(false), f.State(false), f.State(0), f.State(100), f.State(1), f.State("%d");
					f.PushConfig({
						ContentWidth = UDim.new(1, -120)
					});
					local x = f.InputNum({
						[f.Args.InputNum.Text] = "Input Number",
						[f.Args.InputNum.NoButtons] = s.value,
						[f.Args.InputNum.Min] = t.value,
						[f.Args.InputNum.Max] = u.value,
						[f.Args.InputNum.Increment] = v.value,
						[f.Args.InputNum.Format] = {
							w.value
						}
					});
					f.PopConfig();
					f.Text({
						"The Value is: " .. x.number.value
					});
					if (f.Button({
						"Randomize Number"
					})).clicked() then
						x.number:set(math.random(1, 99));
					end;
					local y = f.Checkbox({
						"NoField"
					}, {
						isChecked = r
					});
					local z = f.Checkbox({
						"NoButtons"
					}, {
						isChecked = s
					});
					if y.checked() and z.isChecked.value == true then
						z.isChecked:set(false);
					end;
					if z.checked() and y.isChecked.value == true then
						y.isChecked:set(false);
					end;
					f.PushConfig({
						ContentWidth = UDim.new(1, -120)
					});
					f.InputVector2({
						"InputVector2"
					});
					f.InputVector3({
						"InputVector3"
					});
					f.InputUDim({
						"InputUDim"
					});
					f.InputUDim2({
						"InputUDim2"
					});
					local A = f.State(false);
					local B = f.State(false);
					local C = f.State(Color3.new());
					local D = f.State(0);
					f.SliderNum({
						"Transparency",
						0.01,
						0,
						1
					}, {
						number = D
					});
					f.InputColor3({
						"InputColor3",
						A:get(),
						B:get()
					}, {
						color = C
					});
					f.InputColor4({
						"InputColor4",
						A:get(),
						B:get()
					}, {
						color = C,
						transparency = D
					});
					f.SameLine();
					f.Text({
						(C:get()):ToHex()
					});
					f.Checkbox({
						"Use Floats"
					}, {
						isChecked = A
					});
					f.Checkbox({
						"Use HSV"
					}, {
						isChecked = B
					});
					f.End();
					f.PopConfig();
					f.Separator();
					f.SameLine();
					do
						f.Text({
							"Slider Numbers"
						});
						p("ctrl + click slider number widgets to input a number");
					end;
					f.End();
					f.PushConfig({
						ContentWidth = UDim.new(1, -120)
					});
					f.SliderNum({
						"Slide Int",
						1,
						1,
						8
					});
					f.SliderNum({
						"Slide Float",
						0.01,
						0,
						100
					});
					f.SliderNum({
						"Small Numbers",
						0.001,
						-2,
						1,
						"%f radians"
					});
					f.SliderNum({
						"Odd Ranges",
						0.001,
						-math.pi,
						math.pi,
						"%f radians"
					});
					f.SliderNum({
						"Big Numbers",
						10000,
						100000,
						10000000
					});
					f.SliderNum({
						"Few Numbers",
						1,
						0,
						3
					});
					f.PopConfig();
					f.Separator();
					f.SameLine();
					do
						f.Text({
							"Drag Numbers"
						});
						p("ctrl + click or double click drag number widgets to input a number, hold shift/alt while dragging to increase/decrease speed");
					end;
					f.End();
					f.PushConfig({
						ContentWidth = UDim.new(1, -120)
					});
					f.DragNum({
						"Drag Int"
					});
					f.DragNum({
						"Slide Float",
						0.001,
						-10,
						10
					});
					f.DragNum({
						"Percentage",
						1,
						0,
						100,
						"%d %%"
					});
					f.PopConfig();
				end;
				f.End();
			end,
			InputText = function()
				f.Tree({
					"Input Text"
				});
				do
					local r = f.InputText({
						"Input Text Test",
						"Input Text here"
					});
					f.Text({
						"The text is: " .. r.text.value
					});
				end;
				f.End();
			end,
			MultiInput = function()
				f.Tree({
					"Multi-Component Input"
				});
				do
					local r = f.State(Vector2.new());
					local s = f.State(Vector3.new());
					local t = f.State(UDim.new());
					local u = f.State(UDim2.new());
					local v = f.State(Color3.new());
					local w = f.State(Rect.new(0, 0, 0, 0));
					f.SeparatorText({
						"Input"
					});
					f.InputVector2({}, {
						number = r
					});
					f.InputVector3({}, {
						number = s
					});
					f.InputUDim({}, {
						number = t
					});
					f.InputUDim2({}, {
						number = u
					});
					f.InputRect({}, {
						number = w
					});
					f.SeparatorText({
						"Drag"
					});
					f.DragVector2({}, {
						number = r
					});
					f.DragVector3({}, {
						number = s
					});
					f.DragUDim({}, {
						number = t
					});
					f.DragUDim2({}, {
						number = u
					});
					f.DragRect({}, {
						number = w
					});
					f.SeparatorText({
						"Slider"
					});
					f.SliderVector2({}, {
						number = r
					});
					f.SliderVector3({}, {
						number = s
					});
					f.SliderUDim({}, {
						number = t
					});
					f.SliderUDim2({}, {
						number = u
					});
					f.SliderRect({}, {
						number = w
					});
					f.SeparatorText({
						"Color"
					});
					f.InputColor3({}, {
						color = v
					});
					f.InputColor4({}, {
						color = v
					});
				end;
				f.End();
			end,
			Tooltip = function()
				f.PushConfig({
					ContentWidth = UDim.new(0, 250)
				});
				f.Tree({
					"Tooltip"
				});
				do
					if (f.Text({
						"Hover over me to reveal a tooltip"
					})).hovered() then
						f.Tooltip({
							"I am some helpful tooltip text"
						});
					end;
					local r = f.State("Hello ");
					local s = f.State(1);
					if (f.InputNum({
						"# of repeat",
						1,
						1,
						50
					}, {
						number = s
					})).numberChanged() then
						r:set(string.rep("Hello ", s:get()));
					end;
					if (f.Checkbox({
						"Show dynamic text tooltip"
					})).state.isChecked.value then
						f.Tooltip({
							r:get()
						});
					end;
				end;
				f.End();
				f.PopConfig();
			end,
			Plotting = function()
				f.Tree({
					"Plotting"
				});
				do
					f.SeparatorText({
						"Progress"
					});
					local r = os.clock() * 15;
					local s = f.State(0);
					local t = math.clamp((math.abs(r % 100 - 50) - 7.5), 0, 35) / 35;
					s:set(t);
					f.ProgressBar({
						"Progress Bar"
					}, {
						progress = s
					});
					f.ProgressBar({
						"Progress Bar",
						string.format("%s/1753", tostring(math.floor(s:get() * 1753)))
					}, {
						progress = s
					});
					f.SeparatorText({
						"Graphs"
					});
					do
						local u = f.State({
							0.5,
							0.8,
							0.2,
							0.9,
							0.1,
							0.6,
							0.4,
							0.7,
							0.3,
							0
						});
						f.PlotHistogram({
							"Histogram",
							100,
							0,
							1,
							"random"
						}, {
							values = u
						});
						f.PlotLines({
							"Lines",
							100,
							0,
							1,
							"random"
						}, {
							values = u
						});
					end;
					do
						local u = f.State("Cos");
						local v = f.State(37);
						local w = f.State(0);
						local x = f.State({});
						local y = f.State(0);
						local z = f.Checkbox({
							"Animate"
						});
						local A = f.ComboArray({
							"Plotting Function"
						}, {
							index = u
						}, {
							"Sin",
							"Cos",
							"Tan",
							"Saw"
						});
						local B = f.SliderNum({
							"Samples",
							1,
							1,
							145,
							"%d samples"
						}, {
							number = v
						});
						if (f.SliderNum({
							"Baseline",
							0.1,
							-1,
							1
						}, {
							number = w
						})).numberChanged() then
							x:set(x.value, true);
						end;
						if z.state.isChecked.value or A.closed() or B.numberChanged() or #x.value == 0 then
							if z.state.isChecked.value then
								y:set(y.value + f.Internal._deltaTime);
							end;
							local C = math.floor(y.value * 30) - 1;
							local D = u.value;
							table.clear(x.value);
							for E = 1, v.value do
								if D == "Sin" then
									x.value[E] = math.sin(math.rad(5 * (E + C)));
								elseif D == "Cos" then
									x.value[E] = math.cos(math.rad(5 * (E + C)));
								elseif D == "Tan" then
									x.value[E] = math.tan(math.rad(5 * (E + C)));
								elseif D == "Saw" then
									x.value[E] = E % 2 == C % 2 and 1 or (-1);
								end;
							end;
							x:set(x.value, true);
						end;
						f.PlotHistogram({
							"Histogram",
							100,
							-1,
							1,
							"",
							w:get()
						}, {
							values = x
						});
						f.PlotLines({
							"Lines",
							100,
							-1,
							1
						}, {
							values = x
						});
					end;
				end;
				f.End();
			end
		};
		local s = {
			"Basic",
			"Image",
			"Selectable",
			"Combo",
			"Tree",
			"CollapsingHeader",
			"Group",
			"Tab",
			"Indent",
			"Input",
			"MultiInput",
			"InputText",
			"Tooltip",
			"Plotting"
		};
		local function recursiveTree()
			local t = f.Tree({
				"Recursive Tree"
			});
			do
				if t.state.isUncollapsed.value then
					recursiveTree();
				end;
			end;
			f.End();
		end;
		local function recursiveWindow(t)
			local u;
			f.Window({
				"Recursive Window"
			}, {
				size = f.State(Vector2.new(175, 100)),
				isOpened = t
			});
			do
				u = f.Checkbox({
					"Recurse Again"
				});
			end;
			f.End();
			if u.isChecked.value then
				recursiveWindow(u.isChecked);
			end;
		end;
		local t = function()
			local t = f.Window({
				"Runtime Info"
			}, {
				isOpened = i
			});
			do
				local u = f.Internal._lastVDOM;
				local v = f.Internal._states;
				local w = f.State(3);
				local x = f.State(0);
				local y = f.State(os.clock());
				f.SameLine();
				do
					f.InputNum({
						[f.Args.InputNum.Text] = "",
						[f.Args.InputNum.Format] = "%d Seconds",
						[f.Args.InputNum.Max] = 10
					}, {
						number = w
					});
					if (f.Button({
						"Disable"
					})).clicked() then
						f.Disabled = true;
						task.delay(w:get(), function()
							f.Disabled = false;
						end);
					end;
				end;
				f.End();
				local z = os.clock();
				local A = z - y.value;
				x.value = x.value + (A - x.value) * 0.2;
				y.value = z;
				f.Text({
					string.format("Average %.3f ms/frame (%.1f FPS)", x.value * 1000, 1 / x.value)
				});
				f.Text({
					string.format("Window Position: (%d, %d), Window Size: (%d, %d)", t.position.value.X, t.position.value.Y, t.size.value.X, t.size.value.Y)
				});
				f.SameLine();
				do
					f.Text({
						"Enter an ID to learn more about it."
					});
					p("every widget and state has an ID which Iris tracks to remember which widget is which. below lists all widgets and states, with their respective IDs");
				end;
				f.End();
				f.PushConfig({
					ItemWidth = UDim.new(1, -150)
				});
				local B = (f.InputText({
					"ID field"
				}, {
					text = f.State(t.ID)
				})).state.text.value;
				f.PopConfig();
				f.Indent();
				do
					local C = u[B];
					local D = v[B];
					if C then
						f.Table({
							1
						});
						f.Text({
							string.format("The ID, \"%s\", is a widget", B)
						});
						f.NextRow();
						f.Text({
							string.format("Widget is type: %s", C.type)
						});
						f.NextRow();
						f.Tree({
							"Widget has Args:"
						}, {
							isUncollapsed = f.State(true)
						});
						for E, F in C.arguments do
							f.Text({
								E .. " - " .. tostring(F)
							});
						end;
						f.End();
						f.NextRow();
						if C.state then
							f.Tree({
								"Widget has State:"
							}, {
								isUncollapsed = f.State(true)
							});
							for E, F in C.state do
								f.Text({
									E .. " - " .. tostring(F.value)
								});
							end;
							f.End();
						end;
						f.End();
					elseif D then
						f.Table({
							1
						});
						f.Text({
							string.format("The ID, \"%s\", is a state", B)
						});
						f.NextRow();
						f.Text({
							string.format("Value is type: %s, Value = %s", typeof(D.value), tostring(D.value))
						});
						f.NextRow();
						f.Tree({
							"state has connected widgets:"
						}, {
							isUncollapsed = f.State(true)
						});
						for E, F in D.ConnectedWidgets do
							f.Text({
								E .. " - " .. F.type
							});
						end;
						f.End();
						f.NextRow();
						f.Text({
							string.format("state has: %d connected functions", #D.ConnectedFunctions)
						});
						f.End();
					else
						f.Text({
							string.format("The ID, \"%s\", is not a state or widget", B)
						});
					end;
				end;
				f.End();
				if (f.Tree({
					"Widgets"
				})).state.isUncollapsed.value then
					local C = 0;
					local D = "";
					for E, F in u do
						C = C + 1;
						D = D .. "\n" .. F.ID .. " - " .. F.type;
					end;
					f.Text({
						"Number of Widgets: " .. C
					});
					f.Text({
						D
					});
				end;
				f.End();
				if (f.Tree({
					"States"
				})).state.isUncollapsed.value then
					local C = 0;
					local D = "";
					for E, F in v do
						C = C + 1;
						D = D .. "\n" .. E .. " - " .. tostring(F.value);
					end;
					f.Text({
						"Number of States: " .. C
					});
					f.Text({
						D
					});
				end;
				f.End();
			end;
			f.End();
		end;
		local u = function()
			f.Window({
				"Debug Panel"
			}, {
				isOpened = o
			});
			do
				f.CollapsingHeader({
					"Widgets"
				});
				do
					f.SeparatorText({
						"GuiService"
					});
					f.Text({
						string.format("GuiOffset: %s", tostring(f.Internal._utility.GuiOffset))
					});
					f.Text({
						string.format("MouseOffset: %s", tostring(f.Internal._utility.MouseOffset))
					});
					f.SeparatorText({
						"UserInputService"
					});
					f.Text({
						string.format("MousePosition: %s", tostring(f.Internal._utility.UserInputService:GetMouseLocation()))
					});
					f.Text({
						string.format("MouseLocation: %s", tostring(f.Internal._utility.getMouseLocation()))
					});
					f.Text({
						string.format("Left Control: %s", tostring(f.Internal._utility.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)))
					});
					f.Text({
						string.format("Right Control: %s", tostring(f.Internal._utility.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)))
					});
				end;
				f.End();
			end;
			f.End();
		end;
		local function recursiveMenu()
			if (f.Menu({
				"Recursive"
			})).state.isOpened.value then
				f.MenuItem({
					"New",
					Enum.KeyCode.N,
					Enum.ModifierKey.Ctrl
				});
				f.MenuItem({
					"Open",
					Enum.KeyCode.O,
					Enum.ModifierKey.Ctrl
				});
				f.MenuItem({
					"Save",
					Enum.KeyCode.S,
					Enum.ModifierKey.Ctrl
				});
				f.Separator();
				f.MenuToggle({
					"Autosave"
				});
				f.MenuToggle({
					"Checked"
				});
				f.Separator();
				f.Menu({
					"Options"
				});
				f.MenuItem({
					"Red"
				});
				f.MenuItem({
					"Yellow"
				});
				f.MenuItem({
					"Green"
				});
				f.MenuItem({
					"Blue"
				});
				f.Separator();
				recursiveMenu();
				f.End();
			end;
			f.End();
		end;
		local v = function()
			f.MenuBar();
			do
				f.Menu({
					"File"
				});
				do
					f.MenuItem({
						"New",
						Enum.KeyCode.N,
						Enum.ModifierKey.Ctrl
					});
					f.MenuItem({
						"Open",
						Enum.KeyCode.O,
						Enum.ModifierKey.Ctrl
					});
					f.MenuItem({
						"Save",
						Enum.KeyCode.S,
						Enum.ModifierKey.Ctrl
					});
					recursiveMenu();
					if (f.MenuItem({
						"Quit",
						Enum.KeyCode.Q,
						Enum.ModifierKey.Alt
					})).clicked() then
						g:set(false);
					end;
				end;
				f.End();
				f.Menu({
					"Examples"
				});
				do
					f.MenuToggle({
						"Recursive Window"
					}, {
						isChecked = h
					});
					f.MenuToggle({
						"Windowless"
					}, {
						isChecked = k
					});
					f.MenuToggle({
						"Main Menu Bar"
					}, {
						isChecked = l
					});
				end;
				f.End();
				f.Menu({
					"Tools"
				});
				do
					f.MenuToggle({
						"Runtime Info"
					}, {
						isChecked = i
					});
					f.MenuToggle({
						"Style Editor"
					}, {
						isChecked = j
					});
					f.MenuToggle({
						"Debug Panel"
					}, {
						isChecked = o
					});
				end;
				f.End();
			end;
			f.End();
		end;
		local w = function()
			v();
		end;
		local x;
		do
			x = function()
				local y = {
					{
						"Sizing",
						function()
							local y = f.State({});
							f.SameLine();
							do
								if (f.Button({
									"Update"
								})).clicked() then
									f.UpdateGlobalConfig(y.value);
									y:set({});
								end;
								p("Update the global config with these changes.");
							end;
							f.End();
							local z = function(z, A)
								local B = f[z](A, {
									number = f.WeakState(f._config[A[1]])
								});
								if B.numberChanged() then
									y.value[A[1]] = B.number:get();
								end;
							end;
							local A = function(A)
								local B = f.Checkbox(A, {
									isChecked = f.WeakState(f._config[A[1]])
								});
								if B.checked() or B.unchecked() then
									y.value[A[1]] = B.isChecked:get();
								end;
							end;
							f.SeparatorText({
								"Main"
							});
							z("SliderVector2", {
								"WindowPadding",
								nil,
								Vector2.zero,
								Vector2.new(20, 20)
							});
							z("SliderVector2", {
								"WindowResizePadding",
								nil,
								Vector2.zero,
								Vector2.new(20, 20)
							});
							z("SliderVector2", {
								"FramePadding",
								nil,
								Vector2.zero,
								Vector2.new(20, 20)
							});
							z("SliderVector2", {
								"ItemSpacing",
								nil,
								Vector2.zero,
								Vector2.new(20, 20)
							});
							z("SliderVector2", {
								"ItemInnerSpacing",
								nil,
								Vector2.zero,
								Vector2.new(20, 20)
							});
							z("SliderVector2", {
								"CellPadding",
								nil,
								Vector2.zero,
								Vector2.new(20, 20)
							});
							z("SliderNum", {
								"IndentSpacing",
								1,
								0,
								36
							});
							z("SliderNum", {
								"ScrollbarSize",
								1,
								0,
								20
							});
							z("SliderNum", {
								"GrabMinSize",
								1,
								0,
								20
							});
							f.SeparatorText({
								"Borders & Rounding"
							});
							z("SliderNum", {
								"FrameBorderSize",
								0.1,
								0,
								1
							});
							z("SliderNum", {
								"WindowBorderSize",
								0.1,
								0,
								1
							});
							z("SliderNum", {
								"PopupBorderSize",
								0.1,
								0,
								1
							});
							z("SliderNum", {
								"SeparatorTextBorderSize",
								1,
								0,
								20
							});
							z("SliderNum", {
								"FrameRounding",
								1,
								0,
								12
							});
							z("SliderNum", {
								"GrabRounding",
								1,
								0,
								12
							});
							z("SliderNum", {
								"PopupRounding",
								1,
								0,
								12
							});
							f.SeparatorText({
								"Widgets"
							});
							z("SliderVector2", {
								"DisplaySafeAreaPadding",
								nil,
								Vector2.zero,
								Vector2.new(20, 20)
							});
							z("SliderVector2", {
								"SeparatorTextPadding",
								nil,
								Vector2.zero,
								Vector2.new(36, 36)
							});
							z("SliderUDim", {
								"ItemWidth",
								nil,
								UDim.new(),
								UDim.new(1, 200)
							});
							z("SliderUDim", {
								"ContentWidth",
								nil,
								UDim.new(),
								UDim.new(1, 200)
							});
							z("SliderNum", {
								"ImageBorderSize",
								1,
								0,
								12
							});
							local B = f.ComboEnum({
								"WindowTitleAlign"
							}, {
								index = f.WeakState(f._config.WindowTitleAlign)
							}, Enum.LeftRight);
							if B.closed() then
								y.value.WindowTitleAlign = B.index:get();
							end;
							A({
								"RichText"
							});
							A({
								"TextWrapped"
							});
							f.SeparatorText({
								"Config"
							});
							A({
								"UseScreenGUIs"
							});
							z("DragNum", {
								"DisplayOrderOffset",
								1,
								0
							});
							z("DragNum", {
								"ZIndexOffset",
								1,
								0
							});
							z("SliderNum", {
								"MouseDoubleClickTime",
								0.1,
								0,
								5
							});
							z("SliderNum", {
								"MouseDoubleClickMaxDist",
								0.1,
								0,
								20
							});
						end
					},
					{
						"Colors",
						function()
							local y = f.State({});
							f.SameLine();
							do
								if (f.Button({
									"Update"
								})).clicked() then
									f.UpdateGlobalConfig(y.value);
									y:set({});
								end;
								p("Update the global config with these changes.");
							end;
							f.End();
							local z = {
								"Text",
								"TextDisabled",
								"WindowBg",
								"PopupBg",
								"Border",
								"BorderActive",
								"ScrollbarGrab",
								"TitleBg",
								"TitleBgActive",
								"TitleBgCollapsed",
								"MenubarBg",
								"FrameBg",
								"FrameBgHovered",
								"FrameBgActive",
								"Button",
								"ButtonHovered",
								"ButtonActive",
								"Image",
								"SliderGrab",
								"SliderGrabActive",
								"Header",
								"HeaderHovered",
								"HeaderActive",
								"SelectionImageObject",
								"SelectionImageObjectBorder",
								"TableBorderStrong",
								"TableBorderLight",
								"TableRowBg",
								"TableRowBgAlt",
								"NavWindowingHighlight",
								"NavWindowingDimBg",
								"Separator",
								"CheckMark"
							};
							for A, B in z do
								local C = f.InputColor4({
									B
								}, {
									color = f.WeakState(f._config[B .. "Color"]),
									transparency = f.WeakState(f._config[B .. "Transparency"])
								});
								if C.numberChanged() then
									y.value[B .. "Color"] = C.color:get();
									y.value[B .. "Transparency"] = C.transparency:get();
								end;
							end;
						end
					},
					{
						"Fonts",
						function()
							local y = f.State({});
							f.SameLine();
							do
								if (f.Button({
									"Update"
								})).clicked() then
									f.UpdateGlobalConfig(y.value);
									y:set({});
								end;
								p("Update the global config with these changes.");
							end;
							f.End();
							local z = {
								["Code (default)"] = Font.fromEnum(Enum.Font.Code),
							};
							f.Text({
								string.format("Current Font: %s Weight: %s Style: %s", tostring(f._config.TextFont.Family), tostring(f._config.TextFont.Weight), tostring(f._config.TextFont.Style))
							});
							f.SeparatorText({
								"Size"
							});
							local A = f.SliderNum({
								"Font Size",
								1,
								4,
								20
							}, {
								number = f.WeakState(f._config.TextSize)
							});
							if A.numberChanged() then
								y.value.TextSize = A.state.number:get();
							end;
							f.SeparatorText({
								"Properties"
							});
							local B = f.WeakState(f._config.TextFont.Family);
							local C = f.ComboEnum({
								"Font Weight"
							}, {
								index = f.WeakState(f._config.TextFont.Weight)
							}, Enum.FontWeight);
							local D = f.ComboEnum({
								"Font Style"
							}, {
								index = f.WeakState(f._config.TextFont.Style)
							}, Enum.FontStyle);
							f.SeparatorText({
								"Fonts"
							});
							for E, F in z do
								F = Font.new(F.Family, C.state.index.value, D.state.index.value);
								f.SameLine();
								do
									f.PushConfig({
										TextFont = F
									});
									if (f.Selectable({
										string.format("%s | \"The quick brown fox jumps over the lazy dog.\"", tostring(E)),
										F.Family
									}, {
										index = B
									})).selected() then
										y.value.TextFont = F;
									end;
									f.PopConfig();
								end;
								f.End();
							end;
						end
					}
				};
				f.Window({
					"Style Editor"
				}, {
					isOpened = j
				});
				do
					f.Text({
						"Customize the look of Iris in realtime."
					});
					local z = f.State("Dark Theme");
					if (f.ComboArray({
						"Theme"
					}, {
						index = z
					}, {
						"Dark Theme",
						"Light Theme"
					})).closed() then
						if z.value == "Dark Theme" then
							f.UpdateGlobalConfig(f.TemplateConfig.colorDark);
						elseif z.value == "Light Theme" then
							f.UpdateGlobalConfig(f.TemplateConfig.colorLight);
						end;
					end;
					local A = f.State("Classic Size");
					if (f.ComboArray({
						"Size"
					}, {
						index = A
					}, {
						"Classic Size",
						"Larger Size"
					})).closed() then
						if A.value == "Classic Size" then
							f.UpdateGlobalConfig(f.TemplateConfig.sizeDefault);
						elseif A.value == "Larger Size" then
							f.UpdateGlobalConfig(f.TemplateConfig.sizeClear);
						end;
					end;
					f.SameLine();
					do
						if (f.Button({
							"Revert"
						})).clicked() then
							f.UpdateGlobalConfig(f.TemplateConfig.colorDark);
							f.UpdateGlobalConfig(f.TemplateConfig.sizeDefault);
							z:set("Dark Theme");
							A:set("Classic Size");
						end;
						p("Reset Iris to the default theme and size.");
					end;
					f.End();
					f.TabBar();
					do
						for B, C in ipairs(y) do
							f.Tab({
								C[1]
							});
							do
								y[B][2]();
							end;
							f.End();
						end;
					end;
					f.End();
					f.Separator();
				end;
				f.End();
			end;
		end;
		local y = function()
			f.CollapsingHeader({
				"Widget Event Interactivity"
			});
			do
				local y = f.State(0);
				if (f.Button({
					"Click to increase Number"
				})).clicked() then
					y:set(y:get() + 1);
				end;
				f.Text({
					"The Number is: " .. y:get()
				});
				f.Separator();
				local z = f.State(false);
				local A = f.State("clicked");
				f.SameLine();
				do
					f.RadioButton({
						"clicked",
						"clicked"
					}, {
						index = A
					});
					f.RadioButton({
						"rightClicked",
						"rightClicked"
					}, {
						index = A
					});
					f.RadioButton({
						"doubleClicked",
						"doubleClicked"
					}, {
						index = A
					});
					f.RadioButton({
						"ctrlClicked",
						"ctrlClicked"
					}, {
						index = A
					});
				end;
				f.End();
				f.SameLine();
				do
					local B = f.Button({
						A:get() .. " to reveal text"
					});
					if B[A:get()]() then
						z:set(not z:get());
					end;
					if z:get() then
						f.Text({
							"Here i am!"
						});
					end;
				end;
				f.End();
				f.Separator();
				local B = f.State(0);
				f.SameLine();
				do
					if (f.Button({
						"Click to show text for 20 frames"
					})).clicked() then
						B:set(20);
					end;
					if B:get() > 0 then
						f.Text({
							"Here i am!"
						});
					end;
				end;
				f.End();
				B:set(math.max(0, B:get() - 1));
				f.Text({
					"Text Timer: " .. B:get()
				});
				local C = f.Checkbox({
					"Event-tracked checkbox"
				});
				f.Indent();
				do
					f.Text({
						"unchecked: " .. tostring(C.unchecked())
					});
					f.Text({
						"checked: " .. tostring(C.checked())
					});
				end;
				f.End();
				f.SameLine();
				do
					if (f.Button({
						"Hover over me"
					})).hovered() then
						f.Text({
							"The button is hovered"
						});
					end;
				end;
				f.End();
			end;
			f.End();
		end;
		local z = function()
			f.CollapsingHeader({
				"Widget State Interactivity"
			});
			do
				local z = f.Checkbox({
					"Widget-Generated State"
				});
				f.Text({
					string.format("isChecked: %s\n", tostring(z.state.isChecked.value))
				});
				local A = f.State(false);
				local B = f.Checkbox({
					"User-Generated State"
				}, {
					isChecked = A
				});
				f.Text({
					string.format("isChecked: %s\n", tostring(B.state.isChecked.value))
				});
				local C = f.Checkbox({
					"Widget Coupled State"
				});
				local D = f.Checkbox({
					"Coupled to above Checkbox"
				}, {
					isChecked = C.state.isChecked
				});
				f.Text({
					string.format("isChecked: %s\n", tostring(D.state.isChecked.value))
				});
				local E = f.State(false);
				f.Checkbox({
					"Widget and Code Coupled State"
				}, {
					isChecked = E
				});
				local F = f.Button({
					"Click to toggle above checkbox"
				});
				if F.clicked() then
					E:set(not E:get());
				end;
				f.Text({
					string.format("isChecked: %s\n", tostring(E.value))
				});
				local G = f.State(true);
				local H = f.ComputedState(G, function(H)
					return not H;
				end);
				f.Checkbox({
					"ComputedState (dynamic coupling)"
				}, {
					isChecked = G
				});
				f.Checkbox({
					"Inverted of above checkbox"
				}, {
					isChecked = H
				});
				f.Text({
					string.format("isChecked: %s\n", tostring(H.value))
				});
			end;
			f.End();
		end;
		local A = function()
			f.CollapsingHeader({
				"Dynamic Styles"
			});
			do
				local A = f.State(0);
				f.SameLine();
				do
					if (f.Button({
						"Change Color"
					})).clicked() then
						A:set(math.random());
					end;
					f.Text({
						"Hue: " .. math.floor(A:get() * 255)
					});
					p("Using PushConfig with a changing value, this can be done with any config field");
				end;
				f.End();
				f.PushConfig({
					TextColor = Color3.fromHSV(A:get(), 1, 1)
				});
				f.Text({
					"Text with a unique and changable color"
				});
				f.PopConfig();
			end;
			f.End();
		end;
		local B = function()
			local B = f.State(false);
			f.CollapsingHeader({
				"Tables & Columns"
			}, {
				isUncollapsed = B
			});
			if B.value == false then
				f.End();
			else
				f.SameLine();
				do
					f.Text({
						"Table using NextRow and NextColumn syntax:"
					});
					p("calling Iris.NextRow() in the outer loop, and Iris.NextColumn()in the inner loop");
				end;
				f.End();
				f.Table({
					3
				});
				do
					for C = 1, 4 do
						f.NextRow();
						for D = 1, 3 do
							f.NextColumn();
							f.Text({
								string.format("Row: %s, Column: %s", tostring(C), tostring(D))
							});
						end;
					end;
				end;
				f.End();
				f.Text({
					""
				});
				f.SameLine();
				do
					f.Text({
						"Table using NextColumn only syntax:"
					});
					p("only calling Iris.NextColumn() in the inner loop, the result is identical");
				end;
				f.End();
				f.Table({
					2
				});
				do
					for C = 1, 4 do
						for D = 1, 2 do
							f.NextColumn();
							f.Text({
								string.format("Row: %s, Column: %s", tostring(C), tostring(D))
							});
						end;
					end;
				end;
				f.End();
				f.Separator();
				local C = f.State(false);
				local D = f.State(false);
				local E = f.State(true);
				local F = f.State(true);
				local G = f.State(3);
				f.Text({
					"Table with Customizable Arguments"
				});
				f.Table({
					[f.Args.Table.NumColumns] = 4,
					[f.Args.Table.RowBg] = C.value,
					[f.Args.Table.BordersOuter] = D.value,
					[f.Args.Table.BordersInner] = E.value
				});
				do
					for H = 1, G:get() do
						for I = 1, 4 do
							f.NextColumn();
							if F.value then
								f.Button({
									string.format("Month: %s, Week: %s", tostring(H), tostring(I))
								});
							else
								f.Text({
									string.format("Month: %s, Week: %s", tostring(H), tostring(I))
								});
							end;
						end;
					end;
				end;
				f.End();
				f.Checkbox({
					"RowBg"
				}, {
					isChecked = C
				});
				f.Checkbox({
					"BordersOuter"
				}, {
					isChecked = D
				});
				f.Checkbox({
					"BordersInner"
				}, {
					isChecked = E
				});
				f.SameLine();
				do
					f.RadioButton({
						"Buttons",
						true
					}, {
						index = F
					});
					f.RadioButton({
						"Text",
						false
					}, {
						index = F
					});
				end;
				f.End();
				f.InputNum({
					[f.Args.InputNum.Text] = "Number of rows",
					[f.Args.InputNum.Min] = 0,
					[f.Args.InputNum.Max] = 100,
					[f.Args.InputNum.Format] = "%d"
				}, {
					number = G
				});
				f.End();
			end;
		end;
		local C = function()
			f.CollapsingHeader({
				"Widget Layout"
			});
			do
				f.Tree({
					"Widget Alignment"
				});
				do
					f.Text({
						"Iris.SameLine has optional argument supporting horizontal and vertical alignments."
					});
					f.Text({
						"This allows widgets to be place anywhere on the line."
					});
					f.Separator();
					f.SameLine();
					do
						f.Text({
							"By default child widgets will be aligned to the left."
						});
						p("Iris.SameLine()\n\tIris.Button({ \"Button A\" })\n\tIris.Button({ \"Button B\" })\nIris.End()");
					end;
					f.End();
					f.SameLine();
					do
						f.Button({
							"Button A"
						});
						f.Button({
							"Button B"
						});
					end;
					f.End();
					f.SameLine();
					do
						f.Text({
							"But can be aligned to the center."
						});
						p("Iris.SameLine({ nil, nil, Enum.HorizontalAlignment.Center })\n\tIris.Button({ \"Button A\" })\n\tIris.Button({ \"Button B\" })\nIris.End()");
					end;
					f.End();
					f.SameLine({
						nil,
						nil,
						Enum.HorizontalAlignment.Center
					});
					do
						f.Button({
							"Button A"
						});
						f.Button({
							"Button B"
						});
					end;
					f.End();
					f.SameLine();
					do
						f.Text({
							"Or right."
						});
						p("Iris.SameLine({ nil, nil, Enum.HorizontalAlignment.Right })\n\tIris.Button({ \"Button A\" })\n\tIris.Button({ \"Button B\" })\nIris.End()");
					end;
					f.End();
					f.SameLine({
						nil,
						nil,
						Enum.HorizontalAlignment.Right
					});
					do
						f.Button({
							"Button A"
						});
						f.Button({
							"Button B"
						});
					end;
					f.End();
					f.Separator();
					f.SameLine();
					do
						f.Text({
							"You can also specify the padding."
						});
						p("Iris.SameLine({ 0, nil, Enum.HorizontalAlignment.Center })\n\tIris.Button({ \"Button A\" })\n\tIris.Button({ \"Button B\" })\nIris.End()");
					end;
					f.End();
					f.SameLine({
						0,
						nil,
						Enum.HorizontalAlignment.Center
					});
					do
						f.Button({
							"Button A"
						});
						f.Button({
							"Button B"
						});
					end;
					f.End();
				end;
				f.End();
				f.Tree({
					"Widget Sizing"
				});
				do
					f.Text({
						"Nearly all widgets are the minimum size of the content."
					});
					f.Text({
						"For example, text and button widgets will be the size of the text labels."
					});
					f.Text({
						"Some widgets, such as the Image and Button have Size arguments will will set the size of them."
					});
					f.Separator();
					q("The button takes up the full screen-width.", "Iris.Button({ \"Button\", UDim2.fromScale(1, 0) })");
					f.Button({
						"Button",
						UDim2.fromScale(1, 0)
					});
					q("The button takes up half the screen-width.", "Iris.Button({ \"Button\", UDim2.fromScale(0.5, 0) })");
					f.Button({
						"Button",
						UDim2.fromScale(0.5, 0)
					});
					q("Combining with SameLine, the buttons can fill the screen width.", "The button will still be larger that the text size.");
					local C = f.State(2);
					f.SliderNum({
						"Number of Buttons",
						1,
						1,
						8
					}, {
						number = C
					});
					f.SameLine({
						0,
						nil,
						Enum.HorizontalAlignment.Center
					});
					do
						for D = 1, C.value do
							f.Button({
								string.format("Button %s", tostring(D)),
								UDim2.fromScale(1 / C.value, 0)
							});
						end;
					end;
					f.End();
				end;
				f.End();
				f.Tree({
					"Content Width"
				});
				do
					local C = f.State(50);
					local D = f.State(Enum.Axis.X);
					f.Text({
						"The Content Width is a size property which determines the width of input fields."
					});
					f.SameLine();
					do
						f.Text({
							"By default the value is UDim.new(0.65, 0)"
						});
						p("This is the default value from Dear ImGui.It is 65% of the window width.");
					end;
					f.End();
					f.Text({
						"This works well, but sometimes we know how wide elements are going to be and want to maximise the space."
					});
					f.Text({
						"Therefore, we can use Iris.PushConfig() to change the width"
					});
					f.Separator();
					f.SameLine();
					do
						f.Text({
							"Content Width = 150 pixels"
						});
						p("UDim.new(0, 150)");
					end;
					f.End();
					f.PushConfig({
						ContentWidth = UDim.new(0, 150)
					});
					f.DragNum({
						"number",
						1,
						0,
						100
					}, {
						number = C
					});
					f.InputEnum({
						"axis"
					}, {
						index = D
					}, Enum.Axis);
					f.PopConfig();
					f.SameLine();
					do
						f.Text({
							"Content Width = 50% window width"
						});
						p("UDim.new(0.5, 0)");
					end;
					f.End();
					f.PushConfig({
						ContentWidth = UDim.new(0.5, 0)
					});
					f.DragNum({
						"number",
						1,
						0,
						100
					}, {
						number = C
					});
					f.InputEnum({
						"axis"
					}, {
						index = D
					}, Enum.Axis);
					f.PopConfig();
					f.SameLine();
					do
						f.Text({
							"Content Width = -150 pixels from the right side"
						});
						p("UDim.new(1, -150)");
					end;
					f.End();
					f.PushConfig({
						ContentWidth = UDim.new(1, -150)
					});
					f.DragNum({
						"number",
						1,
						0,
						100
					}, {
						number = C
					});
					f.InputEnum({
						"axis"
					}, {
						index = D
					}, Enum.Axis);
					f.PopConfig();
				end;
				f.End();
				f.Tree({
					"Content Height"
				});
				do
					local C = f.State("a single line");
					local D = f.State(50);
					local E = f.State(Enum.Axis.X);
					local F = f.State(0);
					local G = math.clamp((math.abs(os.clock() * 15 % 100 - 50) - 7.5), 0, 35) / 35;
					F:set(G);
					f.Text({
						"The Content Height is a size property that determines the minimum size of certain widgets."
					});
					f.Text({
						"By default the value is UDim.new(0, 0), so there is no minimum height."
					});
					f.Text({
						"We use Iris.PushConfig() to change this value."
					});
					f.Separator();
					f.SameLine();
					do
						f.Text({
							"Content Height = 0 pixels"
						});
						p("UDim.new(0, 0)");
					end;
					f.End();
					f.InputText({
						"text"
					}, {
						text = C
					});
					f.ProgressBar({
						"progress"
					}, {
						progress = F
					});
					f.DragNum({
						"number",
						1,
						0,
						100
					}, {
						number = D
					});
					f.ComboEnum({
						"axis"
					}, {
						index = E
					}, Enum.Axis);
					f.SameLine();
					do
						f.Text({
							"Content Height = 60 pixels"
						});
						p("UDim.new(0, 60)");
					end;
					f.End();
					f.PushConfig({
						ContentHeight = UDim.new(0, 60)
					});
					f.InputText({
						"text",
						nil,
						nil,
						true
					}, {
						text = C
					});
					f.ProgressBar({
						"progress"
					}, {
						progress = F
					});
					f.DragNum({
						"number",
						1,
						0,
						100
					}, {
						number = D
					});
					f.ComboEnum({
						"axis"
					}, {
						index = E
					}, Enum.Axis);
					f.PopConfig();
					f.Text({
						"This property can be used to force the height of a text box."
					});
					f.Text({
						"Just make sure you enable the MultiLine argument."
					});
				end;
				f.End();
			end;
			f.End();
		end;
		local D = function()
			f.PushConfig({
				ItemWidth = UDim.new(0, 150)
			});
			f.SameLine();
			do
				f.TextWrapped({
					"Windowless widgets"
				});
				p("Widgets which are placed outside of a window will appear on the top left side of the screen.");
			end;
			f.End();
			f.Button({});
			f.Tree({});
			do
				f.InputText({});
			end;
			f.End();
			f.PopConfig();
		end;
		return function()
			local E = f.State(false);
			local F = f.State(false);
			local G = f.State(false);
			local H = f.State(true);
			local I = f.State(false);
			local J = f.State(false);
			local K = f.State(false);
			local L = f.State(false);
			local M = f.State(false);
			if g.value == false then
				f.Checkbox({
					"Open main window"
				}, {
					isChecked = g
				});
				return;
			end;
			local N = f.Window({
				[f.Args.Window.Title] = "Iris Demo Window",
				[f.Args.Window.NoTitleBar] = E.value,
				[f.Args.Window.NoBackground] = F.value,
				[f.Args.Window.NoCollapse] = G.value,
				[f.Args.Window.NoClose] = H.value,
				[f.Args.Window.NoMove] = I.value,
				[f.Args.Window.NoScrollbar] = J.value,
				[f.Args.Window.NoResize] = K.value,
				[f.Args.Window.NoNav] = L.value,
				[f.Args.Window.NoMenu] = M.value
			}, {
				size = f.State(Vector2.new(600, 550)),
				position = f.State(Vector2.new(100, 25)),
				isOpened = g
			});
			if N.state.isUncollapsed.value and N.state.isOpened.value then
				v();
				f.Text({
					"Iris says hello. (" .. f.Internal._version .. ")"
				});
				f.CollapsingHeader({
					"Window Options"
				});
				do
					f.Table({
						3,
						false,
						false,
						false
					});
					do
						f.NextColumn();
						f.Checkbox({
							"NoTitleBar"
						}, {
							isChecked = E
						});
						f.NextColumn();
						f.Checkbox({
							"NoBackground"
						}, {
							isChecked = F
						});
						f.NextColumn();
						f.Checkbox({
							"NoCollapse"
						}, {
							isChecked = G
						});
						f.NextColumn();
						f.Checkbox({
							"NoClose"
						}, {
							isChecked = H
						});
						f.NextColumn();
						f.Checkbox({
							"NoMove"
						}, {
							isChecked = I
						});
						f.NextColumn();
						f.Checkbox({
							"NoScrollbar"
						}, {
							isChecked = J
						});
						f.NextColumn();
						f.Checkbox({
							"NoResize"
						}, {
							isChecked = K
						});
						f.NextColumn();
						f.Checkbox({
							"NoNav"
						}, {
							isChecked = L
						});
						f.NextColumn();
						f.Checkbox({
							"NoMenu"
						}, {
							isChecked = M
						});
					end;
					f.End();
				end;
				f.End();
				y();
				z();
				f.CollapsingHeader({
					"Recursive Tree"
				});
				recursiveTree();
				f.End();
				A();
				f.Separator();
				f.CollapsingHeader({
					"Widgets"
				});
				do
					for O, P in s do
						r[P]();
					end;
				end;
				f.End();
				B();
				C();
			end;
			f.End();
			if h.value then
				recursiveWindow(h);
			end;
			if i.value then
				t();
			end;
			if o.value then
				u();
			end;
			if j.value then
				x();
			end;
			if k.value then
				D();
			end;
			if l.value then
				w();
			end;
			return N;
		end;
	end;
end);
c("config", function(aa, ab, ac, e)
	local f = {
		colorDark = {
			TextColor = Color3.fromRGB(200, 200, 200),
			TextTransparency = 0,
			TextDisabledColor = Color3.fromRGB(120, 120, 120),
			TextDisabledTransparency = 0,
			BorderColor = Color3.fromRGB(60, 60, 60),
			BorderActiveColor = Color3.fromRGB(100, 100, 100),
			BorderTransparency = 0.4,
			BorderActiveTransparency = 0.3,
			WindowBgColor = Color3.fromRGB(30, 30, 30),
			WindowBgTransparency = 0.06,
			PopupBgColor = Color3.fromRGB(40, 40, 40),
			PopupBgTransparency = 0.06,
			ScrollbarGrabColor = Color3.fromRGB(90, 90, 90),
			ScrollbarGrabTransparency = 0,
			TitleBgColor = Color3.fromRGB(20, 20, 20),
			TitleBgTransparency = 0,
			TitleBgActiveColor = Color3.fromRGB(60, 60, 60),
			TitleBgActiveTransparency = 0,
			TitleBgCollapsedColor = Color3.fromRGB(10, 10, 10),
			TitleBgCollapsedTransparency = 0.5,
			MenubarBgColor = Color3.fromRGB(40, 40, 40),
			MenubarBgTransparency = 0,
			FrameBgColor = Color3.fromRGB(50, 50, 50),
			FrameBgTransparency = 0.46,
			FrameBgHoveredColor = Color3.fromRGB(80, 80, 80),
			FrameBgHoveredTransparency = 0.46,
			FrameBgActiveColor = Color3.fromRGB(80, 80, 80),
			FrameBgActiveTransparency = 0.33,
			ButtonColor = Color3.fromRGB(70, 70, 70),
			ButtonTransparency = 0.6,
			ButtonHoveredColor = Color3.fromRGB(90, 90, 90),
			ButtonHoveredTransparency = 0,
			ButtonActiveColor = Color3.fromRGB(50, 50, 50),
			ButtonActiveTransparency = 0,
			ImageColor = Color3.fromRGB(200, 200, 200),
			ImageTransparency = 0,
			SliderGrabColor = Color3.fromRGB(90, 90, 90),
			SliderGrabTransparency = 0,
			SliderGrabActiveColor = Color3.fromRGB(100, 100, 100),
			SliderGrabActiveTransparency = 0,
			HeaderColor = Color3.fromRGB(70, 70, 70),
			HeaderTransparency = 0.69,
			HeaderHoveredColor = Color3.fromRGB(80, 80, 80),
			HeaderHoveredTransparency = 0.2,
			HeaderActiveColor = Color3.fromRGB(90, 90, 90),
			HeaderActiveTransparency = 0,
			TabColor = Color3.fromRGB(50, 50, 50),
			TabTransparency = 0.14,
			TabHoveredColor = Color3.fromRGB(70, 70, 70),
			TabHoveredTransparency = 0.2,
			TabActiveColor = Color3.fromRGB(60, 60, 60),
			TabActiveTransparency = 0,
			SelectionImageObjectColor = Color3.fromRGB(200, 200, 200),
			SelectionImageObjectTransparency = 0.8,
			SelectionImageObjectBorderColor = Color3.fromRGB(200, 200, 200),
			SelectionImageObjectBorderTransparency = 0,
			TableBorderStrongColor = Color3.fromRGB(50, 50, 50),
			TableBorderStrongTransparency = 0,
			TableBorderLightColor = Color3.fromRGB(60, 60, 60),
			TableBorderLightTransparency = 0,
			TableRowBgColor = Color3.fromRGB(10, 10, 10),
			TableRowBgTransparency = 1,
			TableRowBgAltColor = Color3.fromRGB(30, 30, 30),
			TableRowBgAltTransparency = 0.94,
			NavWindowingHighlightColor = Color3.fromRGB(200, 200, 200),
			NavWindowingHighlightTransparency = 0.3,
			NavWindowingDimBgColor = Color3.fromRGB(100, 100, 100),
			NavWindowingDimBgTransparency = 0.65,
			SeparatorColor = Color3.fromRGB(60, 60, 60),
			SeparatorTransparency = 0.5,
			CheckMarkColor = Color3.fromRGB(70, 70, 70),
			CheckMarkTransparency = 0,
			PlotLinesColor = Color3.fromRGB(130, 130, 130),
			PlotLinesTransparency = 0,
			PlotLinesHoveredColor = Color3.fromRGB(200, 90, 80),
			PlotLinesHoveredTransparency = 0,
			PlotHistogramColor = Color3.fromRGB(180, 130, 0),
			PlotHistogramTransparency = 0,
			PlotHistogramHoveredColor = Color3.fromRGB(220, 150, 0),
			PlotHistogramHoveredTransparency = 0,
			ResizeGripColor = Color3.fromRGB(90, 90, 90),
			ResizeGripTransparency = 0.8,
			ResizeGripHoveredColor = Color3.fromRGB(90, 90, 90),
			ResizeGripHoveredTransparency = 0.33,
			ResizeGripActiveColor = Color3.fromRGB(90, 90, 90),
			ResizeGripActiveTransparency = 0.05
		},
		colorLight = {
			TextColor = Color3.fromRGB(20, 20, 20),
			TextTransparency = 0,
			TextDisabledColor = Color3.fromRGB(120, 120, 120),
			TextDisabledTransparency = 0,
			BorderColor = Color3.fromRGB(80, 80, 80),
			BorderActiveColor = Color3.fromRGB(100, 100, 100),
			BorderTransparency = 0.3,
			BorderActiveTransparency = 0.2,
			WindowBgColor = Color3.fromRGB(255, 255, 255),
			WindowBgTransparency = 0,
			PopupBgColor = Color3.fromRGB(240, 240, 240),
			PopupBgTransparency = 0.05,
			TitleBgColor = Color3.fromRGB(220, 220, 220),
			TitleBgTransparency = 0,
			TitleBgActiveColor = Color3.fromRGB(200, 200, 200),
			TitleBgActiveTransparency = 0,
			TitleBgCollapsedColor = Color3.fromRGB(220, 220, 220),
			TitleBgCollapsedTransparency = 0.5,
			MenubarBgColor = Color3.fromRGB(210, 210, 210),
			MenubarBgTransparency = 0,
			ScrollbarGrabColor = Color3.fromRGB(150, 150, 150),
			ScrollbarGrabTransparency = 0,
			FrameBgColor = Color3.fromRGB(240, 240, 240),
			FrameBgTransparency = 0.8,
			FrameBgHoveredColor = Color3.fromRGB(200, 200, 200),
			FrameBgHoveredTransparency = 0.6,
			FrameBgActiveColor = Color3.fromRGB(180, 180, 180),
			FrameBgActiveTransparency = 0.4,
			ButtonColor = Color3.fromRGB(200, 200, 200),
			ButtonTransparency = 0.6,
			ButtonHoveredColor = Color3.fromRGB(180, 180, 180),
			ButtonHoveredTransparency = 0,
			ButtonActiveColor = Color3.fromRGB(160, 160, 160),
			ButtonActiveTransparency = 0,
			ImageColor = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 0,
			HeaderColor = Color3.fromRGB(200, 200, 200),
			HeaderTransparency = 0.35,
			HeaderHoveredColor = Color3.fromRGB(180, 180, 180),
			HeaderHoveredTransparency = 0.25,
			HeaderActiveColor = Color3.fromRGB(160, 160, 160),
			HeaderActiveTransparency = 0,
			TabColor = Color3.fromRGB(220, 220, 220),
			TabTransparency = 0.1,
			TabHoveredColor = Color3.fromRGB(200, 200, 200),
			TabHoveredTransparency = 0.2,
			TabActiveColor = Color3.fromRGB(180, 180, 180),
			TabActiveTransparency = 0,
			SliderGrabColor = Color3.fromRGB(150, 150, 150),
			SliderGrabTransparency = 0,
			SliderGrabActiveColor = Color3.fromRGB(120, 120, 120),
			SliderGrabActiveTransparency = 0,
			SelectionImageObjectColor = Color3.fromRGB(40, 40, 40),
			SelectionImageObjectTransparency = 0.7,
			SelectionImageObjectBorderColor = Color3.fromRGB(80, 80, 80),
			SelectionImageObjectBorderTransparency = 0,
			TableBorderStrongColor = Color3.fromRGB(100, 100, 100),
			TableBorderStrongTransparency = 0,
			TableBorderLightColor = Color3.fromRGB(150, 150, 150),
			TableBorderLightTransparency = 0,
			TableRowBgColor = Color3.fromRGB(255, 255, 255),
			TableRowBgTransparency = 0.9,
			TableRowBgAltColor = Color3.fromRGB(240, 240, 240),
			TableRowBgAltTransparency = 0.85,
			NavWindowingHighlightColor = Color3.fromRGB(180, 180, 180),
			NavWindowingHighlightTransparency = 0.2,
			NavWindowingDimBgColor = Color3.fromRGB(30, 30, 30),
			NavWindowingDimBgTransparency = 0.7,
			SeparatorColor = Color3.fromRGB(150, 150, 150),
			SeparatorTransparency = 0.3,
			CheckMarkColor = Color3.fromRGB(20, 20, 20),
			CheckMarkTransparency = 0,
			PlotLinesColor = Color3.fromRGB(100, 100, 100),
			PlotLinesTransparency = 0,
			PlotLinesHoveredColor = Color3.fromRGB(50, 50, 50),
			PlotLinesHoveredTransparency = 0,
			PlotHistogramColor = Color3.fromRGB(120, 120, 120),
			PlotHistogramTransparency = 0,
			PlotHistogramHoveredColor = Color3.fromRGB(80, 80, 80),
			PlotHistogramHoveredTransparency = 0,
			ResizeGripColor = Color3.fromRGB(150, 150, 150),
			ResizeGripTransparency = 0.75,
			ResizeGripHoveredColor = Color3.fromRGB(120, 120, 120),
			ResizeGripHoveredTransparency = 0.3,
			ResizeGripActiveColor = Color3.fromRGB(100, 100, 100),
			ResizeGripActiveTransparency = 0.1		
		},
		sizeDefault = {
			ItemWidth = UDim.new(1, 0),
			ContentWidth = UDim.new(0.65, 0),
			ContentHeight = UDim.new(0, 0),
			WindowPadding = Vector2.new(8, 8),
			WindowResizePadding = Vector2.new(6, 6),
			FramePadding = Vector2.new(4, 3),
			ItemSpacing = Vector2.new(8, 4),
			ItemInnerSpacing = Vector2.new(4, 4),
			CellPadding = Vector2.new(4, 2),
			DisplaySafeAreaPadding = Vector2.new(0, 0),
			SeparatorTextPadding = Vector2.new(20, 3),
			IndentSpacing = 21,
			TextFont = Font.fromEnum(Enum.Font.Code),
			TextSize = 13,
			FrameBorderSize = 0,
			FrameRounding = 0,
			GrabRounding = 0,
			WindowRounding = 0,
			WindowBorderSize = 1,
			WindowTitleAlign = Enum.LeftRight.Left,
			PopupBorderSize = 1,
			PopupRounding = 0,
			ScrollbarSize = 7,
			GrabMinSize = 10,
			SeparatorTextBorderSize = 3,
			ImageBorderSize = 2
		},
		sizeClear = {
			ItemWidth = UDim.new(1, 0),
			ContentWidth = UDim.new(0.65, 0),
			ContentHeight = UDim.new(0, 0),
			WindowPadding = Vector2.new(12, 8),
			WindowResizePadding = Vector2.new(8, 8),
			FramePadding = Vector2.new(6, 4),
			ItemSpacing = Vector2.new(8, 8),
			ItemInnerSpacing = Vector2.new(8, 8),
			CellPadding = Vector2.new(4, 4),
			DisplaySafeAreaPadding = Vector2.new(8, 8),
			SeparatorTextPadding = Vector2.new(24, 6),
			IndentSpacing = 25,
			TextFont = Font.fromEnum(Enum.Font.Ubuntu),
			TextSize = 15,
			FrameBorderSize = 1,
			FrameRounding = 4,
			GrabRounding = 4,
			WindowRounding = 4,
			WindowBorderSize = 1,
			WindowTitleAlign = Enum.LeftRight.Center,
			PopupBorderSize = 1,
			PopupRounding = 4,
			ScrollbarSize = 9,
			GrabMinSize = 14,
			SeparatorTextBorderSize = 4,
			ImageBorderSize = 4
		},
		utilityDefault = {
			UseScreenGUIs = true,
			IgnoreGuiInset = false,
			Parent = nil,
			RichText = false,
			TextWrapped = false,
			DisplayOrderOffset = 127,
			ZIndexOffset = 0,
			MouseDoubleClickTime = 0.3,
			MouseDoubleClickMaxDist = 6,
			HoverColor = Color3.fromRGB(255, 255, 0),
			HoverTransparency = 0.1
		}
	};
	return f;
end);
c("Internal", function(aa, ab, ac, e)
	local f = game:GetService("HttpService");
	return function(g)
		local h = {};
		h._version = " 2.4.1 ";
		h._started = false;
		h._shutdown = false;
		h._cycleTick = 0;
		h._deltaTime = 0;
		h._globalRefreshRequested = false;
		h._localRefreshActive = false;
		h._widgets = {};
		h._stackIndex = 1;
		h._rootInstance = nil;
		h._rootWidget = {
			ID = "R",
			type = "Root",
			Instance = h._rootInstance,
			ZIndex = 0,
			ZOffset = 0
		};
		h._lastWidget = h._rootWidget;
		h._rootConfig = {};
		h._config = h._rootConfig;
		h._IDStack = {
			"R"
		};
		h._usedIDs = {};
		h._pushedId = nil;
		h._nextWidgetId = nil;
		h._states = {};
		h._postCycleCallbacks = {};
		h._connectedFunctions = {};
		h._connections = {};
		h._initFunctions = {};
		h._fullErrorTracebacks = (game:GetService("RunService")):IsStudio();
		h._cycleCoroutine = coroutine.create(function()
			while h._started do
				for i, j in h._connectedFunctions do
					local k, l = pcall(j);
					if not k then
						h._stackIndex = 1;
						coroutine.yield(false, l);
					end;
				end;
				coroutine.yield(true);
			end;
		end);
		local i = {};
		i.__index = i;
		function i.get(j)
			return j.value;
		end;
		function i.set(j, k, l)
			if k == j.value and l ~= true then
				return j.value;
			end;
			j.value = k;
			j.lastChangeTick = g.Internal._cycleTick;
			for o, p in j.ConnectedWidgets do
				h._widgets[p.type].UpdateState(p);
			end;
			for o, p in j.ConnectedFunctions do
				p(k);
			end;
			return j.value;
		end;
		function i.onChange(j, k)
			local l = (#j.ConnectedFunctions) + 1;
			j.ConnectedFunctions[l] = k;
			return function()
				j.ConnectedFunctions[l] = nil;
			end;
		end;
		function i.changed(j)
			return j.lastChangeTick + 1 == h._cycleTick;
		end;
		h.StateClass = i;
		function h._cycle(j)
			if g.Disabled then
				return;
			end;
			h._rootWidget.lastCycleTick = h._cycleTick;
			if h._rootInstance == nil or h._rootInstance.Parent == nil then
				g.ForceRefresh();
			end;
			for k, l in h._lastVDOM do
				if l.lastCycleTick ~= h._cycleTick and l.lastCycleTick ~= (-1) then
					h._DiscardWidget(l);
				end;
			end;
			setmetatable(h._lastVDOM, {
				__mode = "kv"
			});
			h._lastVDOM = h._VDOM;
			h._VDOM = h._generateEmptyVDOM();
			task.spawn(function()
				for k, l in h._postCycleCallbacks do
					l();
				end;
			end);
			if h._globalRefreshRequested then
				h._generateSelectionImageObject();
				h._globalRefreshRequested = false;
				for k, l in h._lastVDOM do
					h._DiscardWidget(l);
				end;
				h._generateRootInstance();
				h._lastVDOM = h._generateEmptyVDOM();
			end;
			h._cycleTick = h._cycleTick + 1;
			h._deltaTime = j;
			table.clear(h._usedIDs);
			local k = h.parentInstance:IsA("GuiBase2d") or h.parentInstance:IsA("CoreGui") or h.parentInstance:IsA("PluginGui") or h.parentInstance:IsA("PlayerGui");
			if k == false then
				error("The Iris parent instance will not display any GUIs.");
			end;
			if h._fullErrorTracebacks then
				for l, o in h._connectedFunctions do
					o();
				end;
			else
				local l = coroutine.status(h._cycleCoroutine);
				if l == "suspended" then
					local o, p, q = coroutine.resume(h._cycleCoroutine);
					if p == false then
						error(q, 0);
					end;
				elseif l == "running" then
					error("Iris cycleCoroutine took to long to yield. Connected functions should not yield.");
				else
					error("unrecoverable state");
				end;
			end;
			if h._stackIndex ~= 1 then
				h._stackIndex = 1;
				error("Too few calls to Iris.End().", 0);
			end;
		end;
		function h._NoOp()
		end;
		function h.WidgetConstructor(j, k)
			local l = {
				All = {
					Required = {
						"Generate",
						"Discard",
						"Update",
						"Args",
						"Events",
						"hasChildren",
						"hasState"
					},
					Optional = {}
				},
				IfState = {
					Required = {
						"GenerateState",
						"UpdateState"
					},
					Optional = {}
				},
				IfChildren = {
					Required = {
						"ChildAdded"
					},
					Optional = {
						"ChildDiscarded"
					}
				}
			};
			local o = {};
			for p, q in l.All.Required do
				local r = k[q] ~= nil;
				o[q] = k[q];
			end;
			for p, q in l.All.Optional do
				if k[q] == nil then
					o[q] = h._NoOp;
				else
					o[q] = k[q];
				end;
			end;
			if k.hasState then
				for p, q in l.IfState.Required do
					local r = k[q] ~= nil;
					o[q] = k[q];
				end;
				for p, q in l.IfState.Optional do
					if k[q] == nil then
						o[q] = h._NoOp;
					else
						o[q] = k[q];
					end;
				end;
			end;
			if k.hasChildren then
				for p, q in l.IfChildren.Required do
					local r = k[q] ~= nil;
					o[q] = k[q];
				end;
				for p, q in l.IfChildren.Optional do
					if k[q] == nil then
						o[q] = h._NoOp;
					else
						o[q] = k[q];
					end;
				end;
			end;
			h._widgets[j] = o;
			g.Args[j] = o.Args;
			local p = {};
			for q, r in o.Args do
				p[r] = q;
			end;
			o.ArgNames = p;
			for q, r in o.Events do
				if g.Events[q] == nil then
					g.Events[q] = function()
						return h._EventCall(h._lastWidget, q);
					end;
				end;
			end;
		end;
		function h._Insert(j, k, l)
			local o = h._getID(3);
			local p = h._widgets[j];
			if h._VDOM[o] then
				return h._ContinueWidget(o, j);
			end;
			local q = {};
			if k ~= nil then
				if type(k) ~= "table" then
					k = {
						k
					};
				end;
				for r, s in k do
					do
						local t = r > 0;
						string.format("Widget Arguments must be a positive number, not %s of type %s for %s.", tostring(r), tostring(typeof(r)), tostring(s));
					end;
					q[p.ArgNames[r]] = s;
				end;
			end;
			table.freeze(q);
			local r = h._lastVDOM[o];
			if r and j == r.type then
				if h._localRefreshActive then
					h._DiscardWidget(r);
					r = nil;
				end;
			end;
			local s = (r == nil and {
				h._GenNewWidget(j, q, l, o)
			} or {
				r
			})[1];
			local t = s.parentWidget;
			if s.type ~= "Window" and s.type ~= "Tooltip" then
				if s.ZIndex ~= t.ZOffset then
					t.ZUpdate = true;
				end;
				if t.ZUpdate then
					s.ZIndex = t.ZOffset;
					if s.Instance then
						s.Instance.ZIndex = s.ZIndex;
						s.Instance.LayoutOrder = s.ZIndex;
					end;
				end;
			end;
			if h._deepCompare(s.providedArguments, q) == false then
				s.arguments = h._deepCopy(q);
				s.providedArguments = q;
				p.Update(s);
			end;
			s.lastCycleTick = h._cycleTick;
			t.ZOffset = t.ZOffset + 1;
			if p.hasChildren then
				local u = s;
				u.ZOffset = 0;
				u.ZUpdate = false;
				h._stackIndex = h._stackIndex + 1;
				h._IDStack[h._stackIndex] = s.ID;
			end;
			h._VDOM[o] = s;
			h._lastWidget = s;
			return s;
		end;
		function h._GenNewWidget(j, k, l, o)
			local p = h._IDStack[h._stackIndex];
			local q = h._VDOM[p];
			local r = h._widgets[j];
			local s = {};
			setmetatable(s, s);
			s.ID = o;
			s.type = j;
			s.parentWidget = q;
			s.trackedEvents = {};
			s.UID = (f:GenerateGUID(false)):sub(0, 8);
			s.ZIndex = q.ZOffset;
			s.Instance = r.Generate(s);
			q = s.parentWidget;
			if h._config.Parent then
				s.Instance.Parent = h._config.Parent;
			else
				s.Instance.Parent = h._widgets[q.type].ChildAdded(q, s);
			end;
			s.providedArguments = k;
			s.arguments = h._deepCopy(k);
			r.Update(s);
			local t;
			if r.hasState then
				local u = s;
				if l then
					for v, w in l do
						if not (type(w) == "table" and getmetatable(w) == h.StateClass) then
							l[v] = h._widgetState(u, v, w);
						end;
						l[v].lastChangeTick = h._cycleTick;
					end;
					u.state = l;
					for v, w in l do
						w.ConnectedWidgets[u.ID] = u;
					end;
				else
					u.state = {};
				end;
				r.GenerateState(u);
				r.UpdateState(u);
				u.stateMT = {};
				setmetatable(u.state, u.stateMT);
				u.__index = u.state;
				t = u.stateMT;
			else
				t = s;
			end;
			t.__index = function(u, v)
				return function()
					return h._EventCall(s, v);
				end;
			end;
			return s;
		end;
		function h._ContinueWidget(j, k)
			local l = h._widgets[k];
			local o = h._VDOM[j];
			if l.hasChildren then
				h._stackIndex = h._stackIndex + 1;
				h._IDStack[h._stackIndex] = o.ID;
			end;
			h._lastWidget = o;
			return o;
		end;
		function h._DiscardWidget(j)
			local k = j.parentWidget;
			if k then
				h._widgets[k.type].ChildDiscarded(k, j);
			end;
			h._widgets[j.type].Discard(j);
			j.lastCycleTick = -1;
		end;
		function h._widgetState(j, k, l)
			local o = j.ID .. k;
			if h._states[o] then
				h._states[o].ConnectedWidgets[j.ID] = j;
				h._states[o].lastChangeTick = h._cycleTick;
				return h._states[o];
			else
				h._states[o] = {
					ID = o,
					value = l,
					lastChangeTick = h._cycleTick,
					ConnectedWidgets = {
						[j.ID] = j
					},
					ConnectedFunctions = {}
				};
				setmetatable(h._states[o], h.StateClass);
				return h._states[o];
			end;
		end;
		function h._EventCall(j, k)
			local l = h._widgets[j.type].Events;
			local o = l[k];
			do
				local p = o ~= nil;
				string.format("widget %s has no event of name %s", tostring(j.type), tostring(k));
			end;
			if j.trackedEvents[k] == nil then
				o.Init(j);
				j.trackedEvents[k] = true;
			end;
			return o.Get(j);
		end;
		function h._GetParentWidget()
			return h._VDOM[h._IDStack[h._stackIndex]];
		end;
		function h._generateEmptyVDOM()
			return {
				R = h._rootWidget
			};
		end;
		function h._generateRootInstance()
			h._rootInstance = h._widgets.Root.Generate(h._widgets.Root);
			h._rootInstance.Parent = h.parentInstance;
			h._rootWidget.Instance = h._rootInstance;
		end;
		function h._generateSelectionImageObject()
			if h.SelectionImageObject then
				h.SelectionImageObject:Destroy();
			end;
			local j = Instance.new("Frame");
			j.Position = UDim2.fromOffset(-1, -1);
			j.Size = UDim2.new(1, 2, 1, 2);
			j.BackgroundColor3 = h._config.SelectionImageObjectColor;
			j.BackgroundTransparency = h._config.SelectionImageObjectTransparency;
			j.BorderSizePixel = 0;
			local k = Instance.new("UIStroke");
			k.Thickness = 1;
			k.Color = h._config.SelectionImageObjectBorderColor;
			k.Transparency = h._config.SelectionImageObjectBorderTransparency;
			k.LineJoinMode = Enum.LineJoinMode.Round;
			k.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			k.Parent = j;
			local l = Instance.new("UICorner");
			l.CornerRadius = UDim.new(0, 2);
			l.Parent = j;
			h.SelectionImageObject = j;
		end;
		function h._getID(j)
			if h._nextWidgetId then
				local k = h._nextWidgetId;
				h._nextWidgetId = nil;
				return k;
			end;
			local k = 1 + (j or 1);
			local l = "";
			local o = debug.info(k, "l");
			while o ~= (-1) and o ~= nil do
				l = l .. "+" .. o;
				k = k + 1;
				o = debug.info(k, "l");
			end;
			if h._usedIDs[l] then
				do
					local p = h._usedIDs;
					p[l] = p[l] + 1;
				end;
			else
				h._usedIDs[l] = 1;
			end;
			local p = (h._pushedId and {
				h._pushedId
			} or {
				h._usedIDs[l]
			})[1];
			return l .. ":" .. p;
		end;
		function h._deepCompare(j, k)
			for l, o in j do
				local p = k[l];
				if type(o) == "table" then
					if p and type(p) == "table" then
						if h._deepCompare(o, p) == false then
							return false;
						end;
					else
						return false;
					end;
				elseif type(o) ~= type(p) or o ~= p then
					return false;
				end;
			end;
			return true;
		end;
		function h._deepCopy(j)
			local k = table.clone(j);
			for l, o in pairs(j) do
				if type(o) == "table" then
					k[l] = h._deepCopy(o);
				end;
			end;
			return k;
		end;
		h._lastVDOM = h._generateEmptyVDOM();
		h._VDOM = h._generateEmptyVDOM();
		g.Internal = h;
		g._config = h._config;
		return h;
	end;
end);
return a("__root");
