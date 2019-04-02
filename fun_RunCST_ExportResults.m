function fun_RunCST_ExportResults(L1,R1)

global filepath;
global filenameExport;
global cst;
global mws;

invoke(mws,'StoreParameter','L1',L1);
invoke(mws,'StoreParameter','R1',R1);

mws.invoke('ReBuild');
%mws.invoke('saveas',[filenameExport '.cst'],'false');

solver = invoke(mws, 'Solver');
invoke(solver,'Start')
%invoke(mws,'Save')
%% PostProcessing
myS1p = invoke(mws,'TOUCHSTONE');           % With TOUCHSTONE
invoke(myS1p, 'Reset');                 %     .Reset
invoke(myS1p, 'FileName', [filepath filenameExport]);
%     .FileName (".\example")
invoke(myS1p, 'Impedance',50);          %     .Impedance (50)
invoke(myS1p, 'FrequencyRange', 'Full');
invoke(myS1p, 'Renormalize', false);    %     .Renormalize (True)
invoke(myS1p, 'UseARResults',false);    %     .UseARResults (False)
invoke(myS1p, 'SetNSamples','101');     %     .SetNSamples (100)
invoke(myS1p, 'Write');                 %     .Write
release(myS1p);                             % End With

%%
FFitem = {'Farfields\farfield (f=1) [1]' 'Farfields\farfield (f=2) [1]'};
for ii=1:2
    
    invoke(mws,'SelectTreeItem', FFitem{ii});
    FarfieldPlot = invoke(mws,'FarfieldPlot');
    %invoke(FarfieldPlot,'SetPlotMode','directivity');
    %invoke(FarfieldPlot,'SetPlotMode','gain');
    invoke(FarfieldPlot,'SetPlotMode','realized gain');
    %invoke(myFarfieldPlot,'SetFrequency',2.1);
    invoke(FarfieldPlot,'Vary','theta');
    %invoke(myFarfieldPlot,'PlotType','Polar');
    %invoke(FarfieldPlot,'PlotType','Cartesian');
    
    LorH =['L' 'H'];
    MY = invoke(FarfieldPlot,'Plot');
    myFFName{ii} = invoke(FarfieldPlot, 'CopyFarfieldTo1DResults','FarField2Export',['FF' num2str(ii)]);
    
    FFfilename = [filenameExport LorH(ii) '.txt'];
    
    FFexport = invoke(mws,'ASCIIExport');   % With ASCIIExport
    invoke(FFexport, 'Reset');              %     .Reset
    invoke(FFexport, 'FileName', [filepath FFfilename]); %     .FileName (".\example.txt")
    %     .Mode ("FixedNumber")
    %     .StepX (12)
    %     .StepY (12)
    %     .StepZ (8)
    invoke(FFexport,'Execute');%     .Execute
    % End With
end