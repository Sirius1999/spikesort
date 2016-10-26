%% plugins.m
% shows the installed plugins with associated methods
% 
function varargout = plugins(s)

p.name = '';
p.plugin_type = '';
p.plugin_dimension = [];


if ~nargout
    disp('The following plugins for spikesort have been installed:')
end

m = dir([fileparts(which(mfilename)) oss '*.m']);

c = 1;
for i = 1:length(m)
    % read the file
    t = lineRead([fileparts(which(mfilename)) oss m(i).name]);

    if ~any(strfind(t{1},'spikesort plugin'))
        continue
    end

    p(c).name = strrep(m(i).name,'.m','');
    
    plugin_type = 'unknown';
    plugin_dimension = NaN;

    eval(strrep(t{2},'%',''));
    eval(strrep(t{3},'%',''));

    p(c).plugin_dimension = plugin_dimension;
    p(c).plugin_type = plugin_type;
    c = c + 1;
end

if ~nargout
    cprintf('_text','Plugin ')
    cprintf('text',repmat(' ',1,10))
    cprintf('_text','Type ')
    cprintf('text',repmat(' ',1,10))
    cprintf('_text','Dimension\n')
    for i = 1:length(p)
        fprintf(p(i).name)
        fprintf(repmat(' ',1,16 - length(p(i).name)));
        fprintf(p(i).plugin_type)
        fprintf(repmat(' ',1,16 - length(p(i).plugin_type)));
        fprintf(oval(p(i).plugin_dimension))
        fprintf('\n')
    end
else
    s.installed_plugins = p;
    varargout{1} = s;
end
