function skip_lines(file_in, num)
	for i in 1:num
		readline(file_in)
	end
end 

function read_file(file_path)
	file_in = open(file_path)
	skip_lines(file_in, 1)
	bonuses = readdlm(IOBuffer(strip(readline(file_in))), Int)
	skip_lines(file_in, 2)
	penalties = readdlm(IOBuffer(strip(readline(file_in))), Int)
	close(file_in)

	costs = readdlm(file_path, Int, skipstart=8)
	print(costs)
end

read_file("../res/instances/problem_20_100_100_1000.pctsp")