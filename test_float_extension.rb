require "picotest" 
require "float_extension"

# redondeo a 0 decimales
suite( 1.3 => 1.0, 333332.43 => 333332.0 ).test(:binary_round.to_proc)

# redondeo a 1 decimal binario
suite( _set(1.5, 1.52, 1.59, 1.745) => 1.5,
       _set(20.24, 20.0) => 20.0
       ).test( lambda{|x| x.binary_round(1) } )

