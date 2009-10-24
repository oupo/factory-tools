module Roma2reg
  # ���[�}�����琳�K�\�������R�[�h�͈ȉ�����q�؂��܂���
  # http://la.ma.la/misc/aws/beta.html
  
  KANA_MAP = Hash[*%w(a �A i �C yi �C u �E wu �E whu �E e �G o �I la �@ xa �@ li �B xi �B lyi �B xyi �B lu �D xu �D le �F xe �F lye �F xye �F lo �H xo �H wha �E�@ whi �E�B wi �E�B whe �E�F we �E�F who �E�H ka �J ca �J ki �L ku �N cu �N qu �N ke �P ko �R co �R lka �� xka �� lke �� xke �� ga �K gi �M gu �O ge �Q go �S kya �L�� kyi �L�B kyu �L�� kye �L�F kyo �L�� qya �N�� qyu �N�� qwa �N�@ qa �N�@ kwa �N�@ qwi �N�B qi �N�B qyi �N�B qwu �N�D qwe �N�F qe �N�F qye �N�F qwo �N�H qo �N�H gya �M�� gyi �M�B gyu �M�� gye �M�F gyo �M�� gwa �O�@ gwi �O�B gwu �O�D gwe �O�F gwo �O�H sa �T si �V ci �V shi �V su �X se �Z ce �Z so �\ za �U zi �W ji �W zu �Y ze �[ zo �] sya �V�� sha �V�� syi �V�B syu �V�� shu �V�� sye �V�F she �V�F syo �V�� sho �V�� swa �X�@ swi �X�B swu �X�D swe �X�F swo �X�H zya �W�� ja �W�� jya �W�� zyi �W�B jyi �W�B zyu �W�� ju �W�� jyu �W�� zye �W�F je �W�F jye �W�F zyo �W�� jo �W�� jyo �W�� ta �^ ti �` chi �` tu �c tsu �c te �e to �g ltu �b xtu �b ltsu �b da �_ di �a du �d de �f do �h tya �`�� cha �`�� cya �`�� tyi �`�B cyi �`�B tyu �`�� chu �`�� cyu �`�� tye �`�F che �`�F cye �`�F tyo �`�� cho �`�� cyo �`�� tsa �c�@ tsi �c�B tse �c�F tso �c�H tha �e�� thi �e�B thu �e�� the �e�F tho �e�� twa �g�@ twi �g�B twu �g�D twe �g�F two �g�H dya �a�� dyi �a�B dyu �a�� dye �a�F dyo �a�� dha �f�� dhi �f�B dhu �f�� dhe �f�F dho �f�� dwa �h�@ dwi �h�B dwu �h�D dwe �h�F dwo �h�H na �i ni �j nu �k ne �l no �m nya �j��|���� nyi �j�B nyu �j��|���� nye �j�F nyo �j��|���� ha �n hi �q hu �t fu �t he �w ho �z ba �o bi �r bu �u be �x bo �{ pa �p pi �s pu �v pe �y po �| hya �q�� hyi �q�B hyu �q�� hye �q�F hyo �q�� fya �t�� fyu �t�� fyo �t�� fwa �t�@ fa �t�@ fwi �t�B fi �t�B fyi �t�B fwu �t�D fwe �t�F fe �t�F fye �t�F fwo �t�H fo �t�H bya �r�� byi �r�B byu �r�� bye �r�F byo �r�� va ���@ vi ���B vu �� ve ���F vo ���H vya ���� vyi ���B vyu ���� vye ���F vyo ���� pya �s�� pyi �s�B pyu �s�� pye �s�F pyo �s�� ma �} mi �~ mu �� me �� mo �� mya �~�� myi �~�B myu �~�� mye �~�F myo �~�� ya �� yu �� yo �� lya �� xya �� lyu �� xyu �� lyo �� xyo �� ra �� ri �� ru �� re �� ro �� rya ���� ryi ���B ryu ���� rye ���F ryo ���� wa �� wo �� n �� nn �� n' �� xn �� lwa �� xwa �� bb �b cc �b dd �b ff �b gg �b hh �b jj �b kk �b ll �b mm �b pp �b qq �b rr �b ss �b tt �b vv �b ww �b xx �b yy �b zz �b - �[)]
  
  module_function
  def roma2reg(text)
    result = ""
    len = 0
    i = 0
    chars = text.split(//)
    while true
      i += len
      break if i >= chars.size
      len = 1
      t = chars[i]
      if /[a-z-]/ !~ t
        result << Regexp.escape(t)
        next
      end
      t = search_token(chars, i)
      if !t
        result << t
        next
      end
      kana = KANA_MAP[t]
      if t.size == 2 && kana == "�b"
        result << "(?:#{t[0,1]}|#{kana})"
      else
        result << "(?:#{t}|#{kana})"
        len = t.size
      end
    end
    result
  end
  
  def search_token(chars, i)
    4.downto(1) do |n|
      token = chars[i, n].join
      if KANA_MAP.include?(token)
        return token
      end
    end
    nil
  end
end

def roma2reg(text)
  Roma2reg.roma2reg(text)
end
