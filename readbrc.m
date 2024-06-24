function [thetas,R] = readbrc( filename )

thetas = [];
R      = [];

fid     = fopen( filename, 'r' );
nthetas = fscanf( fid, '%d\n', 1 );

thetas = zeros( 1,nthetas ); 
absR   = zeros( 1,nthetas );
phaseR = zeros( 1,nthetas );

for i = 1:nthetas 
    thedata = fscanf(fid,'%f',3);
    thetas(i) = thedata(1);
      absR(i) = thedata(2);
    phaseR(i) = thedata(3);
endfor
    
fclose( fid );

R = absR.*exp( 1i*phaseR );

endfunction
