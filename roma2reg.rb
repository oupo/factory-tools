module Roma2reg
  # ローマ字から正規表現を作るコードは以下から拝借しました
  # http://la.ma.la/misc/aws/beta.html
  
  KANA_MAP = Hash[*%w(a ア i イ yi イ u ウ wu ウ whu ウ e エ o オ la ァ xa ァ li ィ xi ィ lyi ィ xyi ィ lu ゥ xu ゥ le ェ xe ェ lye ェ xye ェ lo ォ xo ォ wha ウァ whi ウィ wi ウィ whe ウェ we ウェ who ウォ ka カ ca カ ki キ ku ク cu ク qu ク ke ケ ko コ co コ lka ヵ xka ヵ lke ヶ xke ヶ ga ガ gi ギ gu グ ge ゲ go ゴ kya キャ kyi キィ kyu キュ kye キェ kyo キョ qya クャ qyu クュ qwa クァ qa クァ kwa クァ qwi クィ qi クィ qyi クィ qwu クゥ qwe クェ qe クェ qye クェ qwo クォ qo クォ gya ギャ gyi ギィ gyu ギュ gye ギェ gyo ギョ gwa グァ gwi グィ gwu グゥ gwe グェ gwo グォ sa サ si シ ci シ shi シ su ス se セ ce セ so ソ za ザ zi ジ ji ジ zu ズ ze ゼ zo ゾ sya シャ sha シャ syi シィ syu シュ shu シュ sye シェ she シェ syo ショ sho ショ swa スァ swi スィ swu スゥ swe スェ swo スォ zya ジャ ja ジャ jya ジャ zyi ジィ jyi ジィ zyu ジュ ju ジュ jyu ジュ zye ジェ je ジェ jye ジェ zyo ジョ jo ジョ jyo ジョ ta タ ti チ chi チ tu ツ tsu ツ te テ to ト ltu ッ xtu ッ ltsu ッ da ダ di ヂ du ヅ de デ do ド tya チャ cha チャ cya チャ tyi チィ cyi チィ tyu チュ chu チュ cyu チュ tye チェ che チェ cye チェ tyo チョ cho チョ cyo チョ tsa ツァ tsi ツィ tse ツェ tso ツォ tha テャ thi ティ thu テュ the テェ tho テョ twa トァ twi トィ twu トゥ twe トェ two トォ dya ヂャ dyi ヂィ dyu ヂュ dye ヂェ dyo ヂョ dha デャ dhi ディ dhu デュ dhe デェ dho デョ dwa ドァ dwi ドィ dwu ドゥ dwe ドェ dwo ドォ na ナ ni ニ nu ヌ ne ネ no ノ nya ニャ|ンヤ nyi ニィ nyu ニュ|ンユ nye ニェ nyo ニョ|ンヨ ha ハ hi ヒ hu フ fu フ he ヘ ho ホ ba バ bi ビ bu ブ be ベ bo ボ pa パ pi ピ pu プ pe ペ po ポ hya ヒャ hyi ヒィ hyu ヒュ hye ヒェ hyo ヒョ fya フャ fyu フュ fyo フョ fwa ファ fa ファ fwi フィ fi フィ fyi フィ fwu フゥ fwe フェ fe フェ fye フェ fwo フォ fo フォ bya ビャ byi ビィ byu ビュ bye ビェ byo ビョ va ヴァ vi ヴィ vu ヴ ve ヴェ vo ヴォ vya ヴャ vyi ヴィ vyu ヴュ vye ヴェ vyo ヴョ pya ピャ pyi ピィ pyu ピュ pye ピェ pyo ピョ ma マ mi ミ mu ム me メ mo モ mya ミャ myi ミィ myu ミュ mye ミェ myo ミョ ya ヤ yu ユ yo ヨ lya ャ xya ャ lyu ュ xyu ュ lyo ョ xyo ョ ra ラ ri リ ru ル re レ ro ロ rya リャ ryi リィ ryu リュ rye リェ ryo リョ wa ワ wo ヲ n ン nn ン n' ン xn ン lwa ヮ xwa ヮ bb ッ cc ッ dd ッ ff ッ gg ッ hh ッ jj ッ kk ッ ll ッ mm ッ pp ッ qq ッ rr ッ ss ッ tt ッ vv ッ ww ッ xx ッ yy ッ zz ッ - ー)]
  
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
      if t.size == 2 && kana == "ッ"
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
