function wkrakenenvfil( filename, thetitle, source_info, surface_info, scatter_info, ssp_info, bottom_info, field_info )

% Writes Kraken input (environmental) file. 
%
% SYNTAX: wkrakenenvfil( filename, title, source, surface, scatter, ssp, bottom, field )
%

%*******************************************************************************
% Faro, Sat 22 Jun 2024 06:00:07 PM WEST 
% Written by Tordar 
%*******************************************************************************

envfil = [ filename '.env' ];
brcfil = [ filename '.brc' ];
trcfil = [ filename '.trc' ];
ircfil = [ filename '.irc' ];

%*******************************************************************************
% Get source data: 

freq     = source_info.f     ;
nsources = source_info.n     ;
zs       = source_info.zs    ;

%*******************************************************************************
% Get surface data: 

top_boundary_condition = surface_info.bc        ;
top_properties         = surface_info.properties;
top_reflection_coeff   = surface_info.reflection;

%*******************************************************************************
% Get scatter data: 

bumden = scatter_info.bumden;
eta    = scatter_info.eta   ;
xi     = scatter_info.xi    ;

%*******************************************************************************
% Get sound speed data: 

ssp_data  = ssp_info.data   ;
ssp_type  = ssp_info.type   ;
citype    = ssp_info.itype  ;
nmesh     = ssp_info.nmesh  ;
csigma    = ssp_info.sigma  ;
clow      = ssp_info.clow   ;
chigh     = ssp_info.chigh  ;
zbottom   = ssp_info.zbottom;

z = ssp_data(1,:); Dmax = max( z ); nz = length( z );

%*******************************************************************************
% Get bottom data:

nlayers                   = bottom_info.n    ;
attenuation_units         = bottom_info.units;
bottom_boundary_condition = bottom_info.bc   ;
bottom_properties         = bottom_info.properties;
bsigma                    = bottom_info.sigma;
layer_properties          = bottom_info.layerp;
layer_type                = bottom_info.layert;
layer_data                = bottom_info.data;

if nlayers >= 20 
disp('Max # of layers = 20!!!!!!')
return 
end 

%*******************************************************************************
% Get field data:

thorpe      = field_info.thorpe;
finder      = field_info.finder;
rmax        = field_info.rmax  ;
nrd         = field_info.nrd   ;
nrr         = field_info.nrr   ;
rd          = field_info.rd    ;
rr          = field_info.rr    ;
nmodes      = field_info.m     ;
source_type = field_info.stype ;
nprofiles   = field_info.np    ;
rprofiles   = field_info.rp    ;
dr          = field_info.dr    ;
range_dependent_modes = field_info.rmodes;

%*******************************************************************************
% Construct the options: 

options1(1) = citype                ;
options1(2) = top_boundary_condition;
options1(3) = attenuation_units     ;
options1(4) = thorpe                ;
options1(5) = finder                ;

options2(1) = source_type          ;
options2(2) = range_dependent_modes;

%*******************************************************************************
% Write the ENVFIL: 

fid = fopen(envfil,'w');

fprintf(fid,'%s\n',thetitle);
fprintf(fid,'%f\n',freq);
fprintf(fid,'%d\n',nlayers);
fprintf(fid,'%s\n',options1);

if top_boundary_condition == 'A', 
fprintf(fid,'%f\n',top_properties);
end 

if top_boundary_condition == 'F',
nthetas    = surface_info.nthetas;
angle_data = surface_info.angle_data;  
fidtrc = fopen(trcfil,'w');
fprintf(fidtrc,'%d\n',nthetas);
fprintf(fidtrc,'%f\n',angle_data);
fclose(fidtrc);
end 

if ( top_boundary_condition == 'F' )|( top_boundary_condition == 'I' ),
fprintf(fid,'%f %f %f\n',bumden,eta,xi);
end 

fprintf(fid,'%d %f %f\n',nmesh,csigma,zbottom);

if ( citype ~= 'A' )

     if ( ssp_type == 'H' )

         fprintf(fid,'%f ',ssp_data(:,1));
         fprintf(fid,'/\n');
         fprintf(fid,'%f %f /\n',ssp_data(1:2,2:nz));

     
     else
     
         fprintf(fid,'%f %f %f %f %f %f\n',ssp_data);
     
     end

end 

for i = 1:nlayers-1 

    fprintf(fid,' %d %f %f \n',layer_properties(i,:));
    
    datai = squeeze( layer_data(i,:,:) );
    
    if ( layer_type(i,1) == 'H' )
    
        nz = length( datai(:,1) );
        
        fprintf(fid,'%f ',datai(1,:));
        fprintf(fid,'\n');
        fprintf(fid,'%f %f /\n',datai(2:nz,1:2));

     
    else
     
        fprintf(fid,'%f %f %f %f %f %f\n',datai);
     
    end

end 

fprintf(fid,'%s %f\n',bottom_boundary_condition,bsigma);
if bottom_boundary_condition == 'A'
fprintf(fid,'%f '    ,bottom_properties);
fprintf(fid,'/ \n');
end
fprintf(fid,'%f %f\n',clow,chigh);
fprintf(fid,'%f\n',rmax);
fprintf(fid,'%d\n',nsources);
if nsources == 1 
fprintf(fid,'%f\n',zs);
else 
fprintf(fid,'%f %f /\n',zs(1),zs(nsources));
end 
fprintf(fid,'%d\n',nrd);
if nrd == 1 
fprintf(fid,'%f\n',rd);
else 
fprintf(fid,'%f %f /\n',rd(1),rd(nrd));
end 

fclose( fid );

%*******************************************************************************  
% Write the FLPFIL: 

fid = fopen('field.flp','w');
fprintf(fid,'%s\n',thetitle);
fprintf(fid,'%s\n',options2);
fprintf(fid,'%d\n',nmodes);
fprintf(fid,'%d\n',nprofiles);
fprintf(fid,'%f  ',rprofiles);
fprintf(fid,'\n');
fprintf(fid,'%d\n',nrr);
if nrr == 1 
fprintf(fid,'%f /\n',rr);
else
fprintf(fid,'%f %f / \n',rr(1),rr(nrr));
end 
fprintf(fid,'%d\n',nsources);
if nsources == 1 
fprintf(fid,'%f /\n',zs);
else
fprintf(fid,'%f %f / \n',zs(1),zs(nsources));
end
fprintf(fid,'%d\n',nrd);
if nrd == 1 
fprintf(fid,'%f /\n',rd);
else
fprintf(fid,'%f %f / \n',rd(1),rd(nrd));
end
fprintf(fid,'%d\n',nrd);
if nrd == 1 
fprintf(fid,'%f /\n',dr);
else
fprintf(fid,'%f %f / \n',dr(1),dr(nrd));
end
fclose( fid );

endfunction
