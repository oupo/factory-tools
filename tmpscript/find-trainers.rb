#!ruby -Ku

Dir.chdir File.dirname(File.dirname(File.expand_path(__FILE__)))
require './factory.rb'

factory_initialize()

def is_match(n, s)
  m = @expected_trainers[0] - (s >> 16) % n
  6.times do |i|
    id = (s >> 16) % n + m
    s = step_seed(s)
    index = @expected_trainers.index(id)
    return false if index == nil or index > i
    redo if index < i
  end
  true
end

def trainer_name_to_id(search_name)
  @trainer_names.find_index do |line|
    name = line.match(/の([^の]+)$/)[1]
    name == search_name
  end
end

@expected_trainers = %w(アドアド オトラ ナグリ ツボネ ベック ボナパルト).map{|i| trainer_name_to_id(i) }

range_min = @expected_trainers.max - @expected_trainers.min + 1

first_seed = 0xaadfec79

range_min.upto(100) do |n|
  i = -20
  seed = step_seed(first_seed, i)
  while i <= -13
    if is_match(n, seed)
      puts "rand %% %d + %d: %d (%#.8x)" % [n, 81 - (seed >> 16) % n, i-20, seed]
    end
    seed = step_seed(seed)
    i += 1
  end
end
