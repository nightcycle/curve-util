--!strict
local Package = script
local Packages = Package.Parent

local Vector = require(Packages:WaitForChild("Vector"))

export type Vector = Vector.Vector
export type Alpha = number
export type BezierSolver<T> = (alpha: Alpha) -> T

local CurveUtil = {}
CurveUtil.__index = CurveUtil

local Lerp = require(script.Lerp)
function CurveUtil.lerp<T>(a: T, b: T, alpha: Alpha): T
	return Lerp(a, b, alpha)
end

local Ease = require(script.Ease)
function CurveUtil.ease(alpha: Alpha, easingStyle: Enum.EasingStyle, easingDirection: Enum.EasingDirection): Alpha
	return Ease(alpha, easingStyle, easingDirection)
end

type bezierable = Vector2 | Vector3 | Vector
function CurveUtil.bezier<bezierable>(...): BezierSolver<bezierable>
	local allPoints: { [number]: bezierable} = { ... }
	assert(#allPoints > 1, "not enough points")
	local function solve(alpha: number, points: { [number]: bezierable }): bezierable?
		local newPoints = {}
		local function typeLerp(a: bezierable, b: bezierable, alpha: number): bezierable?
			if typeof(a) == "Vector2" then
				return Lerp(a, b, alpha)
			elseif typeof(a) == "Vector3" then
				return Lerp(a, b, alpha)
			elseif typeof(a) == "table" and getmetatable(a) == Vector then
				return Lerp(a, b, alpha)
			end
			return nil
		end

		for i = 1, #points - 1 do
			local a: bezierable = points[i]
			local b: bezierable = points[i + 1]
			local result: bezierable? = typeLerp(a, b, alpha)
			if result ~= nil then
				table.insert(newPoints, result)
			end
		end
		if #newPoints <= 1 then
			return newPoints[1]
		else
			return solve(alpha, newPoints)
		end
	end

	return function(alpha: Alpha): bezierable
		assert(allPoints ~= nil)
		local result: bezierable? = solve(alpha, allPoints)
		assert(result ~= nil)
		return result
	end
end
return CurveUtil
