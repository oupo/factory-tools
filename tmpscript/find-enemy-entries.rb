#!ruby -Ku

Dir.chdir File.dirname(File.dirname(File.expand_path(__FILE__)))
require './factory.rb'

factory_initialize()

def show_entries(shuu, h, visited_entries)
  start_consumption, end_consumption = step_entries(h)
  if h[:entries].size == 6
    order = get_order_by_seed(step_seed(h[:seed], end_consumption + 1 - h[:consumption]))
  else
    order = [0,1,2]
  end
  entries = sortby_order(h[:entries], order)
  infos = sortby_order(get_entries_pid(h[:entries], step_seed(h[:seed], h[:steps])), order)
  #show_factory_entries_by_seed(shuu, entries.size, h[:seed], h[:consumption], visited_entries)
  entries.zip(infos) do |entry, info|
    pid = info[:pid]
    printf("%s(%d): ID %.5d 裏ID %.5d 性格値 %#.8x (%s %s %s)\n",
           entry.name,
           entry.id + 1,
           info[:parent_id],
           info[:secret_id],
           pid,
           @natures[pid % 25],
           entry.pokemon_entry.ability(pid % 2),
           pid2gender(pid, entry.pokemon_entry))
  end
end

def input_entries_by_id(num)
  entries = gets.chomp.strip.split(/\s+/).map {|i| id = (Integer(i) rescue nil); id && @factory_entries[id - 1] }
  (entries.all? && entries.size == num) ? entries : nil
end

first_seed = 0xa5da924f
consumption = 0
seed = first_seed
shuu = 2
num_bonus = 1

h = get_6_entries_info(shuu, first_seed, seed, consumption, num_bonus)
start_consumption, end_consumption = step_entries(h)
order = get_order_by_seed(step_seed(first_seed, end_consumption + 1))
entries = sortby_order(h[:entries], order)
puts entries.map(&:name).join(",")
puts "範囲: #{h.start_consumption_str}..#{end_consumption}"
show_entries(shuu, h, [])
seed = step_seed(seed, end_consumption + 3 - consumption)
consumption = end_consumption + 3

prev_enemy_entries = nil

#print "こちらの手持ち: "
#entries_in_hand = input_pokemon_names(3, shuu, [])
entries_in_hand = nil

1.upto(7) do |i|
  if i == 1
    visited_entries = entries
  else
    visited_entries = entries_in_hand + prev_enemy_entries
  end
  begin
    print "#{i}戦目のこちらの手持ち: "
    entries_in_hand = input_entries_by_id(3)
  end until entries_in_hand
  print "#{i}戦目の相手の周: "
  begin
    l = gets().chomp
  end until /\A\s*\d+\s*\z/ =~ l
  enemy_shuu = l.to_i
  print "#{i}戦目の相手の3匹: "
  enemy_entries = input_pokemon_names(3, enemy_shuu, visited_entries)
  h = find_3_entries(enemy_shuu, first_seed, seed, consumption, enemy_entries, visited_entries)
  unless h
    puts "見つかりません"
    redo
  end
  start_consumption, end_consumption = step_entries(h)
  puts "範囲: #{h.start_consumption_str}..#{end_consumption}"
  show_entries(enemy_shuu, h, visited_entries)
  seed = step_seed(seed, end_consumption + 1 - consumption)
  consumption = end_consumption + 1
  prev_enemy_entries = enemy_entries
end
