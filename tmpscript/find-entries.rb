#!ruby -Ku

Dir.chdir File.dirname(File.dirname(File.expand_path(__FILE__)))
require './factory.rb'

factory_initialize()

def is_match(ids, n, m, s)
  entries = []
  visited_entries = []
  ids.size.times do |i|
    id = m - (s >> 16) % n
    entry = $factory_entries[id]
    return false unless entry
    s = step_seed(s)
    redo if entries_collision(entry, entries, visited_entries)
    index = ids.index(id)
    return false if index != i
    entries << entry
  end
  true
end

ids = [892,790,697,647,885,944]

range_min = ids.max - ids.min + 1

first_seed = 0x1ccf9b3a

range_min.upto(600) do |n|
  i = -16
  seed = step_seed(first_seed, i)
  while i <= -6
    m = ids[0] + (seed >> 16) % n
    if is_match(ids, n, m, seed)
      puts "%d - rand %% %d: %#.8x" % [m, n, seed]
    end
    seed = step_seed(seed)
    i += 1
  end
end
puts "finish"
