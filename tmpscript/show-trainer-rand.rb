#!ruby -Ku

Dir.chdir File.dirname(File.dirname(File.expand_path(__FILE__)))
require './factory.rb'

factory_initialize()

def show_rand(i, s, mod, add)
  n = (s >> 16) % mod + add
  puts "%4d: %#.8x %#.4x %% %2d + %3d = %3d (%s)" % [i, s, s >> 16, mod, add, n, $trainer_names[n]]
end

seed = 0x4ef2040c
s = seed
i = 0

[[39, 80]].each do |(mod, add)|
  [-20...0].each do |range|
    i = range.first
    s = step_seed(seed, i)
    while i < range.last
      show_rand i, s, mod, add
      s = step_seed(s)
      i += 1
    end
  end
  puts "-" * 20
end
