#!ruby -Ku

# 同じシャッフル結果のswapに使われる乱数列を表示

Dir.chdir File.dirname(File.dirname(File.expand_path($0)))
require './factory.rb'

factory_initialize()

search_value = ARGV[0] || '1,2,3,4,6,5'
filenames = Dir.glob("log/*").sort
filenames.each do |filename|
  open(filename, "rb") do |f|
    lines = f.lines.map(&:chomp)
    first_seed = Integer(lines[3][/^0x[0-9a-f]{8}/])
    start_consumption, end_consumption = lines[6].match(/(\d+)-(\d+)/)[1..2].map(&:to_i)
    shuffle = lines[7][/(?:\d+,){5}\d+/]
    order = shuffle.split(',').map{|i| i.to_i - 1 }
    n = order.enum_for(:count).with_index {|e, i| e != i }
    if shuffle == search_value
      puts filename
      [end_consumption + 1].each do |c|
        seed = step_seed(first_seed, c)
        2.times do
          puts "%.3d: %#.8x %d" % [c, seed, (seed >> 16) % 6]
          seed = step_seed(seed)
          c += 1
        end
      end
    end
  end
end
