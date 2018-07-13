function Score = dicomcompare(basedicom,querydicom)
Score = 0;

basefields = fields(basedicom);
queryfields = fields(querydicom);
Commonfields = cell(0,0);
for i = 1:size(basefields,1)
    if ~(sum(strcmp(basefields{i,1},queryfields)) == 0)
        Commonfields{end+1,1} = basefields{i,1};
    end
end

for i = 1:size(Commonfields,1)
    EntryType = class(basedicom.(Commonfields{i,1}));
    switch EntryType
        case 'char'
            if strcmp(basedicom.(Commonfields{i,1}),querydicom.(Commonfields{i,1}))
                Score = Score + 1;
            end
        case 'double'
            if isequal(basedicom.(Commonfields{i,1}),querydicom.(Commonfields{i,1}))
                Score = Score + 1;
            end
        case 'uint16'
            if isequal(basedicom.(Commonfields{i,1}),querydicom.(Commonfields{i,1}))
                Score = Score + 1;
            end
        case 'uint32'
            if isequal(basedicom.(Commonfields{i,1}),querydicom.(Commonfields{i,1}))
                Score = Score + 1;
            end
        case 'struct'
        otherwise
    end
end