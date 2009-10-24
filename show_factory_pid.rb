#!ruby -Ks

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

natures = %w(‚ª‚ñ‚Î‚è‚â ‚³‚Ý‚µ‚ª‚è ‚ä‚¤‚©‚ñ ‚¢‚¶‚Á‚Ï‚è ‚â‚ñ‚¿‚á ‚·‚Ô‚Æ‚¢ ‚·‚È‚¨ ‚Ì‚ñ‚« ‚í‚ñ‚Ï‚­ ‚Ì‚¤‚Ä‚ñ‚« ‚¨‚­‚Ñ‚å‚¤ ‚¹‚Á‚©‚¿ ‚Ü‚¶‚ß ‚æ‚¤‚« ‚Þ‚¶‚á‚« ‚Ð‚©‚¦‚ß ‚¨‚Á‚Æ‚è ‚ê‚¢‚¹‚¢ ‚Ä‚ê‚â ‚¤‚Á‚©‚è‚â ‚¨‚¾‚â‚© ‚¨‚Æ‚È‚µ‚¢ ‚È‚Ü‚¢‚« ‚µ‚ñ‚¿‚å‚¤ ‚«‚Ü‚®‚ê)
natures_alias = %w(ga sa yu ij ya zu su non wa nou ok se ma yo mu hi ott re te uk od oto na si ki)

abort "usage: ruby #{$0} 0x12345678 42 ‚ª‚ñ‚Î‚è‚â" if ARGV.size != 3
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
