
class Float
  def binary_round(decimals = 0)
    factor = 2**decimals
    (self * factor).round(0).to_f / factor
  end
end
