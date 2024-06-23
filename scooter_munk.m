%==================================================================
%  
%  SCOOTER - Flat waveguide + Munk sound speed profile
%  Faro, Sat 22 Jun 2024 07:58:16 PM WEST 
%  Written by Tordar 
%  
%==================================================================

clear all, close all 

disp('SCOOTER, Munk profile calculations...')

case_title = 'Munk profile';

freq =   50;
zs   = 1000;

Dmax   = 5000;
Rmaxkm =  100;
Rmax   = Rmaxkm*1000;

%==================================================================
%  
%  Source properties
%  
%==================================================================

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
%  Sound speed profile properties
%  
%==================================================================

load munk.ssp 

zi = munk(:,1)';
ci = munk(:,2)';

cs   = zeros( size( zi ) );
rho  =  ones( size( zi ) );
apt = cs; ast = cs;
ssp_data.type  = 'H';
ssp_data.itype = 'N';
% Number of mesh points to use initially, should be about 10 per vertical wavelenght:
ssp_data.nmesh =   5001;
ssp_data.sigma =      0; % RMS roughness at the surface 
ssp_data.clow  = 1000.0;
ssp_data.chigh = 2000.0;
ssp_data.data  = [zi;ci;cs;rho;apt;ast];
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

nra  = 501; rarray = linspace(0,Rmax,nra);
nza  = 101; zarray = linspace(0,Dmax,nza);

field_data.rmax  = Rmaxkm;
field_data.rr    = rarray/1000; field_data.nrr = nra;
field_data.rp    =    0; field_data.np = 1;
field_data.m     =  999;
field_data.rmodes = 'A';
field_data.stype  = 'R';
field_data.thorpe = 'T';
field_data.finder = ' ';
field_data.rd     = zarray; field_data.dr = 0*zarray;
field_data.nrd    =   nza;

%==================================================================
%  
%  Write the file 
%  
%==================================================================

wkrakenenvfil('munk',case_title,source_data,surface_data,scatter_data,ssp_data, bottom_data,field_data);

flpoptions = '''RP''';
rminkm =  0.0; 
rmaxkm = 10.0;
nr     = nra;
fid = fopen('munk.flp','w');
fprintf(fid,'%s\n',flpoptions); % 'R/X (coord), Pos/Neg/Both' 
fprintf(fid,'%d\n',nr); % NR
fprintf(fid,'%f %f /\n',rminkm,rmaxkm); % RMIN, RMAX
fclose( fid );

%==================================================================
%  
%  Run the model 
%  
%==================================================================

disp('Calling SCOOTER...')

system('scooter.exe munk');

fieldsco('munk.grn');

load("munk.shd.mat")

p = squeeze( pressure );

tl = -20*log10( abs( p ) );

tej = flipud( colormap(jet) ); 

figure(1)
pcolor(rarray,zarray,tl), shading interp, colormap(tej), colorbar, caxis([50 100])
view(0,-90)
xlabel('Range (m)')
ylabel('Depth (m)')
title('SCOOTER - Munk waveguide')

disp('done.')
