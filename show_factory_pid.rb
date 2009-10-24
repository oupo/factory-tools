#!ruby -Ku
require './win32-encoding.rb'

def step_seed(seed, n=1)
  if n >= 0
    n.times do
      seed = (seed * 0x41C64E6D + 0x6073) & 0xffffffff
    end
  else
    (-n).times do
      seed = (seed * 0xEEB9EB65 + 0xA3561A1) & 0xffffffff
    end
  end
  seed
end

natures = %w(がんばりや さみしがり ゆうかん いじっぱり やんちゃ すぶとい すなお のんき わんぱく のうてんき おくびょう せっかち まじめ ようき むじゃき ひかえめ おっとり れいせい てれや うっかりや おだやか おとなしい なまいき しんちょう きまぐれ)
natures_alias = %w(ga sa yu ij ya zu su non wa nou ok se ma yo mu hi ott re te uk od oto na si ki)

abort "usage: ruby #{$0} 0x12345678 42 がんばりや" if ARGV.size != 3
s = Integer(ARGV[0])
n = Integer(ARGV[1])
requested_nature = natures.index(ARGV[2]) || natures_alias.index(ARGV[2])
abort "invalid nature #{ARGV[2].dump}" if !requested_nature

n += 2
s = step_seed(s, n)
while true
  pid = s >> 16 | step_seed(s) >> 16 << 16
  nature = pid % 25
  break if nature == requested_nature
  s = step_seed(s, 2)
  n += 2
end

puts "%#.8x (%s)" % [pid, natures[nature]]
puts "%d: %#.8x" % [n, s]
puts "%d: %#.8x" % [n + 1, step_seed(s)]
