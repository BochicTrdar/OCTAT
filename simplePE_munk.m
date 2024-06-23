%%=====================================================================
%% 
%% Simple PE Munk waveguide
%% Faro, Sat 22 Jun 2024 09:40:36 PM WEST 
%% Written by Tordar 
%% 
%%=====================================================================

% It works, but still needs some tunning... any suggestions?

close all, clear all 

case_title = 'Munk profile'; 

freq = 50;

Rkm = 100; R = Rkm*1000; rmax = R;

zs = 1200; 
D = 5000; nz = 101;
depths = linspace(0,D,nz); 
 
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

%===================
% Bottom
%===================

bottom_properties  = [1600 2.0 0];

%===================
% source definition 
%===================

source_nrays =    90;    % number of propagation rays considered
source_aperture = 45;    % maximum launching angle (degrees)
source_ray_step =100;    % ray calculation step (meters)

%==================================================================
%  
%  Source properties 
%  
%==================================================================

zbox = D+500;
rbox = Rkm;
source_data.box      = [source_ray_step zbox rbox];
source_data.f        = freq;
source_data.thetas   = [source_nrays -source_aperture source_aperture];
source_data.p        = [];
source_data.comp     = '';
source_data.position = zs;

%==================================================================
%  
%  Surface definition: flat
%  
%==================================================================

surface_data.itype = ''' ''';          % Sea surface interpolation type 
surface_data.x     = [];               % The *.ati file won't be written  
surface_data.p     = [];               % Surface properties 

%==================================================================
%  
%  Sound speed profile properties
%  
%==================================================================

ssp_data.r   = [];
ssp_data.z   = depths;
ssp_data.c   = c;

%==================================================================
%  
%  Bottom definition: flat
%  
%==================================================================

bottom_data.itype = ''' ''';          % Sea surface interpolation type
bottom_data.x     = [];               % The *.bty file won't be written 
bottom_data.p     = [bottom_properties(1) 0.0 bottom_properties(2:3)]; % Bottom properties 
bottom_data.aunits = '''W''' ; % Bottom absorption units: (dB/m)*kHZ 
%==================================================================
%  
%  Array properties 
%  
%==================================================================
nza = 501;
nra = 201;
rarray = linspace(0,rmax,nra); rarraykm = rarray/1000; 
zarray = linspace(0,D,nza);
%Read Bellhop's manual to understand the meaning of the options: 
options.options1    = '''SVWT'''; % No ati file expected  
options.options2    = '''A'''; % No bty file expected
options.options3    = '''R'''; %      Rays
%options.options3    = '''E'''; % EigenRays
%options.options3    = '''C'''; % Coherent TL (rewrite final block accordingly) 
options.options4    = []; 
options.r = rarraykm; 
options.z = zarray;
output_option = options.options3;

wbellhopenvfil('munk',case_title,source_data,surface_data,ssp_data,bottom_data,options);

disp('Calling simplePE...')

simplePE( 'munk' )

load("munk.shd.mat")

p = squeeze( pressure );

tl = -20*log10( abs( p ) );

tej = flipud( colormap(jet) ); 

figure(1)
pcolor(rarray,zarray,tl), shading interp, colormap(tej), colorbar, caxis([50 100])
view(0,-90)
xlabel('Range (m)')
ylabel('Depth (m)')
title('SimplePE - Munk waveguide')

disp('done.')
