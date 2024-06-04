function [birthGAs, testGAs] = get_ages(agesfilename, IDlist)
% Extracts participant ages from an excel file.
% Outputs
% birthGAs: List of gestational ages at birth, in weeks, using the order and
% length of IDlist.
% testGAs: List of gestational ages at test, in weeks, using the order and
% length of IDlist.

if ~isa(agesfilename,"string")
    warning('agesfilename must be a string, using default value.')
    agesfilename = "./data/ages.xlsx";
end
[sz1, sz2] = size(IDlist);
if (sz1 > 1) && (sz2 > 1)
    error('IDlist must be a 2D array')
end

% import the age data
opts = spreadsheetImportOptions("NumVariables", 7);
opts.Sheet = "export";
opts.DataRange = "A2:G834";
opts.VariableNames = ["ResearchProject", "ParticipantNumber", "TestOccasionNumber", "GestationAtBirthW", "GestationAtBirthD", "GestationalAgeAtTestOccasionW", "GestationalAgeAtTestOccasionD"];
opts.VariableTypes = ["string", "string", "string", "double", "double", "double", "double"];
opts = setvaropts(opts, ["ResearchProject", "ParticipantNumber", "TestOccasionNumber"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["ResearchProject", "ParticipantNumber", "TestOccasionNumber"], "EmptyFieldRule", "auto");

ages = readtable(agesfilename, opts, "UseExcel", false);
clear opts

ages.ID = strcat(ages{:,"ResearchProject"}, ages{:,"ParticipantNumber"}, ages{:,"TestOccasionNumber"});
ages.GAbirth = ages.GestationAtBirthW + (ages.GestationAtBirthD/7);
ages.GAtest = ages.GestationalAgeAtTestOccasionW + (ages.GestationalAgeAtTestOccasionD/7);

birthGAs = nan(size(IDlist));
testGAs = nan(size(IDlist));
for n=1:length(IDlist)
    row_in_age = find(strcmpi(ages.ID,IDlist(n)));
    birthGAs(n) = ages.GAbirth(row_in_age);
    testGAs(n) = ages.GAtest(row_in_age);
end