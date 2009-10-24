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

s = 0xea0101f8
1500.times do |i|
  puts "%4d: %#.8x %3d %.5d" % [i, s, 150 - (s >> 16) % 150, s >> 16]
  s = step_seed(s)
end
