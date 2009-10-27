#!ruby -Ku

Dir.chdir File.dirname(File.dirname(File.expand_path(__FILE__)))
require './factory.rb'

factory_initialize()

def read_log_file(f)
  h = {}
  h[:date] = f.gets.chomp
  h[:seed_high] = Integer(f.gets[/0x[0-9a-f]{4}/])
  h[:roads_on_save] = f.gets.match(/: (\d+,\d+,\d+)/)[1].split(",").map(&:to_i)
  line = f.gets.chomp
  h[:first_seed] = Integer(line[/^0x[0-9a-f]{8}/])
  h[:roads] = line[/\d+,\d+,\d+/].split(",").map(&:to_i)
  h[:entei_consumption] = line.match(/\((\d+)\)/)[1].to_i
  f.gets
  h[:entries] = f.gets[/(?:[^\x00-\/{-~]+,){5}[^\x00-\/{-~]+/].split(",").map{|i| get_factory_entry(1, i) }
  h[:start_consumption], h[:end_consumption] = f.gets.match(/(\d+)-(\d+)/)[1..2].map(&:to_i)
  h[:order] = f.gets[/(?:\d+,){5}\d+/].split(',').map{|i| i.to_i - 1 }
  f.gets
  h[:enemy_entries] = f.gets[/(?:[^\x00-\/{-~]+,){2}[^\x00-\/{-~]+/].split(",").map{|i| get_factory_entry(1, i) }
  h[:enemy_start_consumption], h[:enemy_end_consumption] = f.gets.match(/(\d+)-(\d+)/)[1..2].map(&:to_i)
  h[:enemy_order] = f.gets[/(?:\d+,){2}\d+/].split(',').map{|i| i.to_i - 1 }
  f.gets
  h[:enemy_trainer_name] = f.gets.match(/: (.+)/)[1]
  h
end

filenames = Dir.glob("log/*").sort
errors = []
ok_files = 0

filenames.each do |filename|
  h = open(filename, "rb") {|f| read_log_file(f) }
  first_seed = h[:first_seed]
  roads, entei_consumption = get_roads_by_seed(first_seed, h[:roads_on_save])
  unless h[:roads] == roads and entei_consumption == h[:entei_consumption]
    errors << [filename, "roads が一致しません"]
    next
  end
  info = get_factory_entries_info(1,
                                  first_seed,
                                  step_seed(first_seed, h[:start_consumption]),
                                  h[:start_consumption],
                                  6,
                                  [])
  if sortby_order(info[:entries], h[:order]) != h[:entries]
    errors << [filename, "entries が一致しません"]
    next
  end
  start_consumption, end_consumption = step_entries(info)
  if start_consumption != h[:start_consumption]
    errors << [filename, "start_consumption が一致しません"]
  end
  if end_consumption != h[:end_consumption]
    errors << [filename, "end_consumption が一致しません"]
  end
  order = get_order_by_seed(step_seed(first_seed, end_consumption + 1))
  if h[:order] != order
    errors << [filename, "order が一致しません"]
  end
  enemy_start_consumption = end_consumption + 3
  enemy_info = get_factory_entries_info(1,
                                        first_seed,
                                        step_seed(first_seed, enemy_start_consumption),
                                        enemy_start_consumption,
                                        3,
                                        h[:entries])
  if sortby_order(enemy_info[:entries], h[:enemy_order]) != h[:enemy_entries]
    errors << [filename, "enemy_entries が一致しません"]
  end
  enemy_start_consumption, enemy_end_consumption = step_entries(enemy_info)
  if enemy_start_consumption != h[:enemy_start_consumption]
    errors << [filename, "enemy_start_consumption が一致しません"]
  end
  if enemy_end_consumption != h[:enemy_end_consumption]
    errors << [filename, "enemy_start_consumption が一致しません"]
  end
  
  ok_files += 1
end

puts "ok: #{ok_files} ng: #{errors.size}"
errors.each do |(filename, msg)|
  puts "#{filename}: #{msg}"
end