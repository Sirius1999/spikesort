% preCachetSNE.m
% this function attempts to pre-calculate t-SNE embeddings for all the data, so that the actual process of spike sorting is faster and less annoying
% 
% usage:
% cd /folder/with/data/from/kontroller
% preCachetSNE('invert_V',true,'variable_name','voltage')
% created by Srinivas Gorur-Shandilya at 9:35 , 11 September 2015. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function [] = preCachetSNE()

variable_name = 'voltage';

% use pref.m to change how this function behaves.
pref = readPref;

% add src to path
% add src folder to path
addpath([fileparts(which(mfilename)) oss 'src'])


allfiles = dir('*.mat');

for i = 1:length(allfiles)
	thisfile = allfiles(i).name;
	if ~strcmp(thisfile,'consolidated_data.mat') && ~strcmp(thisfile,'cached.mat')
		load(thisfile)
		for j = 1:length(data)
			this_control = ControlParadigm(j).Outputs;
			if eval(['~isempty(data(j).' variable_name ')'])
				this_data = eval(['(data(j).' variable_name ')']);

				for k = 1:width(this_data)
					try
						V = this_data(k,:);

						% use templates to remove artifacts
						if exist('template.mat','file')
							if pref.use_on_template || pref.use_off_template
								V = removeArtifactsUsingTemplate(V,this_control,pref);
							end
						end
						

						lc = 1/pref.band_pass(1);
			            lc = floor(lc/pref.deltat);
			            hc = 1/pref.band_pass(2);
			            hc = floor(hc/pref.deltat);
			            V = bandPass(V,lc,hc);

			            % find spikes
						loc = findSpikes(V);

						% take snippets for each putative spike
				        V_snippets = NaN(pref.t_before+pref.t_after,length(loc));
				        if loc(1) < pref.t_before+1
				            loc(1) = [];
				            V_snippets(:,1) = []; 
				        end
				        if loc(end) + pref.t_after+1 > length(V)
				            loc(end) = [];
				            V_snippets(:,end) = [];
				        end
				        for l = 1:length(loc)
				            V_snippets(:,l) = V(loc(l)-pref.t_before+1:loc(l)+pref.t_after);
				        end

				        if pref.ssDebug
				        	disp('We have these many V_snippets')
				        	disp(length(V_snippets))
				        end
					    % run the fast tSNE algorithm on this
					    fast_tsne(V_snippets,2,10,60);
					catch err
						disp(err)
					end
				end
			end
		end
	end
end
