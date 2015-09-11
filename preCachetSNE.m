% preCachetSNE.m
% this function attempts to pre-calculate t-SNE embeddings for all the data, so that the actual process of spike sorting is faster and less annoying
% 
% usage:
% cd /folder/with/data/from/kontroller
% preCachetSNE('find_spikes_in_positive_V',true,'variable_name','voltage')
% created by Srinivas Gorur-Shandilya at 9:35 , 11 September 2015. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function preCachetSNE(varargin)

% defaults
find_spikes_in_positive_V = true;
variable_name = 'voltage';

if iseven(nargin)
	for ii = 1:2:length(varargin)-1
    	temp = varargin{ii};
    	if ischar(temp)
        	eval(strcat(temp,'=varargin{ii+1};'));
    	end
	end
else
    error('Inputs need to be name value pairs')
end

allfiles = dir('*.mat');

for i = 1:length(allfiles)
	thisfile = allfiles(i).name;
	if ~strcmp(thisfile,'consolidated_data.mat') && ~strcmp(thisfile,'cached.mat')
		load(thisfile)
		for j = 1:length(data)
			if eval(['~isempty(data(j).' variable_name ')'])
				this_data = eval(['(data(j).' variable_name ')']);
				for k = 1:width(this_data)
					try
						v_cutoff = -1;
						mpw = 1;
						mpd = 1;
						V = bandPass(this_data(k,:),100,10);
						mpp = std(V)/2;
						
						% find peaks and remove spikes beyond v_cutoff
				        if ~find_spikes_in_positive_V
				            [~,loc] = findpeaks(-V,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw);
				            loc(V(loc) < -abs(v_cutoff)) = [];
				        else
				            [~,loc] = findpeaks(V,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw);
				            loc(V(loc) > abs(v_cutoff)) = [];
				        end

						% take snippets for each putative spike
				        t_before = 20;
				        t_after = 25; % assumes dt = 1e-4
				        V_snippets = NaN(t_before+t_after,length(loc));
				        for i = 2:length(loc)-1
				            V_snippets(:,i) = V(loc(i)-t_before+1:loc(i)+t_after);
				        end
				        loc(1) = []; V_snippets(:,1) = []; 
				        loc(end) = []; V_snippets(:,end) = [];

				        disp(length(V_snippets))
					    % run the fast tSNE algorithm on this
					    fast_tsne(V_snippets,2,10,60);
					catch err
						err
					end
				end
			end
		end
	end
end
