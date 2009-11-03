#!ruby -Ku

Dir.chdir File.dirname(File.dirname(File.expand_path(__FILE__)))
require './factory.rb'

factory_initialize()

items = {}

puts(get_entries_range(1).map do |i|
  e = @factory_entries[i]
  if items.include?(e.item)
    item_id = items[e.item]
  else
    item_id = items.size + 1
    items[e.item] = item_id
  end
  "{%2d, %2d}," % [@natures.index(e.nature), item_id]
end.each_slice(5).map(&:join)).join("\n")
