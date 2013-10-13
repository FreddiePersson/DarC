filename = 'scan 2013.06.13 14.18.56.h5'; %'h5ex_d_rdwr.h5';

h5disp(filename);

info = h5info(filename);

adc_clock = h5read(filename, '/Parameters/ADC Clock');


