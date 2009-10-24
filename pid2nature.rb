#!ruby -Ks

abort "usage: ruby #{$0} 0x12345678 �s�J�`���E" if ARGV.size != 2
pid = Integer(ARGV[0])
name = ARGV[1]
pokedex = open('pokedex.csv', 'rb') {|f| f.lines.map {|l| l.chomp.split(',', -1) } }
e = pokedex.find {|e| e[0] == name}
abort "invalid name: #{name.dump}" if !e


name, ability1, ability2, gender_ratio = *e

# ���ʒl <= ���E�̂Ƃ�: ��
# ���ʒl > ���E�̂Ƃ�: ��

# �ȉ��͈ꌩ�Ԉ���Ă��� '1:7' => 31, '1:3' => 63, '1:1' => 127, '3:1' => 191 ���������Ǝv���邪�A
# ���͕΂��Ă��Ĉȉ��ł����Ă��邻��
# �Q��: http://d.hatena.ne.jp/metagross-armor/20090718/p1
boundaries = {'���̂�' => -1, '���̂�' => 255, '1:7' => 30, '1:3' => 63, '1:1' => 126, '3:1' => 190}

natures = %w(����΂�� ���݂����� �䂤���� �������ς� ��񂿂� ���ԂƂ� ���Ȃ� �̂� ���ς� �̂��Ă� �����т傤 �������� �܂��� �悤�� �ނ��Ⴋ �Ђ����� �����Ƃ� �ꂢ���� �Ă�� ��������� �����₩ ���ƂȂ��� �Ȃ܂��� ���񂿂傤 ���܂���)

puts "%s pid=%#.8x" % [name, pid]
if gender_ratio == '�ӂ߂�'
  puts "����: �s��"
else
  puts "����: " + ((pid & 0xff) > boundaries[gender_ratio] ? "��" : "��")
end

puts "���i: " + natures[pid % 25]
if ability2 == ''
  puts "����: ����#{pid % 2 + 1} #{ability1} (�����͂���̂݁j"
else
  puts "����: ����#{pid % 2 + 1} #{pid % 2 == 0 ? ability1 : ability2} (#{ability1}, #{ability2})"
end
