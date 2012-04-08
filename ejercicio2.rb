class Float
  def binary_round(decimals = 0)
    factor = 2**decimals
    (self * factor).round.to_f / factor
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
    if self == 0
      @mantissa = 0.0
      @exponent = 0.0
      return
    end

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

class Numeric
  def to_single_precision(decimals)
    FloatPrecisionDecorator.new(self.rounded_mantissa(decimals), decimals)
  end

  def single(decimals = 23)
    decimals > 52 ? self : to_single_precision(decimals)
  end
end

class FloatPrecisionDecorator 
  def initialize(inner, decimals)
    @decimals = decimals
    @inner = inner.to_f
  end

  def to_f
    @inner
  end

  def ==(other)
    self.to_f == other.to_f
  end

  def method_missing(m,*x)
    # todas las operaciones sobre el numero se ejecutan sobre el float verdadero
    # y se obtiene el verdadero resultado con precision completa del Float original

    if x.size > 0
      if FloatPrecisionDecorator === x.first
        verdadero_resultado = @inner.send(m,x.first.instance_variable_get(:@inner))
      else
        verdadero_resultado = @inner.send(m,*x)
      end    
    else
      verdadero_resultado = @inner.send(m,*x)
    end
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

  def to_s
    @inner.to_s
  end

  def inspect
    # para que llame al inspect del float decorado
    @inner.inspect
  end
end

# efectua la sumatoria de los terminos de una sucesion hasta
# que se acerque suficiente a un referencia
# el tercer parametro, es el criterio de parada que debera determinar
# en funcion de x y de n si se debe parar o no
def serie(sucesion, stop)
  x = 0.0
  n = 0
  while not stop[x,n]
    x = x + sucesion[n]
    n = n + 1
  end

  x
end


def factorial(n)
  n > 1 ? (2..n).inject(&:*) : 1
end

# efectua la suma de taylor dada la derivada enesima en el punto x0
# y la diferencia entre x-x0 hasta que se acerque suficiente a una referencia
# el tercer parametro, es el criterio de parada
def taylor(derivada_n, diferenciax0, stop)
  # crear los terminos de la sumatoria de taylor en funcion de n
  sucesion = lambda{|n| 
      derivada_n[n] * diferenciax0 ** n / factorial(n) }
  # efectuar la sumatoria de la serie
  serie(sucesion, stop)
end

require "timeout"
{53 => "doble", 23 => "simple simulada", 14 => "custom 14 bits", 10 => "media simulada"}.each do |k,v|

timeout(10) do

  print "Con precision #{v} (#{k} bits de mantisa):\n"

  ops = 0
  iteraciones = 0

  # la derivada enesima de sin(x) evaluada en pi/2 
  derivada_n_sin = lambda{|n|
    iteraciones = iteraciones + 1
    if n%2 == 0 # si el numero es par
      if n%4 == 0
        1.0.single(k)
      else
        -1.0.single(k)
      end
    else # si el numero es impar, vale cero
      0.0.single(k)
    end
  }

  # x0 = pi/2
  print "sin(pi/3): "
  referencia = Math::sin(Math::PI/3.0)
  print taylor(derivada_n_sin, - Math::PI/6.0,  lambda{|x,n| ((x-referencia) / (x == 0.0 ? 0.01 : x) ).abs < 0.0001}), " resuelto con #{iteraciones} iteraciones\n"

  iteraciones = 0
  # la derivada enesima de cos(x) evaluada en pi/2 
  derivada_n_cos = lambda{|n|
    iteraciones = iteraciones + 1
    if n%2 == 0 # si el numero es par, vale cero
      0.0.single(k) 
    else # si el numero es impar
      if n%4 == 1
        -1.0.single(k)
      else
        1.0.single(k)
      end
    end
  }
  # x0 = pi/2
  print "cos(pi/3): "
  referencia = Math::cos(Math::PI/3.0)
  print taylor(derivada_n_cos, - Math::PI/6.0,  lambda{|x,n| ((x-referencia) / (x == 0.0 ? 0.01 : x) ).abs < 0.0001}), " resuelto con #{iteraciones} iteraciones\n"
  print "\n"
end

end

