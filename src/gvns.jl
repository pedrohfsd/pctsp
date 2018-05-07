include("./reader.jl")

using StatsBase

DEBUG = false

function prin(message)
	if DEBUG
		println(message)
	end
end

function keep_best(counter, candidate, current, printInfo)
	if objective(candidate) < objective(current)
		if printInfo
			prin("Best solution changed to objective: $(objective(candidate)) with tour length: $(length(candidate.tour)) $candidate")
		end
		return (1, candidate)
	end
	return (counter+1, current)
end

function shake_k(solution, k, instance)
	if k==1
		return shake_switch_nodes(solution, instance)
	elseif k==2
		return shake_switch_nodes(shake_swap_nodes(shake_insert_node(solution, instance), instance), instance)
	elseif k==3
		return shake_switch_nodes(shake_swap_nodes(shake_insert_node(solution, instance), instance), instance)
	elseif k==4
		return shake_switch_nodes(shake_swap_nodes(shake_remove_node(solution, instance), instance), instance)
	elseif k==5
		return shake_switch_nodes(shake_swap_nodes(shake_insert_nodes(solution, instance, round(instance.cities_count*0.2)), instance), instance)
	elseif k==6
		return shake_switch_nodes(shake_swap_nodes(shake_remove_nodes(solution, instance, round(instance.cities_count*0.2)), instance), instance)
	elseif k==7
		return shake_switch_nodes(shake_swap_nodes(shake_insert_nodes(solution, instance, round(instance.cities_count*0.4)), instance), instance)
	elseif k==8
		return shake_switch_nodes(shake_swap_nodes(shake_remove_nodes(solution, instance, round(instance.cities_count*0.4)), instance), instance)
#	elseif k==7
#		return shake_insert_nodes(solution, instance, round(instance.cities_count*0.6))
#	elseif k==8
#		return shake_remove_nodes(solution, instance, round(instance.cities_count*0.6))
#	elseif k==9
#		return shake_insert_nodes(solution, instance, round(instance.cities_count*0.8))
#	elseif k==10
#		return shake_remove_nodes(solution, instance, round(instance.cities_count*0.8))
#	elseif k==11
#		return shake_remove_nodes(solution, instance, round(instance.cities_count*0.8))
#	elseif k==7
#		return shake_switch_nodes(solution, instance)
	end
	error("K-Neighborhood k=$k wasn't implemented yet") 
end

function local_search_l(solution, l, instance)
	if l==1
		return swap(solution, instance)
	elseif l==2
		return two_opt(solution, instance)
	end
	error("L-Neighborhood l=$l wasn't implemented yet") 
end

function find_feasible(instance)
	solution = Solution(0, 0, instance.total_penalties, [])
	candidates = sample(1:instance.cities_count, instance.cities_count, replace = false)
	prev = nothing
	for candidate in candidates
		push!(solution.tour, candidate)
		solution.total_prize += instance.prizes[candidate]
		solution.total_penalty -= instance.penalties[candidate]
		if prev != nothing
			solution.total_cost += instance.costs[prev, candidate]
		end
		if solution.total_prize >= instance.minimum_prize
			break
		end
		prev = candidate
	end
	solution.total_cost += instance.costs[solution.tour[end], solution.tour[1]]
	if solution.total_prize < instance.minimum_prize
		error("Problem is infeasible for minimum prize of $minimum_prize")
	end
	return solution
end

function shake_switch_nodes(solution, instance)
	used = Set(solution.tour)
	all = Set(1:instance.cities_count)
	candidates = collect(symdiff(used, all))
	best = solution
	temp_tour = copy(solution.tour)
	for i in 1:length(temp_tour)
		for candidate in candidates
			temp_tour[i], old = candidate, temp_tour[i] # do
			total_prize, total_cost, total_penalty = calculate_tour(temp_tour, instance)
			best_total_prize, best_total_cost, best_total_penalty = calculate_tour(best.tour, instance)
			if objective(total_prize, total_cost, total_penalty) < objective(best_total_prize, best_total_cost, best_total_penalty)
				aux = Solution(total_prize, total_cost, total_penalty, copy(temp_tour))
				if is_feasible(aux, instance)
					best = aux
				end
			end
			temp_tour[i] = old
		end
	end
	return best
end

function shake_swap_nodes(solution, instance)
	best = solution
	used = Set(best.tour)
	all = Set(1:instance.cities_count)
	candidates = collect(symdiff(used, all))
	i = 1
	while i < length(best.tour)
		for candidate in candidates
			best_total_prize, best_total_cost, best_total_penalty = calculate_tour(best.tour, instance)
			best.tour[i], old = candidate, best.tour[i] # do
			total_prize, total_cost, total_penalty = calculate_tour(best.tour, instance)
			if objective(total_prize, total_cost, total_penalty) < objective(best_total_prize, best_total_cost, best_total_penalty)
				if is_feasible(best, instance)
					i = 0
					used = Set(best.tour)
					all = Set(1:instance.cities_count)
					candidates = collect(symdiff(used, all))
					break
				end
			end
			best.tour[i] = old
		end
		i += 1
	end
	return best
end

