#!ruby -Ku

require './factory.rb'

factory_initialize()
shuu = 1
num_bonus = 0

print "初期seed: "
seed = first_seed = Integer(gets())
consumption = 0

print "最初の6匹: "
entries = input_pokemon_names(6, shuu, [])

h = find_6_entries(shuu, [first_seed], entries, num_bonus)
unless h
  puts "6匹の組み合わせは見つかりませんでした"
  return
end
raw_entries = h[:entries]
start_consumption, end_consumption = step_entries(h)
order = get_order_by_seed(step_seed(first_seed, end_consumption + 1))
if order != create_order(raw_entries, entries)
  puts "並び順が一致しません"
  return
end

n = show_entries(shuu, h, consumption, entries, [])
n += @consumption_for_calc_order
seed = step_seed(seed, n)
consumption += n

puts
print "相手の3匹: "
enemy_entries = input_pokemon_names(3, shuu, raw_entries)
h = get_3_entries_info(shuu, first_seed, seed, consumption, entries)
unless h[:entries].all? {|i| enemy_entries.include?(i) }
  puts "3匹の組み合わせが一致しません"
  return true
end
raw_enemy_entries = h[:entries]
enemy_start_consumption, enemy_end_consumption = step_entries(h)
n = show_entries(shuu, h, consumption, enemy_entries, entries)
seed = step_seed(seed, n)
consumption += n
