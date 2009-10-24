#!ruby -Ks

require 'set'
require 'pp'
require './roma2reg.rb'

def main
  initialize_pokemon_entries()
  initialize_factory_entries()
  initialize_shuu_entry_range()
  initialize_trainer_names()
  initialize_entei()
  @natures = %w(がんばりや さみしがり ゆうかん いじっぱり やんちゃ ずぶとい すなお のんき わんぱく のうてんき おくびょう せっかち まじめ ようき むじゃき ひかえめ おっとり れいせい てれや うっかりや おだやか おとなしい なまいき しんちょう きまぐれ)
  
  if ARGV.delete("--log")
    main_log_mode()
  else
    main_normal()
  end
end

def main_normal
  shuu = 1

  print "初期seed: "
  first_seed = Integer(gets())

  print "最初の6匹: "
  entries = input_pokemon_names(6, shuu, [])
  
  seed = step_seed(first_seed)
  consumption = 1
  
  raw_entries, start_consumption, end_consumption, n = find_entries_and_show(shuu, first_seed, consumption, entries, [])
  seed = step_seed(seed, n)
  consumption += n
  
  puts
  print "相手の3匹: "
  enemy_entries = input_pokemon_names(3, shuu, raw_entries)
  raw_enemy_entries, enemy_start_consumption, enemy_end_consumption, n = find_entries_and_show(shuu, first_seed, consumption, enemy_entries, entries)
  seed = step_seed(seed, n)
  consumption += n
end

def main_log_mode
  puts "log mode"
  
  shuu = 1
  date = "2009/10/21"
  second = 24
  times = 0.upto(23).map {|h| (0..50).step(10).map {|m| "%.2d:%.2d" % [h, m] } }.flatten
  times = times[times.index('02:10')..-1]
  
  roads_on_save = input_roads("セーブ前の徘徊の位置: ")
  times.each do |time|
    puts "時刻: #{time}"
    datetime = "#{date} #{time}:#{second}"
    seed_high = date_to_seed_high(datetime)
    roads = input_roads("ロード直後の徘徊の位置: ")
    redo if main_log_mode_cycle(shuu, datetime, seed_high, roads, roads_on_save)
    roads_on_save = roads
  end
end

def main_log_mode_cycle(shuu, date, seed_high, roads, roads_on_save)
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
  return true unless h
  raw_entries = h[:entries]
  first_seed = h[:first_seed]
  entei_consumption = seed_pick.find {|(s,c)| s == first_seed}[1] # 徘徊での乱数消費量
  
  puts "初期seed: %#.8x" % first_seed
  seed = first_seed
  consumption = 0
  
  start_consumption, end_consumption = step_entries(h, consumption)
  
  h = find_entries_and_select_candidate(shuu, [first_seed], end_consumption + 1, enemy_entries, entries)
  return true unless h
  raw_enemy_entries = h[:entries]
  
  enemy_start_consumption, enemy_end_consumption = step_entries(h, end_consumption + 1)
  consumption = end_consumption + 1
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

def input_roads(caption)
  roads = nil
  1.times do
    print caption
    roads = gets.split(",").map{|i| Integer(i) }
    unless valid_roads(roads)
      puts "invalid roads"
      redo
    end
  end
  roads
end

