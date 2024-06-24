%==================================================================
%  
%  BOUNCE: COA figure 1_26
%  Faro, Sun 23 Jun 2024 10:41:22 PM WEST 
%  Written by Tordar
%  
%==================================================================

% Reflection loss at layered fluid bottom with the parameters given in Table 1.5.
% (a) Loss vs. grazing angle.
% (b) Contoured loss vs. frequency and grazing angle. 
clear all, close all 

case_title = "Layered fluid bottom";
freq = 25.0;
rmaxkm = 10.0;
clow  = 1500.0;
chigh = 1.00e6;
nmedia  = 1;
options = "CAW";
parw = [0.0, 1500.0, 0.0, 1.0, 0.0, 0.0];
parl = [2.0, 1550.0, 0.0, 1.5, 0.2, 0.0;2.0, 1800.0, 0.0, 2.0, 0.5, 0.0];

disp( 'Case (a)...' )

wbounceenvfil("fluidb",case_title,freq,nmedia,options,parw,parl,clow,chigh,rmaxkm)

system("bounce.exe fluidb");

[thetas1,R] = readbrc("fluidb.brc");

B1 = -10*log10( abs(R).*abs(R) );

freq = 2000.0;

wbounceenvfil("fluidb",case_title,freq,nmedia,options,parw,parl,clow,chigh,rmaxkm)

system("bounce.exe fluidb");

[thetas2,R] = readbrc("fluidb.brc");

B2 = -10*log10( abs(R).*abs(R) );

disp( 'Case (b)...' )

nfreqs = 101;
freqs = linspace(0,2000,nfreqs);
freqs(1) = 2.0;
thetamin =  5.0;
thetamax = 85.0;
nthetas = 101;
thetas = linspace(thetamin,thetamax,nthetas);
B = zeros(nfreqs,nthetas);

for i = 1:nfreqs
    freqi = freqs(i);
    wbounceenvfil("fluidb",case_title,freqi,nmedia,options,parw,parl,clow,chigh,rmaxkm)
    system("bounce.exe fluidb");   
    [thetasi,Ri] = readbrc("fluidb.brc");
    Bi = -10*log10( abs(Ri).*abs(Ri) );
    B(i,:) = interp1(thetasi, Bi, thetas );
endfor 
    
figure(1)
plot(thetas1,B1,thetas2,B2,'--')
xlabel('Grazing angle (deg)')
ylabel('Loss (dB)')
title('(a)')
ylim([0,25])
box on, grid on

figure(2)
pcolor(thetas,freqs,B), shading('interp')
colorbar
xlabel('Grazing angle (deg)')
ylabel('Frequency (Hz)')
title('(b)')
xlim([thetamin,thetamax])
ylim([0,2000])

disp("done")
