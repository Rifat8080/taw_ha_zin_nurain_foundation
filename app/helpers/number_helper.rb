module NumberHelper
  BANGLA_DIGITS = {
    "0" => "\u09E6", "1" => "\u09E7", "2" => "\u09E8", "3" => "\u09E9", "4" => "\u09EA",
    "5" => "\u09EB", "6" => "\u09EC", "7" => "\u09ED", "8" => "\u09EE", "9" => "\u09EF",
    "." => "."
  }

  def number_to_bangla(number)
    number.to_s.chars.map { |c| BANGLA_DIGITS[c] || c }.join
  end
end
