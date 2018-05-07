include("./gvns.jl")
using DataStructures

function main()
	minutes = 2
	sigma = 0.5
	k = 8
	l = 2

	root_dir = "../res/instances"
	files = readdir(root_dir)
	solutions = OrderedDict("A" => [], "B" => [], "C" => [])
	i = 1
	for file in files
		file = "problem_40_100_100_1000.pctsp"
		file_path = "$root_dir/$file"
		if i>1
			break
		end
		if isfile(file_path)
			values = split(split(file, ".")[1], "_")
			class = parse_class(values)
			cities = parse(Int64,values[2])
			prizes, penalties, costs = read_file(file_path)
			min_prize = sum(map(x->x*sigma, prizes))
			println("Searching solution with minimum prize of $min_prize")
			best = gvns(Instance(reshape(costs, cities, cities), prizes, penalties, min_prize, cities, sum(penalties)), minutes, k, l)
			push!(solutions[class], [class, values[2], objective(best)])
			#println([class, values[2], objective(best)])
		end
		i += 1
	end
	for class in keys(solutions)
		for solution in solutions[class]
			println("$(solution[1]), $(solution[2]), $(solution[3])")
		end
	end
end

function parse_class(values)
	if values[5]=="1000" && values[4]=="100" && values[3]=="100"
		return "A"
	elseif values[5]=="10000" && values[4]=="1000" && values[3]=="100"
		return "B"
	elseif values[5]=="10000" && values[4]=="100" && values[3]=="100"
		return "C"
	end
	return "ERROR"
end

main()