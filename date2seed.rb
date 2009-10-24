#!ruby

s = ARGV.join(" ")

unless m = /\A(?:20\d{2}\/)?(?<month>\d{1,2})\/(?<date>\d{1,2}) (?<hour>\d{1,2}):(?<minute>\d{1,2}):(?<second>\d{1,2})\z/.match(s)
  abort "usage: date2seed.rb DATE 12/24 21:40:30"
end

h = {}
m.names.each {|name| h[name] = m[name].to_i }

puts '%#.4x' % (((h['month'] * h['date'] + h['minute'] + h['second']) & 0xff) << 8 | h['hour'])
