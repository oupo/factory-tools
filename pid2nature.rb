#!ruby -Ks

abort "usage: ruby #{$0} 0x12345678 ピカチュウ" if ARGV.size != 2
pid = Integer(ARGV[0])
name = ARGV[1]
pokedex = open('pokedex.csv', 'rb') {|f| f.lines.map {|l| l.chomp.split(',', -1) } }
e = pokedex.find {|e| e[0] == name}
abort "invalid name: #{name.dump}" if !e


name, ability1, ability2, gender_ratio = *e

# 性別値 <= 境界のとき: ♀
# 性別値 > 境界のとき: ♂

# 以下は一見間違っていて '1:7' => 31, '1:3' => 63, '1:1' => 127, '3:1' => 191 が正解かと思われるが、
# 実は偏っていて以下であっているそう
# 参照: http://d.hatena.ne.jp/metagross-armor/20090718/p1
boundaries = {'♂のみ' => -1, '♀のみ' => 255, '1:7' => 30, '1:3' => 63, '1:1' => 126, '3:1' => 190}

natures = %w(がんばりや さみしがり ゆうかん いじっぱり やんちゃ ずぶとい すなお のんき わんぱく のうてんき おくびょう せっかち まじめ ようき むじゃき ひかえめ おっとり れいせい てれや うっかりや おだやか おとなしい なまいき しんちょう きまぐれ)

puts "%s pid=%#.8x" % [name, pid]
if gender_ratio == 'ふめい'
  puts "性別: 不明"
else
  puts "性別: " + ((pid & 0xff) > boundaries[gender_ratio] ? "♂" : "♀")
end

puts "性格: " + natures[pid % 25]
if ability2 == ''
  puts "特性: 特性#{pid % 2 + 1} #{ability1} (特性はこれのみ）"
else
  puts "特性: 特性#{pid % 2 + 1} #{pid % 2 == 0 ? ability1 : ability2} (#{ability1}, #{ability2})"
end
