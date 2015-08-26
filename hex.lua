require('utils.class')

-- ============================================================================================
-- http.//www.redblobgames.com/grids/hexagons/
-- 六宫格的Lua实现
-- Authors.XavierCHN
-- Date.20150826
-- ============================================================================================



-- ============================================================================================
-- 1 坐标系
-- 本文使用方块坐标系来表示六边形网格坐标
-- 关于方块坐标系请查看此文章：
-- http.//www.redblobgames.com/grids/hexagons/#coordinates
-- ============================================================================================


-- ============================================================================================
-- 1.1 the hex class
-- ============================================================================================
if hex == nil then hex = class({
    q = nil,
    r = nil,
    s = nil,

    -- 1.1 构造函数
    -- @param q number x坐标，方块坐标系
    -- @param r number y坐标，方块坐标系
    -- @return hex
    --
    constructor = function(self, q, r)
        self.q = q
        self.r = r
        self.s = - q - r
    end,

    -- 输出六边形网格信息
    -- @return string
    __tostring = function(self)
        return string.format("Hexagon(%s, %s, %s)", self.q, self.r, self.s)
    end,

    -- 判断相等
    -- @param hex_b hex 另一个网格
    -- @return boolean
    __eq = function(self, hex_b)
        return self.q == hex_b.q and self.r == hex_b.r and self.s == hex_b.s
    end,

    -- 加法
    -- @param hex_b hex 另一个网格
    -- @return hex
    __add = function(self, hex_b)
        return hex(self.q + hex_b.q, self.r + hex_b.r, self.s + hex_b.s)
    end,

    -- 减法
    -- @param hex_b hex 另一个网格
    -- @return hex
    __sub = function(self, hex_b)
        return hex(self.q - hex_b.q, self.r - hex_b.r, self.s - hex_b.s)
    end,

    -- 乘法
    -- @param int_k number
    -- @return hex
    __mul = function(self, int_k)
        return hex(self.q * int_k, self.r + int_k, self.s + int_k)
    end,

    -- 除法
    -- @param int_k number
    -- @return hex
    __div = function(self, int_k)
        assert(int_k, "error div by 0")
        return hex(self.q / int_k, self.r / int_k, self.s / int_k)
    end,

}) end
-- ============================================================================================



-- ============================================================================================
-- 1.2 加减法
-- ============================================================================================


-- ============================================================================================
-- 加法
-- @param hex_b hex 另一个网格
-- @return hex
function hex.add(self, hex_b)
    return hex(self.q + hex_b.q, self.r + hex_b.r, self.s + hex_b.s)
end
-- 减法
-- @param hex_b hex 另一个网格
-- @return hex
function hex.sub(self, hex_b)
   return hex(self.q - hex_b.q, self.r - hex_b.r, self.s - hex_b.s)
end
-- 乘法
-- @param hex_b hex 另一个网格
-- @return hex
function hex.mul(self, int_k)
    return hex(self.q * int_k, self.r + int_k, self.s + int_k)
end
-- 除法
-- @param int_k number
-- @return hex
function hex.div(self, int_k)
    assert(int_k, "error div by 0")
    return hex(self.q / int_k, self.r / int_k, self.s / int_k)
end
-- ============================================================================================



-- ============================================================================================
-- 1.3 距离与方位关系
-- ============================================================================================


-- ============================================================================================
-- 网格的长度
-- @return number
function hex.length(self)
    return (math.abs(self.q) + math.abs(self.r) + math.abs(self.s)) / 2
end
-- 两个网格之间的距离
-- @return number
function hex.distance(self, hex_b)
    return (self - hex_b):length()
end
-- 一个网格的邻居(用边相邻的)
hex.__hex_directions__ = {
    hex(1,0),hex(1,-1),hex(0,-1),
    hex(-1,0),hex(-1,1),hex(0,1)
}
-- 一个网格的对角线邻居
hex.__hex_diagonals__ = {
    hex(2,-1),hex(1,-2),hex(-1,-1),
    hex(-2,1),hex(-1,2),hex(1,1)
}
-- 获取某个方向
-- 非实例函数
-- @param direction number 1-6的方向数值
-- @return hex
function hex.direction(direction)
    return hex.__hex_directions__[direction]
end

-- 获取某个方向上的邻居
-- @param direction number 1-6的方向数值
-- @return hex
function hex.neighbor(self, direction)
    return self + hex.direction(direction)
end

-- 获取所有邻居
-- @return table
function hex.neighbors(self)
    local results = {}
    for i = 1, 6 do
        table.insert(results, hex.neighbor(self, i))
    end
    return results
