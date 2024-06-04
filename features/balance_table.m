function [out] = balance_table(tbl,TypeVar,BirthageVar,TestageVar)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
epochtypes = unique(tbl.(TypeVar));
epochtypes = [epochtypes; {'Total'}];
if ~isa(epochtypes,'cell')
    epochtypes = cellstr(epochtypes); end
agetypes = {'Prem<2w','Prem>2w','Term<2w','Term>2w'};
birthages = tbl.(BirthageVar);
testages = tbl.(TestageVar);
out = array2table(nan(length(epochtypes),4),'VariableNames',agetypes,'RowNames',epochtypes);

for n=1:length(epochtypes)
    epochtype = epochtypes{n};
    if n==length(epochtypes)
         tmp = sum(table2array(out),1,'omitnan');
         out{n,:} = tmp;
    else
    for m=1:4
        if m==1
            out{n,m} = sum(tbl.(BirthageVar)<37 & tbl.(TestageVar)<(tbl.(BirthageVar)+2) & strcmp(cellstr(tbl.(TypeVar)),epochtype));
        elseif m==2
            out{n,m} = sum(tbl.(BirthageVar)<37 & tbl.(TestageVar)>=(tbl.(BirthageVar)+2) & strcmp(cellstr(tbl.(TypeVar)),epochtype));
        elseif m==3
            out{n,m} = sum(tbl.(BirthageVar)>=37 & tbl.(TestageVar)<(tbl.(BirthageVar)+2) & strcmp(cellstr(tbl.(TypeVar)),epochtype));
        elseif m==4
            out{n,m} = sum(tbl.(BirthageVar)>=37 & tbl.(TestageVar)>=(tbl.(BirthageVar)+2) & strcmp(cellstr(tbl.(TypeVar)),epochtype));
        end
    end
    end
end
out.TypeTotal = sum(table2array(out),2);

