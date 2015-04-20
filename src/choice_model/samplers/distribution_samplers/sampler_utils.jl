# find midpoint of a range without causing an overflow to Inf
function robustmidpoint(a::Float64,b::Float64)
	l = min(a,b)
	u = max(a,b)
	if sign(l) == sign(u)
		m = l + (u-l)/2
	else
		m = (u+l)/2
	end
	m
end
