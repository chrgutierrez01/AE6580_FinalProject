function prm = param_helper(value,varargin)

    p=inputParser;
    addRequired(p,'value');
    addParameter(p,'Description','');
    addParameter(p,'Dimensions',[1,1]);
    addParameter(p,'Min',[]);
    addParameter(p,'Max',[]);
    addParameter(p,'Unit','');
    addParameter(p,'DataType','auto');
    
    parse(p,value,varargin{:});
    
    prm = Simulink.Parameter(value);
    prm.Description = p.Results.Description;
    prm.Min = p.Results.Min;
    prm.Max = p.Results.Max;
    prm.Unit = p.Results.Unit;
    prm.Dimensions = p.Results.Dimensions;
    prm.DataType = p.Results.DataType;
   
end
