function [meansiv, stdsiv, tsiv]=avsiv(TractFA, Tracts)

figure
hold on
for i=1:length(TractFA);
plot3(Tracts{i}(1,1), Tracts{i}(1,2), Tracts{i}(1,3), '*');
end

pause;
ncut = 0;
while ncut < 5 || ncut > 15
    ncut=input('Enter cutoff for flip: ');
end

for i=1:length(TractFA)
    siv1=TractFA{i};
    if Tracts{i}(1,2)>ncut
        siv1=flipud(siv1);
    end
    rsiv1=imresize(double(siv1), 100/length(siv1));
    tsiv(:,i)=rsiv1(1:100,1);
end
meansiv=mean(tsiv,2);
stdsiv=std(tsiv,0,2)./sqrt(length(TractFA));
