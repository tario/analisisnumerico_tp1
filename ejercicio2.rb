require "float_decorator"

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

# la derivada enesima de sin(x) evaluada en pi/2 
derivada_n_sin = lambda{|n|
  if n%2 == 0 # si el numero es par
    if n%4 == 0
      1
    else
      -1
    end
  else # si el numero es impar, vale cero
    0
  end
}
# x0 = pi/2
print "sin(pi/3): "
print taylor(derivada_n_sin, - Math::PI/6.0, lambda{|x,n| (x-Math::sin(Math::PI/3.0)).abs < 0.01}), "\n"


# la derivada enesima de cos(x) evaluada en pi/2 
derivada_n_cos = lambda{|n|
  if n%2 == 0 # si el numero es par, vale cero
    0
  else # si el numero es impar
    if n%4 == 1
      -1
    else
      1
    end
  end
}
# x0 = pi/2
print "cos(pi/3): "
print taylor(derivada_n_cos, - Math::PI/6.0,  lambda{|x,n| (x-Math::cos(Math::PI/3.0)).abs < 0.01}), "\n"