function shake_insert_node(solution, instance)
	if length(solution.tour) == instance.cities_count
		return solution
	end
	used = Set(solution.tour)
	all = Set(1:instance.cities_count)
	candidates = collect(symdiff(used, all))
	new_element = candidates[rand(1:length(candidates))]
	shaked = Solution(solution.total_prize, solution.total_cost, solution.total_penalty, copy(solution.tour))
	add_city(instance, shaked, new_element)
	return shaked
end

function shake_remove_node(solution, instance)
	if length(solution.tour) == 2
		return solution
	end
	old_index = rand(1:length(solution.tour))
	shaked = Solution(solution.total_prize, solution.total_cost, solution.total_penalty, copy(solution.tour))
	remove_city(instance, shaked, old_index)
	return shaked
end

function shake_insert_nodes(solution, instance, quantity)
	shaked = solution
	for i in 1:quantity
		shaked = shake_insert_node(shaked, instance)
	end
	return shaked
end

function shake_remove_nodes(solution, instance, quantity)
	shaked = solution
	for i in 1:quantity
		shaked = shake_remove_node(shaked, instance)
	end
	return shaked
end

function add_city(instance, solution, city)
	solution.total_prize += instance.prizes[city]
	solution.total_penalty -= instance.penalties[city]
	solution.total_cost -= instance.costs[solution.tour[end], solution.tour[1]]
	solution.total_cost += instance.costs[solution.tour[end], city]
	solution.total_cost += instance.costs[city, solution.tour[1]]
	push!(solution.tour, city)
end

function remove_city(instance, solution, index)
	solution.total_prize -= instance.prizes[solution.tour[index]]
	if !is_feasible(solution, instance)
		solution.total_prize += instance.prizes[solution.tour[index]]
		return
	end
	solution.total_penalty += instance.penalties[solution.tour[index]]
	prev = index-1
	next = index+1
	if index == 1
		prev = length(solution.tour)
	elseif index == length(solution.tour)
		next = 1
	end
	solution.total_cost -= instance.costs[solution.tour[prev], solution.tour[index]]
	solution.total_cost -= instance.costs[solution.tour[index], solution.tour[next]]
	solution.total_cost += instance.costs[solution.tour[prev], solution.tour[next]]
	splice!(solution.tour, index)
end

function two_opt(solution, instance)
	best = solution
	i = 1
	while i < length(best.tour)
		j = i+1
		while j < length(best.tour)
			best_total_prize, best_total_cost, best_total_penalty = calculate_tour(best.tour, instance)
			new_tour = reverse(copy(best.tour), i, j)
			total_prize, total_cost, total_penalty = calculate_tour(new_tour, instance)
			if total_cost < best_total_cost
				i=0
				best = Solution(total_prize, total_cost, total_penalty, new_tour)
				break
			end
			j += 1
		end
		i += 1
	end
	return best
end

function swap(solution, instance)
	best = solution
	for i in 1:length(solution.tour)-1
		for j in (i+1):length(solution.tour)
			best_total_prize, best_total_cost, best_total_penalty = calculate_tour(best.tour, instance)
			solution.tour[i], solution.tour[j] = solution.tour[j], solution.tour[i] # do
			total_prize, total_cost, total_penalty = calculate_tour(solution.tour, instance)
			if total_cost < best_total_cost
				best = Solution(total_prize, total_cost, total_penalty, copy(solution.tour))
			end
			solution.tour[i], solution.tour[j] = solution.tour[j], solution.tour[i] # undo
		end
	end
	return best
end

function local_search2(solution, instance)
	return solution
end

function objective(solution)
	return solution.total_penalty + solution.total_cost
end

function objective(total_prize, total_cost, total_penalty)
	return total_penalty + total_cost
end

function is_feasible(solution, instance)
	return solution.total_prize >= instance.minimum_prize
end

function calculate_tour(tour, instance)
	if length(tour) == 0
		return (0, 0, instance.total_penalties)
	end
	total_prize = instance.prizes[tour[1]]
	total_penalty = instance.total_penalties - instance.penalties[tour[1]]
	total_cost = 0
	for i in 2:length(tour)
		total_prize += instance.prizes[tour[i]]
		total_penalty -= instance.penalties[tour[i]]
		total_cost += instance.costs[tour[i-1], tour[i]]
	end
	total_cost += instance.costs[tour[end], tour[1]]
	return (total_prize, total_cost, total_penalty)
end

type Solution
	total_prize::Int64
	total_cost::Int64
	total_penalty::Int64
	tour::Array{Int64}
end

type Instance
	costs::Array{Int64, 2}
	prizes::Array{Int64}
	penalties::Array{Int64}
	minimum_prize::Float64
	cities_count::Int64
	total_penalties::Int64
end

function gvns(instance::Instance, timeout, k_max, l_max)
	best = Solution(0, 0, typemax(Int64), [])
	time_limit = Dates.value(now()) + 1000*60*timeout
	count
	while Dates.value(now()) < time_limit
		#prin("Restarting")
		current = find_feasible(instance)
		k = 1
		while k <= k_max
			#prin("Starting iteration k")
			current_k = shake_k(current, k, instance)
			#prin(current_k)
			l = 1
			#prin("Starting iteration l")
			while l <= l_max
				current_l = local_search_l(current_k, l, instance)
				l, current_k = keep_best(l, current_l, current_k, false)
			end
			k, current = keep_best(k, current_k, current, false)
		end
		b, best = keep_best(1, current, best, true)
	end
	return best
end