def input_pokemon_names(count, shuu, entries)
  state = 0
  while true
    case state
    when 0
      result = []
      es = entries.dup
      names = nil
      state = 1
    when 1
      names = gets.scan(/[^\x00-,.\/{-~]+/)
      if names.size == count
        state = 2
      else
        puts "#{count}匹入力してください"
      end
    when 2
      names.each do |name|
        entry = input_pokemon_name(name, shuu, es)
        break unless entry
        result << entry
        es << entry
      end
      if result.size == count
        state = 3
      else
        state = 0
      end
    when 3
      break
    end
  end
  result
end

def input_pokemon_name(name, shuu, entries)
  re = Regexp.new("\\A#{roma2reg(name)}\\z")
  entry = get_factory_entry_by_regexp(shuu, re)
  unless entry
    puts "#{name.inspect} は見つかりません"
    return nil
  end
  if entries.include?(entry)
    puts "重複: #{name.inspect}"
    return nil
  end
  entry
end

def find_entries_and_show(shuu, first_seed, consumption, entries, visited_entries)
  c = consumption
  h = find_entries_and_select_candidate(shuu, [first_seed], consumption, entries, visited_entries)
  raw_entries = h[:entries]
  seed = step_seed(h[:seed], h[:pos])
  c += h[:pos]
  puts
  start_consumption = c
  show_factory_entries_by_seed(shuu, entries.size, seed, c, visited_entries)
  seed = step_seed(seed, h[:consumption])
  c += h[:consumption]
  
  puts
  n = show_entries_pid(raw_entries, seed, c)
  seed = step_seed(seed, n)
  c += n
  end_consumption = c
  
  puts
  puts "シャッフル後: " + raw_entries.map {|e| entries.index(e) + 1 }.join(",")
  puts "#{start_consumption}-#{end_consumption-1}"
  
  return raw_entries, start_consumption, end_consumption, c - consumption
end

def find_entries_and_select_candidate(shuu, seeds, consumption, entries, visited_entries)
  candidate = find_factory_entries_candidate(shuu, seeds, consumption, entries, visited_entries)
  if candidate.empty?
    puts "#{entries.size}匹の組み合わせは見つかりませんでした"
    return nil
  end
  if candidate.size > 1
    puts "#{entries.size}匹の組み合わせは#{candidate.size}通りの候補があります"
    candidate.each_with_index do |h, i|
      es = h[:entries]
      pids = get_entries_pid(es, step_seed(h[:seed], h[:pos]+h[:consumption]))
      puts "%d: %#.8x +%d..%d" % [i+1, h[:first_seed], consumption + h[:pos], consumption + h[:pos] + h[:consumption] - 1]
      puts es.zip(pids).sort_by {|(e,p)| entries.index(e) }.map {|(e,p)| "%s:%.5d" % [e.name, p[:parent_id]] }.join(", ")
    end
    begin
      print "候補: "
      l = gets.strip
    end until /\A\d+\z/ =~ l and (0...candidate.size).include?(l.to_i-1)
    candidate[l.to_i-1]
  else
    candidate[0]
  end
end

def step_entries(h, consumption)
  seed = step_seed(h[:seed], h[:pos])
  consumption += h[:pos]
  
  start_consumption = consumption
  seed = step_seed(seed, h[:consumption])
  consumption += h[:consumption]
  
  n = step_entries_pid(h[:entries], seed)
  seed = step_seed(seed, n)
  consumption += n
  end_consumption = consumption - 1
  return start_consumption, end_consumption
end

def find_factory_entries_candidate(shuu, seeds, consumption, target_entries, visited_entries)
  result = []
  seeds.each do |first_seed|
    c = 0
    seed = s = step_seed(first_seed, consumption)
    100.times do
      entries, n = get_factory_entries(shuu, s, target_entries.size, visited_entries)
      if entries.all? {|i| target_entries.include?(i) }
        if result.none? {|e| entries == e[:entries] and e[:pos] + e[:consumption] == c + n }
          result << {:first_seed => first_seed, :seed => seed, :entries => entries, :pos => c, :consumption => n}
        end
      end
      s = step_seed(s)
      c += 1
    end
  end
  result
end

def get_factory_entries(shuu, seed, count, visited_entries)
  entries = []
  item_set = entries_to_item_set(visited_entries)
  n = 0
  count.times do
    id = factory_id_by_seed(shuu, seed)
    entry = @factory_entries[id]
    seed = step_seed(seed)
    n += 1
    redo if item_set.include?(entry.item)
    item_set << entry.item
    redo if entries.include?(entry) || visited_entries.include?(entry) # ダブり
    entries << entry
  end
  return entries, n
end

def show_factory_entries_by_seed(shuu, entries_count, seed, consumption, visited_entries)
  ids = []
  item_set = entries_to_item_set(visited_entries)
  n = 0
  count = get_shuu_entries_count(shuu)
  range = get_entries_range(shuu)
  entries_count.times do
    id = factory_id_by_seed(shuu, seed)
    e = @factory_entries[id]
    included = ids.include?(id) || visited_entries.include?(e)
    item_collision = item_set.include?(e.item)
    puts sprintf("%d: %#.8x %d - %#.4x %% %d%s = %d %s%s",
                 consumption + n,
                 seed,
                 count,
                 seed >> 16,
                 count,
                 range.first != 0 ? " + #{range.first}" : '',
                 id + 1,
                 e.name,
                 included       ? " (重複のため無視)" : 
                 item_collision ? " (アイテム重複のため無視)": "")
    seed = step_seed(seed)
    n += 1
    redo if item_collision
    item_set << e.item
    redo if included
    ids << id
  end
end

def entries_to_item_set(entries)
  set = Set.new
  entries.each do |entry|
    set << entry.item
  end
  set
end

def get_entries_pid(entries, seed)
  c = 0
  result = []
  entries.each do |e|
    parent_id = seed >> 16
    seed = step_seed(seed)
    c += 1
    hidden_parent_id = seed >> 16
    seed = step_seed(seed)
    c += 1
    nature = @natures.index(e.nature)
    begin
      pid = seed >> 16 | step_seed(seed) >> 16 << 16
      seed = step_seed(seed, 2)
      c += 2
    end while pid % 25 != nature
    result << {:parent_id => parent_id, :hidden_parent_id => hidden_parent_id, :pid => pid}
  end
  result
end

def step_entries_pid(entries, seed)
  c = 0
  entries.each do |e|
    parent_id = seed >> 16
    seed = step_seed(seed)
    c += 1
    hidden_parent_id = seed >> 16
    seed = step_seed(seed)
    c += 1
    nature = @natures.index(e.nature)
    begin
      pid = seed >> 16 | step_seed(seed) >> 16 << 16
      seed = step_seed(seed, 2)
      c += 2
    end while pid % 25 != nature
  end
  c
end

def show_entries_pid(entries, seed, consumption)
  c = consumption
  entries.each do |e|
    puts "#{e.name}"
    puts " 親ID: %.5d" % [seed >> 16]
    puts "  %d: %#.8x" % [c, seed]
    seed = step_seed(seed)
    c += 1
    #puts " 親裏ID: %.5d" % [seed >> 16]
    #puts "  %d: %#.8x" % [c, seed]
    seed = step_seed(seed)
    c += 1
    nature = @natures.index(e.nature)
    while true
      pid = seed >> 16 | step_seed(seed) >> 16 << 16
      break if pid % 25 == nature
      seed = step_seed(seed, 2)
      c += 2
    end
    puts " 性格値: %#.8x" % pid
    puts "  %d: %#.8x" % [c, seed]
    puts "  %d: %#.8x" % [c + 1, step_seed(seed)]
    puts " 性格: " + @natures[pid % 25]
    puts " 特性: " + e.pokemon_entry.ability(pid % 2)
    puts " 性別: " + pid2gender(pid, e.pokemon_entry)
    seed = step_seed(seed, 2)
    c += 2
  end
  c - consumption
end

def pid2gender(pid, pokemon)
  boundary = pokemon.gender_boundary
  if boundary
    (pid & 0xff) > boundary ? "♂" : "♀"
  else
    "不明"
  end
end

def pokemon_entry(name)
  id = @pokemon_name2id[name]
  return nil unless id
  @pokemon_entries[id]
end

def factory_id_by_seed(shuu, seed)
  range = get_entries_range(shuu)
  count = get_shuu_entries_count(shuu)
  count - (seed >> 16) % count - 1 + range.first
end

def initialize_pokemon_entries
  entries = @pokemon_entries = []
  name2id = @pokemon_name2id = {}
  boundaries = {'♂のみ' => -1, '♀のみ' => 255, '1:7' => 30, '1:3' => 63, '1:1' => 126, '3:1' => 190, 'ふめい' => nil}
  open('pokedex.csv', 'rb') do |f|
    f.each_line.with_index do |l, i|
      row = l.chomp.split(',', -1)
      name = row[0]
      ability1 = row[1]
      ability2 = row[2] != '' ? row[2] : nil
      gender_boundary = boundaries[row[3]]
      entries[i] = PokemonEntry.new(i, name, [ability1, ability2], gender_boundary)
      name2id[name] = i
    end
  end
end


def initialize_factory_entries
  entries = @factory_entries = []
  open('factory_data.txt', 'rb') do |f|
    f.each_line.with_index do |l, i|
      row = l.chomp.split('|', -1)[1...-1]
      name = row[0]
      entry = pokemon_entry(name)
      nature = row[1]
      item = row[2]
      moves = row[3].split(',')
      effort = effort_text_to_array(row[4])
      entries[i] = FactoryEntry.new(i, entry, nature, item, moves, effort)
    end
  end
end

def effort_text_to_array(text)
  list = text.split('/')
  efforts = [0, 0, 0, 0, 0, 0]
  status_names = 'HP,攻撃,防御,特攻,特防,すば'.split(',')
  list.each do |i|
    efforts[status_names.index(i)] = list.size == 3 ? 170 : 252
  end
  efforts
end

def initialize_shuu_entry_range
  @shuu_pokemons_count = [150, 100, 100, 136, 136, 136, 192] #各周のポケモンの数
  @shuu_entries_range = []
  i = 0
  @shuu_pokemons_count.each do |n|
    range = i..(i+n-1)
    @shuu_entries_range << (i..(i+n-1))
    i += n
  end
end

def get_entries_range(shuu)
  @shuu_entries_range[shuu - 1]
end

def get_shuu_entries_count(shuu)
  @shuu_pokemons_count[shuu - 1]
end

def get_factory_entry(shuu, name)
  get_entries_range(shuu).each do |i|
    e = @factory_entries[i]
    if e.name == name
      return e
    end
  end
  nil
end

def get_factory_entry_by_regexp(shuu, re)
  get_entries_range(shuu).each do |i|
    e = @factory_entries[i]
    if re =~ e.name
      return e
    end
  end
  nil
end

def date_to_filename(date)
  d = date.sub(/\A(20\d{2})\/(\d{1,2})\/(\d{1,2}).*/) { "#{$1}#{$2}#{$3}" }
  i = 1
  begin
    s = "log/%s-%.2d.txt" % [d, i]
    i += 1
  end while File.exist?(s)
  s
end

def initialize_trainer_names
  open('trainer.txt', 'rb') do |f|
    @trainer_names = f.lines.map(&:chomp)
  end
end

def get_trainer_name(name)
  re = Regexp.new("\\A#{roma2reg(name)}\\z")
  @trainer_names.each do |line|
    name = line.match(/の([^の]+)$/)[1]
    if re =~ name
      return line
    end
  end
  nil
end

def initialize_entei
  @johto_roads = (29..39).to_a + (42..46).to_a
  @kanto_roads = (1..22).to_a + [24,26,28]
end

def valid_roads(roads)
  roads.all? {|road| @johto_roads.include?(road) || @kanto_roads.include?(road) }
end

# セーブ前とロード直後の徘徊の位置と狙った初期seedの上位16ビットを受け取り
# 初期seedの候補を返す
def search_seeds_by_roads(seed_high, roads, roads_on_save)
  result = []
  (-1).upto(1) do |i|
    h = (((seed_high >> 8) + i) & 0xff) << 8 | (seed_high & 0xff)
    50.times do |j|
      r = (0x01e0 + j) & 0xffff
      seed = h << 16 | r
      res = get_roads_by_seed(seed, roads_on_save)
      res_roads, res_c = *res
      #puts "%#.8x" % seed
      if res_roads == roads
        result << [seed, res_c]
      end
    end
  end
  result
end

def get_roads_by_seed(seed, roads_on_save)
  result = []
  c = 0
  roads_on_save.each do |road_on_save|
    roads = @johto_roads.include?(road_on_save) ? @johto_roads : @kanto_roads
    begin
      seed = step_seed(seed)
      road = roads[(seed >> 16) % roads.size]
      c += 1
    end while road == road_on_save
    result << road
  end
  return [result, c]
end

def date_to_seed_high(s)
  m = /\A(?:20\d{2}\/)?(\d{1,2})\/(\d{1,2}) (\d{1,2}):(\d{1,2}):(\d{1,2})\z/.match(s)
  month, date, hour, minute, second = *m.to_a[1..5].map(&:to_i)
  ((month * date + minute + second) & 0xff) << 8 | hour
end

def step_seed(seed, n=1)
  if n >= 0
    n.times do
      seed = (seed * 0x41C64E6D + 0x6073) & 0xffffffff
    end
  else
    (-n).times do
      seed = (seed * 0xEEB9EB65 + 0xA3561A1) & 0xffffffff
    end
  end
  seed
end

FactoryEntry = Struct.new(:id, :pokemon_entry, :nature, :item, :moves, :effort)
PokemonEntry = Struct.new(:id, :name, :abilities, :gender_boundary)

class FactoryEntry
  def name
    pokemon_entry.name
  end
end

class PokemonEntry
  def ability1
    abilities[0]
  end
  
  def ability2
    abilities[1]
  end
  
  def ability(i)
    if i == 1 && abilities[1] == nil
      abilities[0]
    else
      abilities[i]
    end
  end
end

main()
