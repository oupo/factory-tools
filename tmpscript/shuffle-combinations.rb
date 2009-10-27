#!ruby -Ku

Dir.chdir File.dirname(File.dirname(File.expand_path(__FILE__)))
require './factory.rb'

factory_initialize()

order2swap = {}
keys = []
(6*6).times do |n|
  i = n % 6
  j = n / 6
  a = (0...6).to_a
  a[4], a[i] = a[i], a[4]
  a[5], a[j] = a[j], a[5]
  if order2swap[a]
    order2swap[a] << [i, j]
  else
    order2swap[a] = [[i, j]]
    keys << a
  end
end

keys.each do |order|
  puts sprintf("%s: %s",
               order.map{|i| i + 1}.join(","),
               order2swap[order].map{|i| "[#{i.join(",")}]" }.join(","))
end
