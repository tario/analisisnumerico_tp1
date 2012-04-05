require "float_extension" 

class Numeric
  def to_single_precision(decimals)
    FloatPrecisionDecorator.new(self.rounded_mantissa(decimals), decimals)
  end
end

class FloatPrecisionDecorator 
  def initialize(inner, decimals)
    @decimals = decimals
    @inner = inner.to_f
  end

  def method_missing(m,*x)
    # todas las operaciones sobre el numero se ejecutan sobre el float verdadero
    # y se obtiene el verdadero resultado con precision completa del Float original
    verdadero_resultado = @inner.send(m,*x)

    # si es numeric, truncar y wrappear
    if Numeric === verdadero_resultado
      # se reduce la precision, multiplicando por el factor, redondeando y volviendo a dividir
      reduced = verdadero_resultado.to_f.rounded_mantissa(@decimals)
      FloatPrecisionDecorator.new(reduced, @decimals)
    else
      # si no, devolve el resultado como es
      verdadero_resultado
    end
  end

  def coerce(other)
    return self, other
  end

  def inspect
    # para que llame al inspect del float decorado
    @inner.inspect
  end
end
