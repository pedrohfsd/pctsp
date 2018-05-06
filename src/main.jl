include("./gvns.jl")

function main()
	files = readdir("../res/instances")
	i = 0
	for file in files
		if i>1
			break
		end
		if isfile(file)
			prizes, penalties, costs = read_file("../res/instances/problem_20_100_100_1000.pctsp")
			instance = Instance(reshape(costs, 20, 20), prizes, penalties, 100, 20, sum(penalties))
			print(gvns(instance, 1, 2, 1))
		end
	end
end

main()