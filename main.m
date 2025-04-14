clear;
clc;
close all;

pwmPeriod = 1000;
quantityOfPWM = 360;
q1_6 = zeros(6, pwmPeriod * quantityOfPWM);
TabcCmp = zeros(3, pwmPeriod * quantityOfPWM);

U_dc = 100;
Uref = U_dc * 0.6;

for i = 1:1:pwmPeriod*quantityOfPWM
	U_alpha = Uref * cosd(360*i/pwmPeriod);
	U_beta  = Uref * sind(360*i/pwmPeriod);
	[q1_6(:,i), TabcCmp(:,i)] = svpwm(i, 1/pwmPeriod, U_dc, U_alpha, U_beta);
end

figure;
subplot(3,1,1);
plot(q1_6(1,:));
ylim([-0.5 1.5]);
title('PWMA')

subplot(3,1,2);
plot(q1_6(3,:));
ylim([-0.5 1.5]);
title('PWMB')

subplot(3,1,3);
plot(q1_6(5,:));
ylim([-0.5 1.5]);
title('PWMC')

figure;
subplot(2,1,1);
plot(...
	1:pwmPeriod * quantityOfPWM, TabcCmp(1,:),...
	1:pwmPeriod * quantityOfPWM, TabcCmp(2,:),...
	1:pwmPeriod * quantityOfPWM, TabcCmp(3,:));
title('Single Phase Duty');

subplot(2,1,2);
plot(...
	1:pwmPeriod * quantityOfPWM, TabcCmp(1,:)- TabcCmp(2,:),...
	1:pwmPeriod * quantityOfPWM, TabcCmp(2,:) - TabcCmp(3,:),...
	1:pwmPeriod * quantityOfPWM, TabcCmp(3,:) - TabcCmp(1,:));
title('Phase-Phase Duty');
