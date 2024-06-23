%==================================================================
%  
%  KRAKEN - Flat waveguide + Gulf field
%  Faro, Sat 22 Jun 2024 07:25:04 PM WEST 
%  Written by Tordar 
%  
%==================================================================

close all, clear all 

case_title = 'Gulf field';

Rmaxkm = 125; Rmax = Rmaxkm*1000; Dmax = 5000;
 
%==================================================================
%  
%  Gulf field
%  
%==================================================================

gulf_rangeskm = [0.0 12.5 25.0 37.5 50.0 75.0 100.0 125.0];
gulf_ranges   = gulf_rangeskm*1000;

gulf_depths = [...
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

gulf_c = [...
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
 
ssp_data.r = gulf_rangeskm;
ssp_data.z = gulf_depths;
ssp_data.c = gulf_c;

nprofiles = length( gulf_rangeskm );

%==================================================================
%  
%  Source
%  
%==================================================================

freq  =  500;
  zs  = 1200;

source_data.n  =    1; % Number of sources
source_data.zs =   zs; % source depths 
source_data.f  = freq;

%==================================================================
%  
%  Surface properties
%  
%==================================================================

surface_data.bc = 'V';
surface_data.properties = []; % Not required due to vacuum over surface
surface_data.reflection = []; % Not required for this case

%==================================================================

% Scatter is not required fot this case: 
scatter_data.bumden = []; % Bump density in ridges/km 
scatter_data.eta    = []; % Principal radius 1 of bump 
scatter_data.xi     = []; % Principal radius 2 of bump 

%==================================================================
%  
%  Sound speed = gulf data
%  
%==================================================================

zi = gulf_depths';

cs   = zeros( size( zi ) );
rho  =  ones( size( zi ) );
apt = cs; ast = cs;
ssp_data.type  = 'H';
ssp_data.itype = 'N';
% Number of mesh points to use initially, should be about 10 per vertical wavelenght:
ssp_data.nmesh =  20001;
ssp_data.sigma =      0; % RMS roughness at the surface 
ssp_data.clow  =    0.0;
ssp_data.chigh = 2000.0;
ssp_data.zbottom = Dmax;

%==================================================================
%  
%  Bottom properties 
%  
%==================================================================

bottom_data.n	       = 1;
bottom_data.layerp     = [0 0 Dmax];
bottom_data.layert     = ['R'];
bottom_data.properties = [Dmax 1600 0 2.0 0 0];
bottom_data.data       = [];
bottom_data.units      = 'W';
bottom_data.bc	       = 'A';
bottom_data.sigma      = 0.0; % Interfacial roughness

%==================================================================
%  
%  Field definition
%  
%==================================================================

nra  = 201; rarray = linspace(0,Rmax,nra);
nza  = 101; zarray = linspace(0,Dmax,nza);

field_data.rmax  = Rmaxkm;
field_data.rr    = rarray/1000; field_data.nrr = nra;
field_data.rp    = gulf_rangeskm; field_data.np = nprofiles;
field_data.m     =  999;
field_data.rmodes = 'A';
field_data.stype  = 'R';
field_data.thorpe = 'T';
field_data.finder = ' ';
field_data.rd     = zarray; field_data.dr = 0*zarray;
field_data.nrd    =   nza;

%==================================================================
%  
%  Create an env file for each profile:
%  
%==================================================================

fid = fopen('gulf.env','w');
fprintf(fid,' ');
fclose( fid );

for i = 1:nprofiles

    i
    ci = gulf_c(:,i)';
    ssp_data.data = [zi;ci;cs;rho;apt;ast];

%==================================================================
%  
%  Write the file 
%  
%==================================================================

    wkrakenenvfil('eachpro',case_title,source_data,surface_data,scatter_data,ssp_data, bottom_data,field_data);
    system('cat gulf.env eachpro.env > dummy.env');
    system('mv dummy.env gulf.env');
    
end

disp('Calling KRAKEN...')

system('kraken.exe gulf');
system('cp field.flp gulf.flp');
system('field.exe gulf < gulf.flp');

[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, p ] = read_shd( 'gulf.shd' );

p = squeeze( p ); tl = -20*log10( abs( p ) );

tej = flipud( colormap(jet) ); 

figure(1)
pcolor(rarray,zarray,tl), shading interp, colormap(tej), colorbar, caxis([50 100])
view(0,-90)
xlabel('Range (m)')
ylabel('Depth (m)')
title('KRAKEN - Gulf field')

disp('done.')
