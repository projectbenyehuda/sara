require 'hebrew'

HEBMONTHS = { 'ניסן' => 1, 'אייר' => 2, 'סיון' => 3, 'סיוון' => 3, 'תמוז' => 4, 'אב' => 5, 'אלול' => 6, 'תשרי' => 7, 'חשון' => 8, 'חשוון' => 8, 'כסלו' => 9, 'טבת' => 10, 'שבט' => 11, 'אדר' => 12 } # handling Adar Bet is a special pain we're knowingly ignoring
GREGMONTHS = {'ינואר' => 1,'פברואר' => 2,'מרץ' => 3,'מרס' => 3,'מארס' => 3,'אפריל' => 4,'מאי' => 5,'יוני' => 6,'יולי' => 7,'אוגוסט' => 8,'אבגוסט' => 8,'ספטמבר' => 9,'אוקטובר' => 10,'נובמבר' => 11, 'דצמבר' => 12}
HEB_LETTER_VALUE = {'א' => 1, 'ב' => 2, 'ג' => 3, 'ד' => 4, 'ה' => 5, 'ו' => 6, 'ז' => 7, 'ח' => 8, 'ט' => 9, 'י' => 10, 'כ' => 20, 'ך' => 20, 'ל' => 30, 'מ' => 40, 'ם' => 40, 'נ' => 50, 'ן' => 50, 'ס' => 60, 'ע' => 70, 'פ' => 80, 'ף' => 80, 'צ' => 90, 'ץ' => 90, 'ק' => 100, 'ר' => 200, 'ש' => 300, 'ת' => 400}

  def parse_gregorian(str)
    if(str =~ /(\d+)[-\/\.–](\d\d?)[-\/\.–](\d+)/) # try to match numeric date
      begin
        return Date.new($3.to_i, $2.to_i, $1.to_i)
      rescue Date::Error
        return Date.new($1.to_i, $2.to_i, $3.to_i)
      end
    end
    # perhaps there's a date with spaces and a Gregorian month name in Hebrew
    GREGMONTHS.keys.each do |m|
      unless str.match(/ב?#{m}\s+/).nil?
        month = GREGMONTHS[m]
        pre = $`
        year = $'.match(/\d+/).to_s.to_i
        day = (pre.match(/\d+/)) ? $&.to_i : 15 # mid-month by default
        unless day > 31 || day < 1 # avoid exceptions on weird date strings
          return Date.new(year, month, day)
        end
      end
    end
    # we couldn't identify a month; try to use just the year
    str.match(/\d+/)
    yearpart = $&
    yearpart = yearpart[0..3] if yearpart.length > 4 # handle 'YYYYMMDD'
    begin
      return Date.new(yearpart.to_i, 7, 1) # mid-year by default
    rescue Date::Error
      return nil
    end
  end

  def parse_hebrew_year(str)
    i = 0
    s = str
    if str[0] == 'ה'
      i += 5000
      s = str[1..-1]
    elsif str[0] == 'ד'
      i += 4000
      s = str[1..-1]
    end
    s.each_char{|c| i += HEB_LETTER_VALUE[c]}
    i += 5000 if i < 1000 and i != 0 # assume current Hebrew millennium if no other one is specified
    return i
  end

  def parse_hebrew_day(str)
    s = str.tr("\'\"",'') # ignore quotes
    s = s[0..1] if s.length > 2 # ignore prefixes like ב
    s = s[0] unless s.length == 1 || ['ט','י','כ','ל'].include?(s[0]) # only possible first-letters of a two-character hebrew date day
    i = 0
    s.each_char{|c| i += HEB_LETTER_VALUE[c]}
    return i
  end

  def parse_hebrew_date(str)
    HEBMONTHS.keys.each do |m|
      unless str.match(/ב?\S*#{m}\s+/).nil?
        month = HEBMONTHS[m]
        pre = $`
        rpos = $`.rindex(' ')
        pre = $`[0..rpos - 1] unless rpos.nil? # move back to last space (because month may have contained a prefix, like מרחשוון)
        rpos = pre.rindex(' ')
        pre = pre[rpos + 1..-1] unless pre.empty? or rpos.nil?
        year = $'.match(/\S+\"\S/).to_s.strip.tr('\"\'','')
        if pre.empty?
          day = 15
        else
          day = parse_hebrew_day(pre) || 15 # mid-month by default
        end
        hyear = parse_hebrew_year(year)
        unless hyear.nil? || hyear == 0
          hd = Hebruby::HebrewDate.new(day, month, hyear)
          return hd.julian_date
        else
          return nil
        end
      end
    end
    return nil
  end

  def normalize_date(str)
    return nil if str.nil? or str.empty?
    # first look for digits
    return parse_gregorian(str) if str.match(/\d+/)
    # parse hebrew date
    if str.any_hebrew?
      return parse_hebrew_date(str)
    else
      return nil
    end
  end

  def normalize_year(str)
    ndate = normalize_date(str)
    return nil if ndate.nil?
    return ndate.year
  end