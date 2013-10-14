function [C N]=unique2(y)

if length(y)~=0
    
    x = y(:)';
    
    indx = logical([diff(x)>0 1]);
    
    n = 1:length(x);
    
    C = x(indx); %Different components
    N = diff([0 n(indx)]); %Number of repetitions
    
    if iscolumn(y)
        C=C(:);
        N=N(:);
    end
    
else
    C=[];
    N=[];
end


end
