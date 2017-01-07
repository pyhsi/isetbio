function [ois, scene] = oisCreate(oisType,composition, modulation, varargin)
% OISCREATE - oi sequence creation
%    oiSequence objects are used to specify certain simple stimuli that vary
%    over time, such as stimuli used in typical psychophysical experiments.
%
%    [ois, scenes] = OISCREATE(oisType,composition,modulation,'PARAM1',val ...)
%
%  Required parameters 
%   'oisType'      - Stimulus type. One of 'vernier','harmonic','impulse'. 
%   'composition'  - 'add' or 'blend'
%   'modulation'   - Vector of weights describing the add or blend parameters.
%
%  Optional parameter/val types chosen from the following 
%    'testParameters'   Parameters for the test targets 
%    'sceneParameters'  General scene parameters (e.g., fov, luminance)
%    
%    The sequence is a composition of a fixed OI and a modulated OI. The mixture
%    is determined by a time series of weights.  The composition can be either
%    an addition or a blend of the two OIs.
%
%  Harmonics
%   clear hparams
%   hparams(2) = harmonicP; hparams(2).freq = 6; hparams(2).GaborFlag = .2; 
%   hparams(1) = hparams(2); hparams(1).contrast = 0; sparams.fov = 1; 
%   stimWeights = ieScale(fspecial('gaussian',[1,50],15),0,1);
%   ois = oisCreate('harmonic','blend',stimWeights, ...
%                   'testParameters',hparams, ...
%                   'ssceneParams',sparams);
%   ois.visualize;
%
%  Vernier
%   clear vparams; vparams(2) = vernierP; 
%   vparams(2).name = 'offset'; vparams(2).bgColor = 0; vparams(1) = vparams(2); 
%   vparams(1).barWidth = 0; vparams(1).bgColor = 0.5; vparams(1).name = 'uniform';
%   stimWeights = ieScale(fspecial('gaussian',[1,50],15),0,1);
%   [vernier, scenes] = oisCreate('vernier','add', stimWeights,...
%                                 'testParameters',vparams,...
%                                 'sceneParameters',sparams);
%   vernier.visualize;
%   ieAddObject(scenes{1}); ieAddObject(scenes{2}); sceneWindow;
%
% Impulse 
%   clear iparams
%   sparams.fov = 1; sparams.luminance = 100;
%   stimWeights = zeros(1,50); stimWeights(2:4) = 1;
%   impulse = oisCreate('impulse','add', stimWeights,...
%                       'sceneParameters',sparams);
%   impulse.visualize;
%
% See also SCENECREATE   
%
% See ISETBIO wiki <a "href=matlab:
% web('https://github.com/isetbio/isetbio/wiki/OI Sequences','-browser')">,'Retinal
% images'</a>
% BW ISETBIO Team, 2016

%% Inputs
p = inputParser;
p.addRequired('oisType',@ischar)
p.addRequired('composition',@ischar);
p.addRequired('modulation');

p.addParameter('sampleTimes',[],@isvector);
p.addParameter('testParameters',[],@isstruct);
p.addParameter('sceneParameters',[],@isstruct);

p.parse(oisType,composition,modulation,varargin{:});

oisType = ieParamFormat(oisType);

sampleTimes = p.Results.sampleTimes;
if isempty(sampleTimes)
    sampleTimes = 0.001*((1:length(modulation))-1);
end

% Many of the types have a params structure that we will pass along
tparams = p.Results.testParameters;   % Test stimulus parameters (two structs needed)
sparams = p.Results.sceneParameters;   % Scene parameters, only one set.

%%
switch oisType
    case 'harmonic'
        % oisCreate('harmonic', ...); % See examples
        if length(tparams) ~= 2, error('Specify two harmonic param sets.'); end
        scene = cell(1,2);
        OIs = cell(1, 2);

        % Create basic harmonics
        for ii=1:2
            scene{ii} = sceneCreate('harmonic',tparams(ii));
            sname = sprintf('F %d C %.2f', tparams(ii).freq, tparams(ii).contrast);
            scene{ii} = sceneSet(scene{ii},'name',sname);
        end
        % ieAddObject(scene{1}); ieAddObject(scene{2}); sceneWindow;
        
        % Adjust both scenes based on sparams.
        fields = fieldnames(sparams);
        if ~isempty(fields)
            for ii=1:length(fields)
                for jj=1:2
                    val = sparams.(fields{ii});
                    scene{jj} = sceneSet(scene{jj}, fields{ii},val);
                end
            end
        end
        
        % Compute optical images from the scene
        oi = oiCreate('wvf human');
        for ii = 1:2
            OIs{ii} = oiCompute(oi,scene{ii});
        end
        % ieAddObject(OIs{1}); ieAddObject(OIs{2}); oiWindow;

        %% Build the oiSequence
        
        % The weights define some amount of the constant background and some amount
        % of the line on the same constant background
        ois = oiSequence(OIs{1}, OIs{2}, sampleTimes, modulation, ...
            'composition', composition);
        
    case 'vernier'
        % oisCreate('vernier', ...);   % See examples
        if length(tparams) ~= 2, error('Specify two vernier param sets.'); end
        scene = cell(1,2);
        OIs = cell(1, 2);
        
        % Create vernier stimulus and background
        for ii=1:2
            scene{ii} = sceneCreate('vernier', 'display', tparams(ii));
            scene{ii} = sceneSet(scene{ii},'name',tparams(ii).name);
        end
        
        % Adjust both scenes based on sparams.
        fields = fieldnames(sparams);
        if ~isempty(fields)
            for ii=1:length(fields)
                for jj=1:2
                    val = sparams.(fields{ii});
                    scene{jj} = sceneSet(scene{jj}, fields{ii},val);
                end
            end
        end
        %ieAddObject(scene{1}); ieAddObject(scene{2}); sceneWindow;

        % Compute optical images from the scene
        oi = oiCreate('wvf human');
        for ii = 1:2
            OIs{ii} = oiCompute(oi,scene{ii});
        end
        % ieAddObject(OIs{1}); ieAddObject(OIs{2}); oiWindow;

        ois = oiSequence(OIs{1}, OIs{2}, sampleTimes, modulation, ...
            'composition', composition);
        % ois.visualize;
        
    case 'impulse'
        % oisCreate('impulse', 'add', weights,'sparams',sparams); % See examples
        scene = cell(1,2);
        OIs = cell(1, 2);
        
        for ii=1:2
            scene{ii} = sceneCreate('uniform ee');
        end
        
        % Adjust both scenes based on sparams.
        if ~isempty(sparams)
            fields = fieldnames(sparams);
            if ~isempty(fields)
                for ii=1:length(fields)
                    for jj=1:2
                        val = sparams.(fields{ii});
                        scene{jj} = sceneSet(scene{jj}, fields{ii}, val);
                    end
                end
            end
        end
        %ieAddObject(scene{1}); ieAddObject(scene{2}); sceneWindow;
        
        % Compute optical images from the scene
        oi = oiCreate('wvf human');
        for ii = 1:2
            OIs{ii} = oiCompute(oi,scene{ii});
        end
        % ieAddObject(OIs{1}); ieAddObject(OIs{2}); oiWindow;
        
        ois = oiSequence(OIs{1}, OIs{2}, sampleTimes, modulation, ...
            'composition', composition);
        % ois.visualize;  % Not working right.  Something about image scale
        
        % Potentially return the cell array of scenes.
        varargout{1} = scene;
        
    otherwise
        error('Unknown type %s\n',oisType);
end

%%