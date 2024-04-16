function enum_obj = enum_helper(enum_names, description)

    if nargin<2 || isempty(description)
        description = '';
    end
    
    enum_obj = cell2struct(num2cell(uint32(0:(length(enum_names)-1))),enum_names,2);
    enum_obj.Description = description;

end