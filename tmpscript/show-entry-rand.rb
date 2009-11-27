#!ruby -Ku

Dir.chdir File.dirname(File.dirname(File.expand_path(__FILE__)))
require './factory.rb'

factory_initialize()

def show_rand(i, s, mod, add)
  n = add - (s >> 16) % mod
  puts "%4d: %#.8x %3d - %#.4x %% %2d = %3d (%s)" % [i, s, add, s >> 16, mod, n, $factory_entries[n-1].name]
end

seed = 0x04112aac
s = seed
i = 0

[[328, 950]].each do |(mod, add)|
  [0...20].each do |range|
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
