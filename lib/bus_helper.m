%%
function bus_helper(bs,elems)
% Inputs:
%   bs: a bus definition structure 
%
%   ele_struct: bus element definition structure array
%

    % run common checks
    if isa(elems,'cell')
        bus_checker_c(elems)
        be = cellfun(@(x) bus_elem_from_cell(x{:}) ,elems,'Uniformoutput',0);
    elseif isa(elems,'struct')
        bus_checker(elems)
        be = arrayfun(@bus_elem,elems,'Uniformoutput',0);
    else
        error('Unknown input type for bus elements')
    end
    
    c = {{bs.BusName,bs.HeaderFile,bs.Desc,bs.DataScope,bs.Alignment,be}};
    Simulink.Bus.cellToObject(c);
end

function e = bus_elem_from_cell(varargin)

    p=inputParser;
    addParameter(p,'ElementName','unnamed');
    addParameter(p,'Description','no_description_given');
    addParameter(p,'Unit','no_unit_given');
    addParameter(p,'Dimensions',1);
    addParameter(p,'DataType','double');
    addParameter(p,'Min',[]);
    addParameter(p,'Max',[]);
    addParameter(p,'SampleTime',-1);
    addParameter(p,'Complexity','real');
    addParameter(p,'SamplingMode','Sample');
    addParameter(p,'DimensionsMode','Fixed');
    parse(p,varargin{:});
    r=p.Results;
    if strcmp(r.ElementName,'unnamed') || strcmp(r.Description,'no_description_given') || strcmp(r.Unit,'no_unit_given')
        error('Required parameters are ElementName, Description, and Unit.')
    end
    
    e = {r.ElementName,r.Dimensions,r.DataType,r.SampleTime,r.Complexity,r.SamplingMode,r.DimensionsMode,r.Min,r.Max,r.Unit,r.Description};
    
end



function e = bus_elem(s)
    if nargin<1 || isempty(s)
        s=struct();
    end
    s = default_val(s,'ElementName','a');
    s = default_val(s,'Dimensions',1);
    s = default_val(s,'DataType','double');
    s = default_val(s,'Min',[]);
    s = default_val(s,'Max',[]);
    s = default_val(s,'Unit','');
    s = default_val(s,'Description','');
    s = default_val(s,'SampleTime',-1);
    s = default_val(s,'Complexity','real');
    s = default_val(s,'SamplingMode','Sample');
    s = default_val(s,'DimensionsMode','Fixed');
    
    fndiff = setdiff(fieldnames(s),{'ElementName','Dimensions','DataType','Min','Max','Unit','Description','SampleTime','Complexity','SamplingMode','DimensionsMode'});
    if ~isempty(fndiff)
        error(sprintf('Tried to create a bus element with a unexpected fieldname: ''%s''',fndiff{:}))
    end
    
    e = {s.ElementName,s.Dimensions,s.DataType,s.SampleTime,s.Complexity,s.SamplingMode,s.DimensionsMode,s.Min,s.Max,s.Unit,s.Description};
    
    function s = default_val(s,name,default_val)
        if ~isfield(s,name)
            s.(name)=default_val;
        end
    end
end

function bus_checker(ele_struct)
% perform a few common checks on the inputs
    % check for unique names
    name_array = arrayfun(@(x) x.ElementName,ele_struct,'uniformoutput',0);
    [u,m] = unique(name_array); nu = setdiff(1:length(name_array),m);
    assert(length(name_array) == length(u),sprintf("Found non-unique bus element name: '%s'\n",name_array{nu}))

end

function bus_checker_c(elems)
    % check for non-unique names
	name_array = cellfun(@(x) x{2},elems,'Uniformoutput',0);
    [u,m] = unique(name_array); nu = setdiff(1:length(name_array),m);
    assert(length(name_array) == length(u),sprintf("Found non-unique bus element name: '%s'\n",name_array{nu}))
    % check for repeated fields
    flag = cellfun(@(x) length(x(1:2:end))==length(unique(x(1:2:end))),elems);
    assert(all(flag==1),sprintf("Found repeated field names for element: %s\n",name_array{find(flag==0)}))
end