end

-- 获取某个方向上的对角线邻居
-- @param direction number 1-6的方向数值
-- @return hex
function hex.diagonal_neighbor(self, direction)
    return self + hex.__hex_diagonals__[direction]
end

-- 获取所有对角线邻居
-- return table
function hex.diagonal_neighbors(self)
    local results = {}
    for i = 1, 6 do
        table.insert(results, hex.diagonal_neighbor(self, i))
    end
    return results
end
-- ============================================================================================



-- ============================================================================================
-- 2 Layout 布局
-- ============================================================================================


-- ============================================================================================
-- 六边形网格的方向类
if hex.orientation == nil then hex.orientation = class({
    constructor = function(self,f0,f1,f2,f3,b0,b1,b2,b3,start_angle)
        self.f0 = f0 self.f1 = f1 self.f2 = f2 self.f3 = f3
        self.b0 = b0 self.b1 = b1 self.b2 = b2 self.b3 = b3
        self.start_angle = start_angle
    end,
}) end
hex.layout_pointy = hex.orientation(math.sqrt(3.0), math.sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0, math.sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 0.5) -- 点在顶部的布局形式
hex.layout_flat = hex.orientation(3.0 / 2.0, 0.0, math.sqrt(3.0) / 2.0, math.sqrt(3.0), 2.0 / 3.0, 0.0, -1.0 / 3.0, math.sqrt(3.0) / 3.0, 0.0) -- 边在顶部的布局形式
-- 六边形网格的布局类
if hex.layout == nil then hex.layout = class({
    -- 布局方式的构造函数
    -- @param orientation hex.layout_pointy 或者 hex.layout_flat
    -- @param size Vector size.x size.y表示每个网格的大小
    -- @param origin Vector 表示原点的位置
    constructor = function(self, orientation, size, origin)
        self.orientation = orientation
        self.size = size
        self.origin = origin
    end,
}) end
-- 如果不是在引擎里面，做一个Vector类，到引擎中可以移除
if GameRules == nil then
    _G.Vector = class({
        constructor = function(self, x, y, z)
            self.x = x self.y = y self.z = z
        end,
        __tostring = function(self)
            return string.format("Vector(%s, %s, %s)", self.x, self.y, self.z)
        end,
    })
end
-- ============================================================================================



-- ============================================================================================
-- 2.1 将六边形网格转换为空间坐标
-- ============================================================================================


-- ============================================================================================
-- 非实例函数
-- @param layout hex.layout 布局
-- @return Vector
function hex.hex_to_pixel(self, layout)
    local M = layout.orientation
    local size = layout.size
    local origin = layout.origin
    local x = (M.f0 * self.q + M.f1 * self.r) * size.x
    local y = (M.f2 * self.q + M.f3 * self.r) * size.y
    return Vector(x + origin.x, y + origin.y, 0)
end
-- ============================================================================================



-- ============================================================================================
-- 2.2 获取某个空间坐标点对应的六边形网格
-- ============================================================================================


-- ============================================================================================
-- 非实例函数
-- @param layout hex.layout 布局
-- @return hex
function hex.raw_pixel_to_hex(layout, p)
    local M = layout.orientation
    local size = layout.size
    local origin = layout.origin
    local pt = Vector((p.x - origin.x) / size.x, (p.y - origin.y) / size.y, 0)
    local q = M.b0 * pt.x + M.b1 * pt.y
    local r = M.b2 * pt.x + M.b3 * pt.y
    return hex(q, r, -q - r)
end
function hex.pixel_to_hex(layout, p)
    return hex.round(hex.raw_pixel_to_hex(layout, p))
end
-- ============================================================================================


-- ============================================================================================
-- 2.3 网格绘制
-- ============================================================================================


-- ============================================================================================
-- 根据布局获取六边形网格某个角点的坐标偏移
-- @param layout hex.layout 布局
-- @param corner 0-5 角点
-- @return Vector
function hex.corner_offset(layout, corner)
    local M = layout.orientation
    local size = layout.size
    local angle = 2.0 * math.pi * (corner + M.start_angle) / 6
    return Vector(size.x * math.cos(angle), size.y * math.sin(angle),0)
end
-- 获取六边形网格的六个角点
-- @param layout hex.layout 布局
-- @return table
function hex.corners(self, layout)
    local corners = {}
    local center = self.hex_to_pixel(self, layout)
    for i = 0, 6 do
        local offset = hex.corner_offset(layout, i)
        table.insert(corners,Vector(center.x + offset.x, center.y + offset.y, 0))
    end
    return corners
