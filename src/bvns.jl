# timeout in minutes
#function bvns(costs, prizes, penalties, timeout, k_max)
#	n = len(prizes)
#	time_limit = Dates.value(now()) + 1000*60*timeout
#	while Dates.value(now()) < time_limit
#		x = find_feasible()
#		k = 0
#		for k in range(1, k_max)
#			x1 = shake(x, k)
#			x2 = bestImprovement()
#			x,k = neighborhoodChange()
#end

function gvns(costs, prizes, penalties, timeout, k_max, l_max)
	best = {"value":-1, "solution":[]}
	length = len(prizes)
	time_limit = Dates.value(now()) + 1000*60*timeout
	while Dates.value(now()) < time_limit 
		neighbor = find_feasible(length)
		if best["value"] < neighbor["value"]
			
		end
		k = 1
		while k < k_max
			x = shake_k(x, k)
			l = 1
			while l < l_max
				x = shake_l(x, l)

			end
		end
	end

function shake_k(x, k)
end

function shake_l(x, k)
end

function neighborhood1()
end

function find_feasible(length)
end