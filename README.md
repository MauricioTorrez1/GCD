# GCD
Procesador digital que calcula el máximo común divisor dados dos números binarios de 8 bits.

- control_unit.sv:  Los tiempos del procesador son manejados por la Unidad de Control, compuesta por una máquina de estados. Y esta unidad, a su vez, proporciona señales a la ruta de datos; como la carga en un registro, la señal de selección a un multiplexor y otras.
  
- datapath.sv: La ruta de datos(datapath) es un módulo compuesto por registros, multiplexores y otros componentes lógicos y aritméticos. El módulo de la ruta de datos proporciona varias señales de estado (conditional flags) a la Unidad de Control.

- gcd_processor.sv: Instancia ambas unidades (datapath y control_unit) en un solo procesador lógico.

-x7segmux: Permite observar los valores de entrada (xin, yin) y el resultado (gcd) a tráves del display de 7 segmentos en formato hexadecimal.
