clc; close all; clear all;
filepath = 'U:\Desktop\Link_CST_Matlab\';
%%

for R1 = [1:4]
    %%
    cst = actxserver('CSTStudio.application');
    mws = invoke(cst,'OpenFile',[filepath 'Dipole.cst']);
    filenameExport = ['Dipole_R1_' num2str(R1)];
    invoke(mws,'StoreParameter','RHelixU',R1);
    
    mws.invoke('ReBuild');
    mws.invoke('saveas',[filenameExport '.cst'],'false');
    
    solver = invoke(mws, 'Solver');
    invoke(solver,'Start')
    invoke(mws,'Save')
    %% PostProcessing
    myS1p = invoke(mws,'TOUCHSTONE');           % With TOUCHSTONE
    invoke(myS1p, 'Reset');                 %     .Reset
    invoke(myS1p, 'FileName', [filepath filenameExport]);
    %     .FileName (".\example")
    % Since dipole has input impedance 73 Ohms. For all other antennas, set
    % ref. imp. to 50 Ohms.
    invoke(myS1p, 'Impedance',75);          %     .Impedance (50)
    invoke(myS1p, 'FrequencyRange', 'Full')
    invoke(myS1p, 'Renormalize', false)     %     .Renormalize (True)
    invoke(myS1p, 'UseARResults',false)     %     .UseARResults (False)
    invoke(myS1p, 'SetNSamples','100')      %     .SetNSamples (100)
    invoke(myS1p, 'Write')                  %     .Write
    release(myS1p);                             % End With
    
    %%
    FFitem = {'Farfields\farfield (f=1) [1]' 'Farfields\farfield (f=1.5) [1]' 'Farfields\farfield (f=2) [1]'}
    for ii=1:2
        invoke(mws,'SelectTreeItem', FFitem{ii});
        FarfieldPlot = invoke(mws,'FarfieldPlot');
        invoke(FarfieldPlot,'SetPlotMode','directivity');
        % invoke(myFarfieldPlot,'SetPlotMode','gain');

        invoke(FarfieldPlot,'Vary','theta');
        %invoke(myFarfieldPlot,'PlotType','Polar');
        invoke(FarfieldPlot,'PlotType','Cartesian');
        
        MY = invoke(FarfieldPlot,'Plot');
        myFFName{ii} = invoke(FarfieldPlot, 'CopyFarfieldTo1DResults','FarField2Export',['FF' num2str(ii)]);
        
        FFfilename = [filenameExport num2str(ii) '.txt'];
        
        FFexport = invoke(mws,'ASCIIExport');   % With ASCIIExport
        invoke(FFexport, 'Reset');              %     .Reset
        invoke(FFexport, 'FileName', [filepath FFfilename]); %     .FileName (".\example.txt")
        %     .Mode ("FixedNumber")
        %     .StepX (12)
        %     .StepY (12)
        %     .StepZ (8)
        invoke(FFexport,'Execute');%     .Execute
        % End With
        %
    end
    
    
    
    release(solver);
    
    invoke(mws,'Quit')
    clear mws
end

invoke(cst,'Quit')
clear cst
%%
