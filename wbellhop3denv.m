function wbellhop3denv( filename, thetitle, source_info, surface_info, ssp_info, bathymetry_info, options )

% Writes Bellhop3D input (environmental) file. 
%
% SYNTAX: wbellhop3denv( filename, title, source, surface, ssp, bottom, options )
%

%*******************************************************************************
% Faro, Sat 22 Jun 2024 05:58:53 PM WEST 
% Written by Tordar 
%*******************************************************************************

envfil = [ filename '.env' ];
atifil = [ filename '.ati' ]; 
btyfil = [ filename '.bty' ];
sspfil = [ filename '.ssp' ];

%*******************************************************************************
% Get source data: 

box      = source_info.box;
nx       = source_info.nx;
ny       = source_info.ny;
nz       = source_info.nz;
xs       = source_info.xs;
ys       = source_info.ys;
zs       = source_info.zs;
freq     = source_info.f;
thetas   = source_info.thetas;
phi      = source_info.phi;
bearings = source_info.bearings;
beamp    = source_info.p;
beamc    = source_info.comp;

nphi      = length( phi      );
nbearings = length( bearings ); 

%*******************************************************************************
% Get surface data: 

sitype = surface_info.itype;
  xati = surface_info.x    ; 
  if isempty( xati ) ~= 1 
  nati = length( xati(1,:) );
  else
  nati = 0; 
  end 
  pati = surface_info.p    ;
  
%*******************************************************************************
% Get sound speed data: 

c   = ssp_info.c  ;
z   = ssp_info.z  ; Dmax = max( z );
r   = ssp_info.r  ; nr = length(r);

%*******************************************************************************
% Get bathymetry data:

bitype = bathymetry_info.itype ;
aunits = bathymetry_info.aunits;
  nxbty= bathymetry_info.nx    ;
  nybty= bathymetry_info.ny    ;
  xbty = bathymetry_info.x     ;
  ybty = bathymetry_info.y     ;
  zbty = bathymetry_info.z     ;
  pbty = bathymetry_info.p     ;

%*******************************************************************************  
% Get options: 
  options1  = options.options1   ; options1(4) = aunits(2);
  options2  = options.options2   ;
  options3  = options.options3   ;
  options4  = options.options4   ;
  nrd       = options.nrd        ;
  nr        = options.nr         ;
  rd        = options.rd         ;
  r         = options.r          ;

%*******************************************************************************  
% Write the ENVFIL: 
 
fid = fopen(envfil,'w');
fprintf(fid,'%s\n',thetitle);
fprintf(fid,'%f\n',freq);
fprintf(fid,'1 \n');
fprintf(fid,'%s\n', options1);

option1 = options1(2);

switch option1
       case 'Q' 
          [nz nr] = size( c );
          c1 = c(:,1);
          fidssp = fopen(sspfil,'w');
          fprintf(fidssp,'%d\n',nr);
          fprintf(fidssp,'%f ',r);
	  fprintf(fidssp,'\n'   );
	  for ii = 1:nz 
          fprintf(fidssp,'%f ',c(ii,:)); 
          fprintf(fidssp,'\n'   );
	  end
	  fclose(fidssp);
       otherwise
          c1 = c;
end

option2 = options1(3); 

switch option2
       case 'A'   
          fprintf(fid,'%f ',pati);  
          fprintf(fid,' / \n');
end

if numel( options1 ) > 5 
option5 = options1(6);
else
option5 = ' ';
end

switch option5
       case '*'   
          fidati = fopen(atifil,'w');
          fprintf(fidati,'%s\n',sitype);
          fprintf(fidati,'%d\n',nati);
          fprintf(fidati,'%f %f\n',xati);
          fclose(fidati);  
end

fprintf(fid,'51  0.0 ' ); 
fprintf(fid,'%f\n',Dmax );
zc = [z(:)';c1(:)']; 
fprintf(fid,'%f %f / \n' ,zc);

fprintf(fid,'%s', options2);
fprintf(fid,' 0.0\n' );

option1 = options2(2);

switch option1
      case 'A'
          fprintf(fid,'%f ',Dmax);
          fprintf(fid,'%f ',pbty);  
          fprintf(fid,'/ \n');
end 

option2 = options2(3);

switch option2
       case '*'   
          fidbty = fopen(btyfil,'w');
          fprintf(fidbty,'%s\n',bitype);
          fprintf(fidbty,'%d\n',nxbty);
          fprintf(fidbty,'%f %f\n',xbty);
          fprintf(fidbty,'%d\n',nybty);
          fprintf(fidbty,'%f %f\n',ybty);
	  for ii = 1:nybty
 	  fprintf(fidbty,'%f ',zbty(ii,:)); fprintf(fidbty,'\n');
          end	  
          fclose(fidbty);
end

fprintf(fid,'%d\n',nx);
fprintf(fid,'%f ' ,xs); fprintf(fid,'/\n');
fprintf(fid,'%d\n',ny);
fprintf(fid,'%f ' ,ys); fprintf(fid,'/\n');
fprintf(fid,'%d\n',nz);
fprintf(fid,'%f ' ,zs); fprintf(fid,'/\n');
fprintf(fid,'%d\n',nrd);
fprintf(fid,'%f ' ,rd ); fprintf(fid,'/\n');
fprintf(fid,'%d\n',nr );
fprintf(fid,'%f ' ,r  ); fprintf(fid,'/\n');
fprintf(fid,'%d\n',bearings(1));
if nbearings == 2
fprintf(fid,'%f ' ,bearings(2)); fprintf(fid,'/\n');
else
fprintf(fid,'%f ' ,bearings(2:3)); fprintf(fid,'/\n');
end
fprintf(fid,'%s\n', options3);
fprintf(fid,'%d ' ,thetas(1:2)); fprintf(fid,'\n');
fprintf(fid,'%f ' ,thetas(3:4)); fprintf(fid,'/\n');
if nphi > 3 
fprintf(fid,'%d ' ,phi(   1:2)); fprintf(fid,'\n');
fprintf(fid,'%f ' ,phi(   3:4)); fprintf(fid,'/\n');
else
fprintf(fid,'%d ' ,phi(1)); fprintf(fid,'\n');
fprintf(fid,'%f ' ,phi(2)); fprintf(fid,'/\n');
end
fprintf(fid,'%f ',box);
fprintf(fid,'\n');

fprintf(fid,'\n');

fclose( fid );

endfunction
