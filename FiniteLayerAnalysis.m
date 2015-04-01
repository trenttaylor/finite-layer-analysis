%% FINITE LAYER ANALYSIS
% FiniteLayerAnalysis.m

% 3 Mar 2015
% Trent Taylor

%% DESCRIPTION
% This script is the main script for the finite layer analysis. Function
% calls will be handled and outputs received.

%% WORKSPACE PREPARATION
close all
clear
clc
fprintf([fileread('license'),'\n\n']);
disp('FINITE LAYER ANALYSIS');
%% INPUT PARAMETERS
disp('Getting Cross Sectional Data');
load('defaults.mat');

disp('Cross sections are stored and can be retrieved.');
sectionName = input('Input Cross Section Name:');

if (exist([sectionName,'.mat'],'file') ~= 2)
    
    % Concrete Layers
    layers_conc = getConcreteLayers(defaults.compressiveStrength);

    % Steel Layers
    layers_ps = getSteelLayers(defaults.prestressGrade);
    layers_r = getSteelLayers(defaults.steelGrade);
    
    save([sectionName,'.mat'],'layers_conc','layers_ps','layers_r');
else
    load([sectionName,'.mat']);
end

% numerical tolerances
sub_layers = 100; % number of layers to divide each layer
tolerance = .001; % tolerance factor for numerical calculations (should be less than or equal to .001)
max_iterations = 1e9; % maximum number of iterations

%% CALCULATIONS
%% Section Properties
% gross moment of inertia
%Ig = calculateMomentOfInertia(layers_conc);

temp = [layers_conc{:}];
b = max(temp.width);
d = layers_conc{1,end}.distanceToBot;
dt_ps = getSteelCentroid(layers_ps);

% calculate epsilon1
eps_all = [.001];

for eps = eps_all(1:end)

    %% initilization
    diff = 1;
    j = 0;
    
    %% guess c
    c = dt_ps / 2;

    
    while (diff > tolerance)
        j = j+1;
        F_conc_subLayers = [];
        h_subLayers = [];
        
        %% re-estimate c after first iteration
        if (j~=1 && F_conc > F_ps + F_r)
            % F_conc is too big, decrease c
            c = c - c*tolerance;
            
        elseif (j~=1 && F_conc < F_ps + F_r)
            % F_conc is too small, increase c
            c = c + c*tolerance;
        end
        
        %% curvature
        phi = eps/c;
        
        %% calculate stress & force in concrete
        for layer_c = layers_conc(1:end)
            % height of each sub layer
            h = layer_c{1}.distanceToBot - layer_c{1}.distanceToTop;
            dh = h/sub_layers;
            b = layer_c{1}.width;
            
            for subLayer = layer_c{1}.distanceToBot:-dh:layer_c{1}.distanceToTop+dh
                %% calculate stress at top & bottom using hognestead
                f_top = 1;%getHognestead();
                f_bot = 1;%getHognestead();
                
                %% calculate force at sub layer
                F_conc_subLayers(size(F_conc_subLayers,2)+1) = b*(f_top + f_bot)/2;
                h_subLayers(size(h_subLayers,2)+1) = c-(subLayer+dh/2);
            end
        end
        
        % sum forces
        F_conc = sum(F_conc_subLayers);
        
        %% calculate stress & force in prestress
        
        
        F_ps = 0;
        
        %% calculate stress & force in passive steel
        % TODO: Implmement passive reinforcement
        F_r = 0;
        
        %% sum forces
        diff = F_conc + F_ps + F_r;
        
        if (j > max_iterations)
            error('Non-converging solution. Exceeded maximum number of iterations');
        end
        
    end
    
    
    
end 

%% RESULTS
    
    %%
    
    
    %%
       

disp('FINISHED!')


%% LICENSE
%{
    The MIT License (MIT)

    Copyright (c) 2015 trenttaylor

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
%}