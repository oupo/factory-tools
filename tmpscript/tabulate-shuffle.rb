#!ruby -Ku

Dir.chdir File.dirname(File.dirname(File.expand_path(__FILE__)))
require './factory.rb'

factory_initialize()

result = Array.new(5) { Hash.new{|h, k| h[k] = 0 } }

filenames = Dir.glob("log/*").sort
filenames.each do |filename|
  open(filename, "rb") do |f|
    lines = f.lines.map(&:chomp)
    shuffle = lines[7][/(?:\d+,){5}\d+/].split(',').map{|i| i.to_i - 1 }
    n = shuffle.enum_for(:count).with_index {|e, i| e != i }
    result[n][shuffle] += 1
  end
end
result.each_with_index do |es, n|
  next if es.empty?
  puts "-- #{n}"
  es.each do |e, c|
    puts sprintf("#{e.map{|i| i + 1}.join(",")}: #{c}")
  end
end