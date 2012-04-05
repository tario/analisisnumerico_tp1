require "float_decorator"

# encuentra la raiz de x = f[x] usando la tecnica del punto fijo
# hasta obtener un error menor que el especificado comparado con
# un valor de referencia
def punto_fijo(f, error_maximo, referencia, inicial = 0)
  # asignamos a x el valor inicial
  x = inicial

  # iteramos infinitamente mientras la diferencia en valor absoluto
  # entre el valor de referencia y x sean superiores al error maximo
  while (x-referencia).abs > error_maximo
    # en cada iteracion, asignamos a x el resultado de evaluar f[x] con el x anterior
    # como podemos prescindir del x anterior pisamos la misma variable
    # si evaluaramos los errores usando las diferencias entre distintos x de la secuencia
    # utilizariamos otra variable mas el x del ciclo anterior
    x = f[x]
  end

  # devolvemos el ultimo x calculado
  return x
end

# encuentra la raiz de f[x] = 0 usando la tecnica de newton rapson
# iterando hasta obtener un error menor que el especificado comparado
# con un valor de referencia, es necesario pasar como parametro la derivada
# de la funcion

def newton_rapson(f, fd, error_maximo, referencia, inicial = 0)
  # se plantea una funcion cuyo punto fijo es tambien
  # raiz de f[x], segun como lo estipula el metodo de new rapson
  g = lambda{|x| x - f[x]/fd[x] }
  return punto_fijo(g, error_maximo, referencia, inicial)
end

# Calcula la raiz exponente de un numero usando el algoritmo iterativo
# de newton-rapson
#
# Ej:
#
#   print "raiz cuadrada de dos: ", raiz(2,2), "\n"
#   print "raiz cuadrada de tres: ", raiz(3,2), "\n"

def raiz(valor,exponente,referencia)
  # planteamos una funcion cuya raiz es tambien la raiz que intentamos aproximar
  funcion = lambda{|x| x**(exponente) - valor} # NOTA: ** significa elevar x al exponente

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
  return newton_rapson(funcion, derivada, 0.01, referencia, inicial)
end

print "con precision doble (mantisa: 52 bits)\n" 

print "raiz cuadrada de tres: ", raiz(3.0,2.0, 3**0.5), "\n"
print "raiz cuadrada de cinco: ", raiz(5.0,2.0, 5**0.5), "\n"
print "raiz cubica de tres: ", raiz(3.0,3.0, 3**(1.0/3.0)), "\n"

print "con precision simple (mantisa: 23 bits)\n" 

print "raiz cuadrada de tres: ", raiz(3.0.single,2.0.single, 3**0.5), "\n"
print "raiz cuadrada de cinco: ", raiz(5.0.single,2.0.single, 5**0.5), "\n"
print "raiz cubica de tres: ", raiz(3.0.single,3.0.single, 3**(1.0/3.0)), "\n"
