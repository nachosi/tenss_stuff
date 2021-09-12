function [The2Dhisto, Xv, Yv] = My2DHistogram(X, Y, Xbins, Ybins, fig)
The2Dhisto = nan(length(Xbins)-1, length(Ybins)-1);
for i=1:length(Xbins)-1
    for j=1:length(Ybins)-1
        The2Dhisto(i, j) = sum(X>=Xbins(i) & X<Xbins(i+1) &...
            Y>=Ybins(j) & Y<Ybins(j+1));
    end
    
end
Xv = Xbins(1:end-1)+min(diff(Xbins))/2;
Yv = Ybins(1:end-1)+min(diff(Ybins))/2;

if fig

imagesc(Yv,Xv, The2Dhisto)
end

end