def substrings(str, dictionary)
  dictionary.each.with_object(Hash.new(0)) do |dict_word, result|
    str.split.each { |word| result[dict_word] += 1 if word.downcase.include?(dict_word.downcase) }
  end
end
