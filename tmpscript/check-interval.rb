#!ruby -Ku

Dir.chdir File.dirname(File.dirname(File.expand_path($0)))
require './factory.rb'

factory_initialize()

count = {true => 0, false => 0}

Dir["log/*.txt"].sort.each do |filename|
  lines = open(filename, "rb") {|f| f.lines.map(&:chomp) }
  first_seed = Integer(lines[3][/0x[0-9a-f]{8}/])
  my_entries = lines[5].split(",").map {|i| get_factory_entry(1, i) }
  end_consuption = lines[6].match(/(\d+)-(\d+)/)[2].to_i
  enemy_start_consumption = lines[10].match(/(\d+)-(\d+)/)[1].to_i
  interval = enemy_start_consumption - end_consuption - 1
  next if interval == 2

  c1 = enemy_start_consumption
  seed = step_seed(first_seed, c1)
  entries1, n1 = get_factory_entries(1, seed, 3, my_entries)

  c2 = end_consuption + 3
  seed = step_seed(first_seed, c2)
  entries2, n2 = get_factory_entries(1, seed, 3, my_entries)

  ok = entries1 == entries2 && c1 + n1 == c2 + n2
  puts "#{File.basename(filename)}: #{ok}"
  count[ok] += 1
end

puts "true: #{count[true]}, false: #{count[false]}"
