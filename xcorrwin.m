function [corrOut,shiftVal] = xcorrwin(x,y,lagSize)

x = x(:);
y = y(:);

n = (0:length(x)-1)'; 
shiftVal = (-lagSize:lagSize)';

corrOut = zeros(length(x),length(shiftVal));
dumm = zeros(size(x));
norm = conv(ones(size(x)),ones(lagSize,1),'same');


for i=1:length(shiftVal)
    dumm = x .* circshift(y, shiftVal(i));
    corrOut(:,i) = conv(dumm,ones(lagSize,1),'same')./norm;
end
1;

end