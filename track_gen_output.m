function data1 = track_gen_output(x, conditions);

data1.conditions = conditions;  % Original conditions
data1.x = x;                 % Original data

data1.t = (0:size(x,1)-1)/conditions.Controller_Update_Clock;  % Time axis
data1.n = 1:size(x,2);       % Realization axis

data1.scnx_cmd = x(:,:,1);   % Commanded position to scanner in X
data1.scny_cmd = x(:,:,2);   % Commanded position to scanner in Y
data1.scnx = x(:,:,3);       % Measured position of scanner in X
data1.scny = x(:,:,4);       % Measured position of scanner in Y
data1.stgx = x(:,:,5);       % Stage position in X
data1.stgy = x(:,:,6);       % Stage position in Y

data1.trg = bitget(x(:,:,7) ,1); %Stage movement trigger
data1.fb = bitget(x(:,:,7) ,5);  %feedback state

data1.apd1 = x(:,:,8);       % APD 1 counts
data1.apd2 = x(:,:,9);       % APD 2 counts
data1.apd3 = x(:,:,10);      % APD 3 counts
data1.apds = x(:,:,8:10);    % Combined APD counts
data1.apds_norm = x(:,:,8:10)/max(max(max(x(:,:,8:10))));    % Combined APD counts