end
-- ============================================================================================


-- ============================================================================================
-- 3 非整数网格
-- ============================================================================================


-- ============================================================================================
-- 3.1 将非整数网格四舍五入找到最近的hex
-- ============================================================================================


-- ============================================================================================
--  局部函数，四舍五入
-- @param num number
-- @param n number
-- @return number
local function roundOff(num, n)
    if n > 0 then
        local scale = math.pow(10, n-1)
        return math.floor(num / scale + 0.5) * scale
    elseif n < 0 then
        local scale = math.pow(10, n)
        return math.floor(num / scale + 0.5) * scale
    elseif n == 0 then
        return num
    end
end
-- 将某个非整数网格转换到最近的hex整数网格的方法
-- 非实例函数
-- @param h 要转换的非整数网格
-- @return hex
function hex.round(h)
    local q = roundOff(h.q,1)
    local r = roundOff(h.r,1)
    local s = roundOff(h.s,1)
    local q_diff = math.abs(q - h.q)
    local r_diff = math.abs(r - h.r)
    local s_diff = math.abs(s - h.s)
    if q_diff > r_diff and q_diff > s_diff then
        q = -r - s
    else
        if r_diff > s_diff then
            r = -q - s
        else
            s = -q - r
        end
    end
    return hex(q, r, s)
end
-- ============================================================================================

-- ============================================================================================
-- 3.2 获取一条直线上的所有网格
-- ============================================================================================


-- ============================================================================================
-- 获取 a 往 b 网格方向距离为t的非整数六边形网格
-- @param a hex
-- @param b hex
-- @param t number
-- @return hex
function hex.lerp(a, b, t)
    return hex(a.q + (b.q - a.q) * t, a.r + (b.r - a.r) * t, a.s + (b.s - a.s) * t)
end
-- 从网格A到B方向的所有网格
-- @param b hex
-- @return table
function hex.line_draw(self, b)
    local N = hex.distance(self, b)
    local results = {}
    local step = 1.0 / math.max(N,1)
    for i = 0, N, step do
        local cell = hex.round(hex.lerp(self, b, step * i))
        local has = false
        for k,v in pairs(results) do
            if v == cell then
                has = true
                break
            end
        end
        if not has then table.insert(results, cell) end
    end
    return results
end
-- ============================================================================================

-- 测试
function test()
    local a = hex(5,2)
    local b = hex(2,8)
    print("a =>", a)
    print("b =>", b)
    -- 测试加减乘除
    print("a + b =>", a + b)
    print("a:add(b) =>", a:add(b))
    print("hex.add(a,b) =>", hex.add(a,b))
    print("a - b =>", a - b)
    print("a:sub(b) =>", a:sub(b))
    print("hex.sub(a,b) =>", hex.sub(a,b))
    print("b * 2 =>", b * 2)
    print("b:mul(2) =>", b:mul(2))
    print("hex.mul(b,2) =>", hex.mul(b,2))
    print("b / 2 =>", b / 2)
    print("b:div(2) =>", b:div(2))
    print("hex.div(b,2) =>", hex.div(b,2))
    -- 测试长度与距离
    print("b:length() =>", b:length())
    print("hex.length(b) =>", hex.length(b))
    print("a:distance(b) =>", a:distance(b))
    print("hex.distance(a,b) =>", hex.distance(a,b))
    -- 测试相邻与对角线相邻
    for k, v in pairs(a:neighbors()) do
        print("Neighbors=>",k,v)
    end
    for k,v in pairs(a:diagonal_neighbors()) do
        print("Diagonal Neighbors=>",k,v)
    end
    -- 测试Layout与寻址
    local test_layout = hex.layout( hex.layout_flat, Vector(5,5,0), Vector(0,0,0) )
    print("hex.hex_to_pixel(b, test_layout) =>", hex.hex_to_pixel(b, test_layout))
    print("b:hex_to_pixel(test_layout) =>", b:hex_to_pixel(test_layout))
    print("hex.pixel_to_hex(test_layout, Vector(100.45, 33.33, 0)) =>", hex.pixel_to_hex(test_layout, Vector(100.45, 33.33, 0)))
    for k, v in pairs(hex.corners(b, test_layout)) do
        print("Corners=>", k, v)
    end
    for k, v in pairs(b:corners(test_layout)) do
        print("Corners=>", k, v)
    end
    for k, v in pairs(a:line_draw(b)) do
        print("Line Draw=>",k,v)
    end
end

-- test()

return hex
