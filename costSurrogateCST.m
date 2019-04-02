function cost = costSurrogateCST(cst,x)
% x = [L1 R1]
L1 = x(1);
R1 = x(2);

global filenameExport;
global filepath;
global cst;
global mws;

Gmin = [2.0412  2.0412];      %dB
fmin = 2.4e9;  %Hz
fmax = 2.5e9;   %Hz
S11max = 10^(-10/20); %Convert dB to normal number
theta_boresight = 90;
penaltyG = [0];

fun_RunCST_ExportResults(L1,R1)

S = sparameters([filepath filenameExport '.s1p']);
S11 = squeeze(S.Parameters);

i_fmin = min(find(S.Frequencies(:,1)>fmin));
i_fmax = min(find(S.Frequencies(:,1)>fmax));

IntS11 = sum(abs(S11(find(abs(S11(i_fmin:i_fmax))>S11max))));

%%
LorH =['L' 'H'];
for jj=1:2
    FFfilename = [filenameExport LorH(jj) '.txt'];
    
    FF = dlmread([filepath FFfilename],'',3,0);
    theta = FF(1:36,1);
    phi = FF(:,2);
    
    G_theta_dB = FF(1:36,4);
    
    i_boresight = find(theta==theta_boresight);
    
    if ( theta(find(G_theta_dB==max(G_theta_dB)))< (theta(i_boresight)-5) ) ...
        || (G_theta_dB(i_boresight)<Gmin(jj) )
    penaltyG(jj) = 1;
    end
    
    G_boresight(jj) = G_theta_dB(i_boresight);
    clear FF,G_theta_dB;
end

disp('Geometry') 

x 

IntS11
G_boresight

if sum(penaltyG)>0    
    cost = 10;
elseif IntS11
    cost = IntS11;
else
    cost =  -sum(G_boresight-Gmin);  %Hopefully gets here :)
end
cost