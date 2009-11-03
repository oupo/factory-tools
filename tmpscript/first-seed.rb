#!ruby -Ku

Dir.chdir File.dirname(File.dirname(File.expand_path(__FILE__)))
require './factory.rb'

factory_initialize()

def timer(t)
  start_time = Time.now.to_f
  while true
    time = Time.now.to_f
    diff = time - start_time
    break if diff >= t
    printf "\r%5.2f", t - diff
  end
  printf "\r%5.2f\n", 0
rescue Interrupt
  print "\n"
end

def search_seeds_by_roads(target_seed, roads, roads_on_save)
  result = []
  (-20..20).each do |i|
    r = (target_seed + i) & 0xffff
    seed = target_seed & 0xffff0000 | r
    res = get_roads_by_seed(seed, roads_on_save)
    res_roads, res_c = *res
    if res_roads == roads
      result << [seed, res_c]
    end
  end
  result
end

datetime = "2010/05/29 16:07:31"
wait_time = 22.3
seed_high = date_to_seed_high(datetime)
target_seed = 0xb71003c7
roads_on_save = [39,42,17]
if seed_high != target_seed >> 16
  abort "seed_highが一致しません"
end

while true
  print "タイマースタート>"
  if gets.strip.downcase != "n"
    timer(wait_time)
  end
  roads = input_roads("ロード直後の徘徊の位置: ")
  seed_pick = search_seeds_by_roads(target_seed, roads, roads_on_save)
  if seed_pick.empty?
    puts "当てはまる初期seedが見つかりません"
    next
  end
  seed_pick.each do |(seed, c)|
    puts "%#.8x (%d)" % [seed, c]
  end
  #roads_on_save = roads
end
