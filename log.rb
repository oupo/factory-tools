#!ruby -Ku

require './factory.rb'

def main
  factory_initialize()
  shuu = 1
  while true
    puts "-" * 50
    roads_on_save = input_roads("セーブ前の徘徊の位置: ")
    begin
      print "日時: "
      datetime = gets.chomp
    end until /\A20\d{2}\/\d{1,2}\/\d{1,2} \d{1,2}:\d{1,2}:\d{1,2}\z/ =~ datetime
    seed_high = date_to_seed_high(datetime)
    roads = input_roads("ロード直後の徘徊の位置: ")
    redo if main_cycle(shuu, datetime, seed_high, roads, roads_on_save)
  end
end


# ある日付の0:00から10分刻みで23:50まで計144回のログをとる
def main_24h
  factory_initialize()
  
  shuu = 1
  date = "2009/10/21"
  second = 24
  times = 0.upto(23).map {|h| (0..50).step(10).map {|m| "%.2d:%.2d" % [h, m] } }.flatten
  times = times[times.index('00:00')..-1]
  
  roads_on_save = input_roads("セーブ前の徘徊の位置: ")
  times.each do |time|
    puts "時刻: #{time}"
    datetime = "#{date} #{time}:#{second}"
    seed_high = date_to_seed_high(datetime)
    roads = input_roads("ロード直後の徘徊の位置: ")
    redo if main_cycle(shuu, datetime, seed_high, roads, roads_on_save)
    roads_on_save = roads
  end
end

def main_cycle(shuu, date, seed_high, roads, roads_on_save)
  # 初期seed候補のリスト [[seed, 徘徊での乱数消費量], ...]
  seed_pick = search_seeds_by_roads(seed_high, roads, roads_on_save)
  if seed_pick.empty?
    puts "当てはまる初期seedが見つかりません"
    return true
  end
  
  print "相手の3匹: "
  enemy_entries = input_pokemon_names(3, shuu, [])
  
  print "最初の6匹: "
  entries = input_pokemon_names(6, shuu, enemy_entries)
  
  seeds = seed_pick.map{|(s,c)| s}
  h = find_entries_and_select_candidate(shuu, seeds, 0, entries, [])
  unless h
    puts "6匹の組み合わせは見つかりませんでした"
    return true
  end
  raw_entries = h[:entries]
  first_seed = h[:first_seed]
  entei_consumption = seed_pick.find {|(s,c)| s == first_seed}[1] # 徘徊での乱数消費量
  
  puts "初期seed: %#.8x" % first_seed
  seed = first_seed
  consumption = 0
  
  start_consumption, end_consumption = step_entries(h)
  
  # 6匹の性格値生成終了後2つ乱数を消費してから相手の3匹の種類が決定される
  consumption = end_consumption + 1 + 2
  seed = step_seed(first_seed, consumption)
  h = get_factory_entries_info(shuu, first_seed, seed, consumption, 3, entries)
  unless h[:entries].all? {|i| enemy_entries.include?(i) }
    puts "3匹の組み合わせが一致しません"
    return true
  end
  raw_enemy_entries = h[:entries]
  
  enemy_start_consumption, enemy_end_consumption = step_entries(h)
  consumption = enemy_end_consumption + 1
  seed = step_seed(first_seed, consumption)
  
  begin
    print "トレーナー: "
    enemy_trainer_name = get_trainer_name(gets.chomp)
  end until enemy_trainer_name
  
  filename = date_to_filename(date)
  open(filename, "wb") do |f|
    f.puts date
    f.puts "target: %#.4xXXXX" % seed_high
    f.puts "セーブ前の徘徊の位置: " + roads_on_save.join(",")
    f.puts "%#.8x: %s (%d)" % [first_seed, roads.join(","), entei_consumption]
    f.puts
    f.puts entries.map(&:name).join(",")
    f.puts "消費された乱数の範囲: %d-%d" % [start_consumption, end_consumption]
    f.puts "シャッフル: "+raw_entries.map {|e| entries.index(e) + 1 }.join(",")
    f.puts
    f.puts enemy_entries.map(&:name).join(",")
    f.puts "消費された乱数の範囲: %d-%d" % [enemy_start_consumption, enemy_end_consumption]
    f.puts "シャッフル: "+raw_enemy_entries.map {|e| enemy_entries.index(e) + 1 }.join(",")
    f.puts
    f.puts "トレーナー: #{enemy_trainer_name}"
  end
  puts "#{filename} に保存しました"
  false
end

def date_to_filename(date)
  d = date.sub(/\A(20\d{2})\/(\d{1,2})\/(\d{1,2}).*/) { "#{$1}#{$2}#{$3}" }
  i = 1
  begin
    s = "log/%s-%.3d.txt" % [d, i]
    i += 1
  end while File.exist?(s)
  s
end

main()
