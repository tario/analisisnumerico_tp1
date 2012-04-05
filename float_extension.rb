
class Float
  def binary_round(decimals = 0)
    factor = 2**decimals
    (self * factor).round(0).to_f / factor
  end

  # extrae la mantisa del numero
  def mantissa
    compute_mantissa_and_exponent unless @mantissa
    @mantissa
  end

  def exponent
    compute_mantissa_and_exponent unless @exponente
    @exponent
  end

  def sign
    if self < 0
      -1
    elsif self > 0
      1
    else
      0
    end
  end

  def rounded_mantissa(decimals = 0)
    sign * 2 ** exponent * mantissa.binary_round(decimals)   
  end

private

  def compute_mantissa_and_exponent

    x = self.abs
    exponente = 0

    while (x < 1.0 or x >= 2.0)
      if x < 1.0
        exponente = exponente - 1
        x = x * 2 
      elsif x >= 2.0
        exponente = exponente + 1
        x = x / 2
      end
    end

    @exponent = exponente
    @mantissa = x
  end

end
