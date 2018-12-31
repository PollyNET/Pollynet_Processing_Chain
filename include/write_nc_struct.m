function write_nc_struct(nc_file, dimensions, data, attributes);

disp(['Writing ' nc_file]);
f = netcdf(nc_file, 'clobber');


% Define dimensions
dimension_names = fieldnames(dimensions);
for ii = 1:length(dimension_names)
  disp(['   Adding dimension ' dimension_names{ii}]);
  f(dimension_names{ii}) = getfield(dimensions, dimension_names{ii});
end

% Set global attributes
attribute_names = fieldnames(attributes.global);
for ii = 1:length(attribute_names)
  disp(['   Adding global attribute ' attribute_names{ii}]);
  value = getfield(attributes.global, attribute_names{ii});
  [nc_class, straightjacket] = class2ncclass(value);
  if ~isempty(nc_class)
    eval(['f.' attribute_names{ii} ' = nc' nc_class '(' straightjacket '(value));']);
  else
    warning(['Global attribute ' attribute_names{ii} ' omitted due to incompatible type']);
  end
end

% Set variable information
variable_names = fieldnames(data);
for ii = 1:length(variable_names)
  disp(['   Adding variable ' variable_names{ii}]);
  value = getfield(data, variable_names{ii});
  varattributes = getfield(attributes, variable_names{ii});
  vardimensions = getfield(varattributes, 'dimensions');
  nc_class = class2ncclass(value);
  if ~isempty(nc_class)
    if isfield(varattributes,'missing_value')
      missing_value = varattributes.missing_value;
    end
    varinfo = {nc_class};
    for jj = 1:length(vardimensions)
      varinfo{jj+1} = vardimensions{jj};
    end
    f{variable_names{ii}} = varinfo;
    % Set attributes
    attribute_names = fieldnames(varattributes);
    for jj = 1:length(attribute_names)
      if strcmp(attribute_names{jj}, 'dimensions')
	continue;
      end
      disp(['      adding attribute ' variable_names{ii} '.' attribute_names{jj}]);
      value = getfield(varattributes, attribute_names{jj});
      [attr_nc_class, straightjacket] = class2ncclass(value);
      if ~isempty(attr_nc_class)
	if strcmp(attribute_names{jj},'missing_value') | strcmp(attribute_names{jj},'plot_range') 
	  attr_nc_class = nc_class;
	end
	eval(['f{variable_names{ii}}.' attribute_names{jj} ' = nc' attr_nc_class '(' straightjacket '(value));']);
      else
	warning(['Attribute ' variable_names{ii} '.' attribute_names{jj} ' omitted due to incompatible type']);
      end
    end
  else
    warning(['Variable ' variable_names{ii} ' ommitted due to incompatible type']);
  end
end

% Fill variables
variable_names = fieldnames(data);
for ii = 1:length(variable_names)
  value = getfield(data, variable_names{ii});
  varattributes = getfield(attributes, variable_names{ii});
  nc_class = class2ncclass(value);
  disp(['   Filling variable ' variable_names{ii} ' (' nc_class ')']);
  if ~isempty(nc_class)
    if isfield(varattributes,'missing_value') & strcmp(nc_class,'float')
      missing_value = varattributes.missing_value;
      value(find(isnan(value))) = missing_value;
    end
    f{variable_names{ii}}(:) = value;
  else
    warning(['Variable ' variable_names{ii} ' ommitted due to incompatible type']);
  end
end

close(f)

function [nc_class, straightjacket]  = class2ncclass(variable)
matclass = class(variable);
straightjacket = '';
if strcmp(matclass, 'double')
  nc_class = 'float'; % Only ever output floats...
elseif strcmp(matclass, 'single')
  nc_class = 'float';
elseif strcmp(matclass, 'char')
  nc_class = 'char';
elseif strcmp(matclass, 'int8')
  nc_class = 'byte';
  straightjacket = 'double';
elseif strcmp(matclass, 'int16')
  nc_class = 'short';
  straightjacket = 'double';
elseif strcmp(matclass, 'int32')
  nc_class = 'int';
else
  warning(['Unable to save matlab variables of type ' matclass ' in NetCDF']);
  nc_class = '';
end
