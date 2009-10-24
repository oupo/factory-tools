if /win32/ =~ RUBY_PLATFORM
  require 'kconv'
  def $stdout.write(s)
    super s.to_s.kconv(Kconv::SJIS, Kconv::UTF8)
  end
  def $stderr.write(s)
    super s.to_s.kconv(Kconv::SJIS, Kconv::UTF8)
  end
  def gets(*)
    result = super
    result && result.kconv(Kconv::UTF8, Kconv::SJIS)
  end
  ARGV.map! {|i| i.kconv(Kconv::UTF8, Kconv::SJIS) }
end
