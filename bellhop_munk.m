%%=====================================================================
%% 
%% Bellhop: Munk profile test
%% Faro, Sat 22 Jun 2024 09:41:28 PM WEST 
%% Written by Tordar 
%% 
%%=====================================================================

close all, clear all 

case_title = 'Munk profile'; 

freq  = 500;

Rkm = 100; R = Rkm*1000; 

dz = 50; D = 5000; zs = 1200; depths = [0:dz:D]; 
 
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

%cs = interp1(depths,c,zs); 
source_nrays =    10;    % number of propagation rays considered %
source_aperture = 30;    % maximum launching angle (degrees) %
source_ray_step =100;    % ray calculation step (meters) %
%optimal_dtheta = sqrt( cs/(10*freq*R) );
%optimal_nrays  = fix( 2*source_aperture*(pi/180)/optimal_dtheta );
%if source_nrays < optimal_nrays 
%warning1 = ['This frequency requires at least ' num2str(optimal_nrays) ' rays!'];
%warning2 = ['(only ' num2str(source_nrays) ' rays requested)...'];
%disp( warning1 )
%disp( warning2 ) 
%end

%==================================================================
%  
%  Source properties 
%  
%==================================================================

zbox = D+500;
rbox = Rkm-1;
source_data.box      = [source_ray_step zbox rbox];
source_data.f        = freq;
source_data.thetas   = [source_nrays -source_aperture source_aperture];
source_data.p        = [];
source_data.comp     = '';
source_data.position = zs;

%==================================================================
%  
%  Surface definition: idealized wavy surface
%  
%==================================================================

 nati = 1001; lambda = R/10; k = 2*pi/lambda; zati0 = 200;
 rati = linspace(0,R,nati);
 zati = zati0*sin( k*rati ); zati = zati - min( zati );
 surface_data.itype = '''L''';          % Sea surface interpolation type
 surface_data.x     = [rati/1000;zati]; % Surface coordinates 
%surface_data.x     = [];               % The *.ati file won't be written  
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
%  Bottom definition: idealized Gaussian sea mountain
%  
%==================================================================

 rbty = rati; raux = ( rbty - R/2 );  
 zbty = -2000*exp( -raux.^2/1e9 ) + D;
 bottom_data.itype = '''L''';          % Sea surface interpolation type
 bottom_data.x     = [rbty/1000;zbty]; % Bottom coordinates 
%bottom_data.x     = [];               % The *.bty file won't be written 
 bottom_data.p     = [bottom_properties(1) 0.0 bottom_properties(2:3)]; % Bottom properties 
 bottom_data.aunits = '''W''' ; % Bottom absorption units: (dB/m)*kHZ 
%==================================================================
%  
%  Array properties 
%  
%==================================================================
%Read the Bellhop manual to understand the meaning of the options: 
 options.options1    = '''SVWT*'''; 
%options.options1    = '''SVWT'''; % No ati file expected  
 options.options2    = '''A*'''; 
%options.options2    = '''A'''; % No bty file expected
 options.options3    = '''R'''; %      Rays
%options.options3    = '''E'''; % EigenRays
%options.options3    = '''C'''; % Coherent TL (rewrite final block accordingly) 
 options.options4    = []; 
 options.r = R/1000; 
 options.z = zs;
 output_option = options.options3;

wbellhopenvfil('munk',case_title,source_data,surface_data,ssp_data,bottom_data,options);

disp('Calling Bellhop...')

system('bellhop.exe munk');

%=====================%
% Reading output      %
%=====================%
switch output_option 
case '''C'''
    plotshd( 'munk.shd' ), box on, hold on
    plot(rati, zati)
    plot(rbty,zbty)
    hold off
case '''E'''
    plotray( 'munk' ), box on, hold on
    plot(rati, zati)
    plot(rbty,zbty)
    hold off
 case '''R'''
    plotray( 'munk' ), box on, hold on
    plot(rati, zati)
    plot(rbty,zbty)
    hold off    
 otherwise
    disp('Unknown output option.')
end

disp('done.')
