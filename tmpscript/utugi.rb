#!ruby -Ku

Dir.chdir File.dirname(File.dirname(File.expand_path(__FILE__)))
require './factory.rb'

factory_initialize()

seed = 0xb71003c7
c = 0

200.times do
  s = seed
  b = []
  10.times do
    b << (s >> 16) % 3
    s = step_seed(s)
  end
  puts "%.3d: %s" % [c, b.join(",")]
  seed = step_seed(seed)
  c += 1
end

# 0: ポケモンの進化, 1: カントー, 2: ポケルス
