module NumberHelper
  BANGLA_DIGITS = {
    '0' => '০', '1' => '১', '2' => '২', '3' => '৩', '4' => '৪',
    '5' => '৫', '6' => '৬', '7' => '৭', '8' => '৮', '9' => '৯',
    '.' => '.'
  }

  def number_to_bangla(number)
    number.to_s.chars.map { |c| BANGLA_DIGITS[c] || c }.join
  end
end
