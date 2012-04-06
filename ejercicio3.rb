print "numeros primos entre el 1 y el 1000:\n"

criba = Array.new
2.upto(999) do |numero|
  # es primo hasta que se demuestre lo contrario
  criba[numero] = true
end

2.upto(32) do |numero|
  # marcar todos los multiplos menores que 100
  # si el numero es primo
  if criba[numero]
    i = 2*numero
    while (i < 1000)
      criba[i] = false # no es primo
      i = i + numero
    end
  end
end

primos = (2..999).select(&criba.method(:[]))
2.upto(999) do |numero|
  if criba[numero]
    print numero, '-' 
  end
end
print "\n" 

