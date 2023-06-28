ALPHABET = ('a'..'z').to_a

def caesar_cipher(str, shift = 0)
  shifted_alphabet = ('a'..'z').to_a.rotate(shift)
  str.gsub(/[a-zA-Z]/) do |char|
    new_letter = shifted_alphabet[ALPHABET.find_index(char.downcase)]
    char.match?(/[A-Z]/) ? new_letter.upcase : new_letter
  end
end