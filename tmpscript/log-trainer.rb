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

def get_consption(seed, first_trainer_id)
  result = []
  get_trainers_candidate(seed).each do |r|
    if r[:trainer_ids][0] == first_trainer_id
      result << r[:c]
    end
  end
  result
end

def get_trainers_candidate(seed_head)
  i = 13
  seed = step_seed(seed_head, -i)
  result = []
  while i < 50
    r = get_trainers_by_seed(seed)
    if (6..13).include?(i - r[:c])
      result << {:trainer_ids => r[:trainer_ids], :c => i - r[:c]}
    end
    i += 1
    seed = step_seed(seed, -1)
  end
  result.uniq
end

def get_trainers_by_seed(seed)
  result = []
  c = 0
  6.times do |i|
    e = (seed >> 16) % 99
    seed = step_seed(seed)
    c += 1
    redo if result.include?(e)
    result << e
  end
  result << ((seed >> 16) % 19 + 100)
  c += 1
  {:trainer_ids => result, :c => c}
end

def try(seed_head, expected, n, m)
  # トレーナー決定後の消費が r % N で何かを重複なしにM個決定していると仮定 (M >= N)
  seed = step_seed(seed_head, -expected)
  es = []
  c = 0
  m.times do
    e = (seed >> 16) % n
    seed = step_seed(seed)
    c += 1
    redo if es.include?(e)
    es << e
  end
  expected == c
end

log_data = []
Dir.glob("log/*.txt").sort.each do |filename|
  h = open(filename, "rb") {|f| read_log_file(f) }
  next if h[:enemy_trainer_name] == "(調べ忘れ)"
  first_trainer_id = $trainer_names.index(h[:enemy_trainer_name])
  seed = step_seed(h[:first_seed], h[:start_consumption])
  c = get_consption(seed, first_trainer_id)
  next if c.length > 1
  log_data << {:filename => filename, :first_trainer_id => first_trainer_id, :seed => seed, :c => c[0]}
end

(0..3).to_a.product((0..3).to_a).each do |(a,b)|
  # a = トレーナー決定後の固定消費量
  # b = 謎の消費後の固定消費量
  (5-a-b).upto(200) do |n|
    next if n < 2
    2.upto([7-a-b, n].min) do |m|
      ok_count = 0
      log_data.each do |h|
        ok_count += 1 if try(step_seed(h[:seed], -b), h[:c]-a-b, n, m)
      end
      if ok_count.to_f / log_data.size >= 0.6
        puts "n = %d, m = %d, a = %d, b = %d, %2.1f%%" % [n, m, a, b, 100.0 * ok_count / log_data.size]
      end
    end
  end
end
