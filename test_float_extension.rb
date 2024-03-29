require "picotest" 
require "float_extension"

# redondeo a 0 decimales
suite( 1.3 => 1.0, 333332.43 => 333332.0 ).test(:binary_round.to_proc)

# redondeo a 1 decimal binario
suite( _set(1.5, 1.52, 1.59, 1.745) => 1.5,
       _set(20.24, 20.0) => 20.0
       ).test( lambda{|x| x.binary_round(1) } )

# extraccion de mantisa binaria
suite( _set(1.0, 1.25, 1.5, 1.75) => lambda{|x|x}, 
       _set(2.0, 2.5, 3.0, 3.5) => lambda{|x|x/2},
       _set(0.5, 0.625, 0.75, 0.875) => lambda{|x|x*2}
     ).test( :mantissa.to_proc )

# extraccion de exponente binario
suite( _set(1.0, 1.25, 1.5, 1.75) => 0, 
       _set(2.0, 2.5, 3.0, 3.5) => 1,
       _set(0.5, 0.625, 0.75, 0.875) => -1
     ).test( :exponent.to_proc )

# redondeo de mantisa a 0 decimales
suite(_set(2.3, 2.2, 2.1, 2.25, 2.45) => 2.0).test(:rounded_mantissa.to_proc)
suite(_set(3.75, 3.8) => 4.0).test(:rounded_mantissa.to_proc)

# redondeo de mantisa a 1 decimal
suite(_set(2.75, 2.6, 2.8) => 3.0, _set(2.3, 2.2, 2.1, 2.25, 2.45) => 2.0, 2048.5 => 2048.0).test( lambda{|x| x.rounded_mantissa(1)})


