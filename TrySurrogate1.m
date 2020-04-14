clc; close all; clear all;
global filepath
global filenameExport
global cst;
global mws;

filepath = [pwd '\']; % Sets filepath to current directory
filenameExport = 'Dipole'; %['SolidTeflon' num2str(100*Lu)];

    cst = actxserver('CSTStudio.application'); % Uses latest CST version
%   cst = actxserver('CSTStudio.application.2019'); % Specify a CST version here 2019

mws = invoke(cst,'OpenFile',[filepath filenameExport '.cst']);

%%

rng default % For reproducibility
fun = @(x) costSurrogateCST(cst,x);
InitialSet  = [85 2];
LowerBounds = [50 0.1];
UpperBounds = [95 5];
type costSurrogateCST.m;

options = optimoptions('surrogateopt','MaxFunctionEvaluations',300,...
    'InitialPoints',InitialSet,'UseParallel',false,'PlotFcn','surrogateoptplot');

problem = struct('objective',fun,...
    'lb',LowerBounds,...
    'ub',UpperBounds,...
    'options',options,...
    'solver','surrogateopt');
[xopt,fval,exitflag,output,trials] = surrogateopt(problem)

save OptResult.mat