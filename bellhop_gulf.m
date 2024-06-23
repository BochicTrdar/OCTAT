%%=====================================================================
%% 
%% Bellhop: Gulf field ray tracing test
%% Faro, Sat 22 Jun 2024 06:15:55 PM WEST 
%% Written by Tordar 
%% 
%%=====================================================================

close all, clear all

case_title = 'Gulf field'; 

freq  = 500;

Rkm = 125; R = Rkm*1000; rmax = R;

dz = 50; D = 5000; zs = 1200;
 
%===================%
% Gulf field:       %
%===================%

ssp_data.r   = [0.0     12.5    25.0    37.5    50.0    75.0    100.0   125.0];
ssp_data.z   = [...
    0.0  
  200.0  
  700.0  
  800.0  
 1200.0  
 1500.0  
 2000.0  
 3000.0  
 4000.0  
 5000.0];

ssp_data.c   = [...
1536	1536	1536	1536	1536	1536	1536	1536;
1506	1508.75	1511.5	1514.25	1517	1520	1524	1528;
1503	1503	1503	1502.75	1502.5	1502	1502	1502;
1508	1507	1506	1505	1504	1503	1501.5	1500;
1508	1506.6	1505	1503.75	1502.5	1500.5	1499	1497;
1497	1497	1497	1497	1497	1497	1497	1497;
1500	1500	1500	1500	1500	1500	1500	1500;
1512	1512	1512	1512	1512	1512	1512	1512;
1528	1528	1528	1528	1528	1528	1528	1528;
1545	1545	1545	1545	1545	1545	1545	1545];

%===================
% Bottom info
%===================

bottom_properties  = [1600 2.0 0];

%===================
% Source info
%=================== 

%cs = interp1(ssp_data.z,ssp_data.c(:,1),zs); 
source_nrays =    30;    % number of propagation rays considered %
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

zbox = D+1000;
rbox = Rkm-5;
source_data.box      = [100 zbox rbox];
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
 zati = zati0*sin( k*rati );
 zati = zati - min( zati );
 surface_data.itype = '''L''';          % Sea surface interpolation type
 surface_data.x     = [rati/1000;zati]; % Surface coordinates 
%surface_data.x     = [];               % The *.ati file won't be written  
 surface_data.p     = [];               % Surface properties 

%==================================================================
%  
%  Sound speed profile properties = gulf data
%  
%==================================================================

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

%Read Bellhop's' manual to understand the meaning of the options: 
%options.options1    = '''QVWT'''; 
 options.options1    = '''QVWT*'''; 
%options.options1    = '''SVWT'''; % No ati file expected  
 options.options2    = '''A*'''; 
%options.options2    = '''A'''; % No bty file expected
 options.options3    = '''R'''; %      Rays
%options.options3    = '''E'''; % EigenRays
%options.options3    = '''C'''; % Coherent Transmission Loss
 options.options4    = []; 
 options.r = R/1000; 
 options.z = zs;
 output_option = options.options3;

wbellhopenvfil('gulf',case_title,source_data,surface_data,ssp_data,bottom_data,options);

disp('Calling Bellhop...')

system('bellhop.exe gulf');

disp('Plotting...')

switch output_option 
case '''C'''
    plotshd( 'gulf.shd' ), box on, hold on
    plot(rati, zati)
    plot(rbty,zbty)
    hold off
case '''E'''
    plotray( 'gulf' ), box on, hold on
    plot(rati, zati)
    plot(rbty,zbty)
    hold off
 case '''R'''
    plotray( 'gulf' ), box on, hold on
    plot(rati, zati)
    plot(rbty,zbty)
    xlim([0,rmax])
    hold off    
 otherwise
    disp('Unknown output option.')
end

disp('done.')
