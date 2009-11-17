module RandomPronounceableString
  def random_pronounceable_string
    letters = { ?v => 'aeiou',
                ?c => 'bcdfghjklmnprstvwyz' }
    word = ''
    'cvcvcv'.each_byte do |x|
      source = letters[x]
      word << source[rand(source.length)].chr
    end
    return word
  end
end