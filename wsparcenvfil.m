function wsparcenvfil( filename, thetitle, tx_info, top_info, ssp_info, bottom_info, layer_info, rx_info, pulse_info )

% Writes SPARC input (environmental) file. 
%
% SYNTAX: wkrakenenvfil( filename, title, tx, top, ssp, bottom, rx, pulse )
%

%*******************************************************************************
% Faro, Sat 22 Jun 2024 06:00:45 PM WEST 
% Written by Tordar 
%*******************************************************************************

envfil = [ filename '.env' ];

%*******************************************************************************
% Write the ENVFIL: 

nlayers = bottom_info.nlayers;

fid = fopen(envfil,'w');

fprintf(fid,'%s\n',thetitle);
fprintf(fid,'%f\n',tx_info.freq);
fprintf(fid,'%d\n',nlayers);
fprintf(fid,'%s \n',top_info.options);
fprintf(fid,'%d '  ,top_info.nmesh  );
fprintf(fid,'%f '  ,top_info.csigma );
fprintf(fid,'%f \n',top_info.zbottom);
fprintf(fid,'%f %f %f %f %f %f\n',ssp_info.data);
if nlayers > 1 
   for i = 1:nlayers-1
       fprintf(fid,'%d ' ,top_info.nmesh  );
       fprintf(fid,'%f ' ,top_info.csigma );
       fprintf(fid,'%f\n',layer_info(i,2,1));             
       fprintf(fid,'%f %f %f %f %f %f\n',layer_info(i,1,:));
       fprintf(fid,'%f %f %f %f %f %f\n',layer_info(i,2,:));
   endfor
endif 
fprintf(fid,'%s %f\n','''R''',0);
fprintf(fid,'%f %f\n',rx_info.clow,rx_info.chigh);
fprintf(fid,'%f\n',rx_info.rmaxkm);
fprintf(fid,'%d\n',tx_info.n);
if tx_info.n == 1 
fprintf(fid,'%f / \n',tx_info.zs);
else 
fprintf(fid,'%f %f /\n',tx_info.zs(1),tx_info.zs(end));
endif
fprintf(fid,'%d\n',rx_info.nrd);
if rx_info.nrd == 1 
fprintf(fid,'%f /\n',rx_info.rd);
else 
fprintf(fid,'%f %f /\n',rx_info.rd(1),rx_info.rd(end));
endif 
fprintf(fid,'%s\n',pulse_info.options  ); % PULSE
fprintf(fid,'%f %f\n',pulse_info.freqs ); % FMIN, FMAX (Hz)
fprintf(fid,'%d\n',pulse_info.nrr      ); % NRR
fprintf(fid,'%f /\n',pulse_info.rrkm   ); % RR(1:NRR) (km)
fprintf(fid,'%d\n',pulse_info.ntout    ); % NTout
fprintf(fid,'%f %f /\n',pulse_info.tout(1),pulse_info.tout(end)); % TOUT(1:NTOUT)
fprintf(fid,'%f %f %f % f %f\n',pulse_info.pars); %-TSTART (s), TMULT, ALPHA, BETA, V (m/s)

fclose( fid );

endfunction
