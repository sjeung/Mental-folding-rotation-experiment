function m = mrand(l,what)

if nargin<2
    what='default';
end

if strcmp(what,'rows')
    l=l';
end

m = zeros(size(l));
ncols = size(m,2);

for i=1:ncols
    m(:,i)=vrand(l(:,i));
end

if strcmp(what,'rows')
    m=m';
end