%%=====================================================================
%% 
%% SPARC: Munk flat case
%% Faro, Sat 22 Jun 2024 06:05:04 PM WEST 
%% Written by Tordar 
%% 
%%=====================================================================

close all, clear all 

disp('SPARC, Munk profile calculations...')

case_title = 'Munk profile';

freq =   50;
zs   = 1000;

Dmax   = 5000;
Rmaxkm =  100;
Rmax   = Rmaxkm*1000;

%==================================================================
%  
%  Sound speed
%  
%==================================================================

load munk.ssp 

zi = munk(:,1)';
ci = munk(:,2)';

Dmax = max( zi );

%==================================================================
%  
%  Source properties
%  
%==================================================================

tx_data.n    =    1; % Number of sources
tx_data.zs   =   zs; % source depths 
tx_data.freq = freq;

%==================================================================
%  
%  Surface properties
%  
%==================================================================

% Last option:
% S => snapshot 
% R => range stack (horizontal array)
% D => depth stack (vertical   array)
top_data.options = '''NVW S''';
top_data.nmesh   = 0; % Number of mesh points (used?)
top_data.csigma  = 0; % RMS roughness (used?)
top_data.zbottom = Dmax; % depth at bottom of medium

%==================================================================
%  
%  Sound speed profile properties
%  
%==================================================================

cs   = zeros( size( zi ) );
rho  =  ones( size( zi ) );
apt = cs; ast = cs; 
ssp_data.data  = [zi;ci;cs;rho;apt;ast];

%==================================================================
%  
%  Bottom properties 
%  
%==================================================================

bottom_data.nlayers = 1;

%==================================================================
%  
% Layers: 
%  
%==================================================================

layer_data = [];

%==================================================================
%  
%  Field parameters
%  
%==================================================================

rx_data.clow   = 1500.0; % CAN'T BE 0!!!!!!
rx_data.chigh  = 1550.0;
rx_data.rmaxkm = 10;
nrd = 201;
rx_data.nrd = nrd;
rx_data.rd  = linspace(0,Dmax,nrd);

% Pulse info (KRAKEN  manual, p. 141):
% PULSE(1:1)
% P => Pseudo-Gaussian 
% R => Ricker wavelet
% A => Approximate Ricker Wavelet
% S => Single sine
% H => Hanning weighted four sine
% N => N-wave
% G => Gaussian 
% F => From a Source Time Series (STS) file 
% B => From a Source Time Series (STS) file backwards
% PULSE(2:2)
% H => perform a Hilbert transform of the source
% N => do not perform... 
% Hilbert transforming eliminates the left travelling wave
% PULSE(3:3)
% + => don't flip (recommended) 
% - => flip 
% PULSE(4:4)
% L => low cut filter 
% H => high cut filter
% B => both high and cut filter
% N => no cut
% Fmin => low  cut frequency 
% Fmax => high cut frequency 
% NRR => number of receiver ranges
%  RR => receiver ranges

%pulse_data.options = 'PN+H';
%ntout = 101;
ntout = 5;
%pulse_data.options = 'PH'; % Artifacts?
pulse_data.options = '''NH+N''';
pulse_data.freqs = [0.0 50.0]; % THis interval should contain the source frequency!!!!!!
pulse_data.nrr = 1;
pulse_data.rrkm = 10; % CAN'T BE LARGER THAN RMAX!!!
pulse_data.ntout = ntout;
tmin = 0.1;
tmax = 6.25;
pulse_data.tout = linspace(tmin,tmax,ntout);
pulse_data.pars = [-0.1 0.98 0.0 0.0 0.0];

%==================================================================
%  
%  Write the env file 
%  
%==================================================================

wsparcenvfil('munk',case_title,tx_data,top_data,ssp_data,bottom_data,layer_data,rx_data,pulse_data);

%==================================================================
%  
%  Write the flp file 
%  
%==================================================================

flpoptions = '''RPO''';
rminkm = 0.01; 
rmaxkm = 10.0 ;
nr     = 501;
fid = fopen('munk.flp','w');
fprintf(fid,'%s\n',flpoptions); % 'R/X (coord), Pos/Neg/Both' 
fprintf(fid,'%d\n',nr); % NR
fprintf(fid,'%f %f /\n',rminkm,rmaxkm); % RMIN, RMAX
fclose( fid );

system('sparc.exe munk');
fieldsco('munk.grn');
plotmovie('munk.shd.mat');

disp('done.')
