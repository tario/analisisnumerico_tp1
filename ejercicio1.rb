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

# encuentra la raiz de x = f[x] usando la tecnica del punto fijo
# hasta obtener un error menor que el especificado comparado con
# un valor de referencia
def punto_fijo(f, stop, inicial = 0)
  # asignamos a x el valor inicial
  x = inicial
  xprev = x

  # iteramos infinitamente mientras la diferencia en valor absoluto
  # entre el valor de referencia y x sean superiores al error maximo
  while not stop[x,xprev]
    # en cada iteracion, asignamos a x el resultado de evaluar f[x] con el x anterior
    # como podemos prescindir del x anterior pisamos la misma variable
    # si evaluaramos los errores usando las diferencias entre distintos x de la secuencia
    # utilizariamos otra variable mas el x del ciclo anterior
    xprev = x
    x = f[x]
  end

  # devolvemos el ultimo x calculado
  return x
end

# encuentra la raiz de f[x] = 0 usando la tecnica de newton rapson
# la cual define una funcion cuyo punto fijo es tambien la raiz d f
# es necesario pasar como parametro la derivada
# de la funcion y el criterio de parada que usara el metodo del punto fijo

def newton_rapson(f, fd, stop, inicial = 0)
  # se plantea una funcion cuyo punto fijo es tambien
  # raiz de f[x], segun como lo estipula el metodo de new rapson
  g = lambda{|x| x - f[x]/fd[x] }
  return punto_fijo(g, stop, inicial)
end

# Calcula la raiz exponente de un numero usando el algoritmo iterativo
# de newton-rapson
#
# Ej:
#
#   print "raiz cuadrada de dos: ", raiz(2,2), "\n"
#   print "raiz cuadrada de tres: ", raiz(3,2), "\n"

def raiz(valor,exponente,referencia, contador = nil)
  # planteamos una funcion cuya raiz es tambien la raiz que intentamos aproximar
  funcion = lambda{|x| contador.call;
       x**(exponente) - valor} # NOTA: ** significa elevar x al exponente

  # definimos la derivada de la funcion de la cual queremos obtener el punto fijo
  # ya que el metodo de newton rapson requiere ese parametro tambien
  if exponente == 2
    derivada = lambda{|x| exponente*x }
  else
    derivada = lambda{|x| exponente*x**(exponente-1) }
  end

  # calculamos el valor inicial para usar en el metodo de punto fijo
  # como el promedio entre el rango en el que se supone estara el resultado
  # (ejemplo: la raiz cuadrada de dos esta entra 1 y 2)
  maximo_valor = valor
  minimo_valor = 1
  inicial = (maximo_valor + minimo_valor) / 2 

  # invocar el metodo de newton rapson
  return newton_rapson(funcion, derivada, lambda{|x,xprev| ((x-referencia)/x).abs < 0.0001 }, inicial)
end

require "timeout"
iteraciones = 0

{53 => "doble", 23 => "simple simulada", 14 => "custom 14 bits", 10 => "media simulada"}.each do |k,v|
timeout(10) do

  print "con precision #{v} (#{k} bits de mantisa)\n" 

  contador = lambda{ iteraciones = iteraciones + 1}

  r23 = raiz(3.0.single(k),2.0.single(k), 3**0.5, contador)
  print "raiz cuadrada de tres: #{r23} resuelto con #{iteraciones} iteraciones\n"

  iteraciones = 0
  r25 = raiz(5.0.single(k),2.0.single(k), 5**0.5, contador)
  print "raiz cuadrada de cinco: #{r25}, resuelto con #{iteraciones} iteraciones\n"

  iteraciones = 0
  r33 = raiz(3.0.single(k),3.0.single(k), 3**(1/3.0), contador)
  print "raiz cubica de tres: #{r33}, resuelto con #{iteraciones} iteraciones\n"

  print "\n"
end
end

