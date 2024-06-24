function wbounceenvfil(filename,thetitle,freq,nmedia,options,waterinfo,layersinfo,clow,chigh,rmaxkm)

% Writes BOUNCE input (environmental) file. 
%
% SYNTAX: wbounceenvfil(filename,thetitle,freq,nmedia,options,waterinfo,layersinfo,clow,chigh,rmaxkm)
%

%*******************************************************************************
% Faro, Sun 23 Jun 2024 10:48:06 PM WEST 
% Written by Tordar 
%*******************************************************************************

envfil = [ filename '.env' ];

somezeros = '0 0.0 ';
fid = fopen(envfil,'w');
fprintf(fid,'%s\n',thetitle);
fprintf(fid,'%f\n',freq);
fprintf(fid,'%d\n',nmedia);
fprintf(fid,'%s\n', options);
fprintf(fid,'%f ' ,waterinfo);fprintf(fid,'\n');
for i = 1:nmedia
    fprintf(fid,'%s',somezeros);fprintf(fid,'%f\n',layersinfo(i,1));
    fprintf(fid,'%f ',waterinfo(1));
    fprintf(fid,'%f ',layersinfo(i,2:end));fprintf(fid,'\n');
    fprintf(fid,'%f ',layersinfo(i,1:2  ));fprintf(fid,'/ \n');
    fprintf(fid,'%s ','"A"');
    fprintf(fid,'%s',somezeros);fprintf(fid,'\n');
endfor
fprintf(fid,'%f ',layersinfo(nmedia+1,:));fprintf(fid,'\n');
fprintf(fid,'%f ' ,clow  );
fprintf(fid,'%f\n',chigh ); 
fprintf(fid,'%f\n',rmaxkm); 
fclose( fid );

endfunction
