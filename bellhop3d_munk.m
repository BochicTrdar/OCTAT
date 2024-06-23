%======================================================================
% 
% Bellhop3D: Munk profile ray tracing test
% Faro, Sat 22 Jun 2024 06:13:51 PM WEST 
% Written by Tordar 
%
%======================================================================

close all, clear all

case_title = '''Munk profile'''; 

freq  = 50;

Rkm = 100; R = Rkm*1000; 

dz = 50; D = 5000; depths = [0:dz:D]; 
 
B  = 1.3e3 ; B2 = B*B;

epsilon = 7.37e-3 ;  

z1 = 1200; c1 = 1480;

eta = 2*( depths - z1 )/B ; 

c   = c1*( 1 + epsilon*( eta + exp( -eta ) - 1 ) ); 

%figure(1)
%plot( c , depths ), box on, grid on, view(0,-90)
%xlabel('Sound speen (m/s)')
%ylabel('Depth (m)')
%title('Munk profile')

%==================================================================
%  
%  Source:
%  
%==================================================================

source_data.nx       =  1;
source_data.ny       =  1;
source_data.nz       =  1;
source_data.box      = [100 100 100 5000]; % [step(m) xbox(km) ybox(km) zbox(m)]
source_data.f        = freq;
source_data.thetas   = [51  6 -20 20];
source_data.phi      = [11 46 -2   2];
source_data.bearings = [2 0 1];
source_data.p        = [];
source_data.comp     = '';
source_data.xs       =     0;
source_data.ys       =     0;
source_data.zs       =  1000;

%==================================================================
%  
%  Surface:
%  
%==================================================================

surface_data.x = [];
surface_data.itype = '''L'''; % Not used, but required...
surface_data.p    =       []; % Not used, but required...
 
%==================================================================
%  
%  Sound speed profile:
%  
%==================================================================

ssp_data.r   = [];
ssp_data.z   = depths;
ssp_data.c   = c;

%==================================================================
%  
%  Bottom:
%  
%==================================================================

bottom_data.p     = [1600 0 1.8 0.8];
bottom_data.aunits = '''W''' ; % Bottom absorption units: (dB/m)*kHZ 
bottom_data.itype = '''R'''; % Not used, but required...
bottom_data.nx = 2;
bottom_data.ny = 2;
bottom_data.x  = [0 100];
bottom_data.y  = [-100 100];
bottom_data.z  = [3000 3000;5000 5000];

%==================================================================
%  
%  Array:
%  
%==================================================================
%Read the Bellhop manual to understand the meaning of the options: 
%options.options1    = '''SVWT*'''; 
options.options1    = '''SVWT'''; % No ati file expected  
%options.options2    = '''A*'''; 
options.options2    = '''A'''; % No bty file expected
options.options3    = '''R'''; % Rays
%options.options3    = '''E'''; % EigenRays
%options.options3    = '''C'''; % Coherent TL (rewrite final block accordingly) 
options.options4    = []; 
options.nrd =  401; 
options.nr  = 1001;
options.rd  = [1000 4000]; 
options.r   = [0  100];

output_option = options.options3;

wbellhop3denv('munk',case_title,source_data,surface_data,ssp_data,bottom_data,options);

disp('Calling Bellhop3D...')

system('bellhop3d.exe munk');

plotray3d('munk.ray');

disp('done.')
