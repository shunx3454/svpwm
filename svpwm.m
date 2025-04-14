% 仿真时间
% Freq: pwm频率
% Udc: 母线电压
% U_alpha: alpha轴电压, 只会在PWM周期开始时采样
% U_beta: beta轴电压, 只会在PWM周期开始时采样
% Q: 6路pwm开关输出 [Q1 /Q1 Q2 /Q2 Q3 /Q3]
% D: ABC相上桥臂PWM占空比
function [Q, D] = svpwm(t, Freq, Udc, U_alpha, U_beta)
persistent svpwmSectorTab;
persistent pwmCompareTab;
persistent pwmPeriod;
persistent ABC;
persistent T12;
persistent Tabc;
persistent CompareABCIndex;
persistent LastUpdateTime;

if isempty(pwmCompareTab)
	pwmCompareTab = [1 2 3;2 1 3;3 1 2;3 2 1;2 3 1;1 3 2]';
end
if isempty(svpwmSectorTab)
	svpwmSectorTab = [2 6 1 4 3 5];
end
if isempty(pwmPeriod)
	pwmPeriod = 1/Freq;
end
if isempty(Tabc)
	Tabc = [0 0 0]';
end
if isempty(T12)
	T12 = [0 0]';
end
if isempty(ABC)
	ABC = [0 0 0]';
end
if isempty(CompareABCIndex)
	CompareABCIndex = pwmCompareTab(:, svpwmSectorTab(1,1));
end
if isempty(LastUpdateTime)
	LastUpdateTime =  -pwmPeriod;
end

% 每个PWM周期才计算一次
% 并更新LastUpdateTime
if (t - LastUpdateTime) >= pwmPeriod
	LastUpdateTime = t;
	% 计算A，B，C
	ABC = [0 1; sqrt(3)/2 -1/2; -sqrt(3)/2 -1/2] * [U_alpha, U_beta]';
	XYZ = zeros(3,1);
	for i = 1:3
		if ABC(i,1) > 0
			XYZ(i,1) = 1;
		else
			XYZ(i, 1) = 0;
		end
	end
	N = 4 * XYZ(3,1) + 2 * XYZ(2,1) + XYZ(1,1);
	if N == 0
		N = 1;
	end

	% 更新 T12
	switch svpwmSectorTab(N)
		case 1
			T12 = 2*pwmPeriod/sqrt(3) / Udc * [ABC(2) ABC(1)]';
		case 2
			T12 = 2*pwmPeriod/sqrt(3) / Udc * [-ABC(2) -ABC(3)]';
		case 3
			T12 = 2*pwmPeriod/sqrt(3) / Udc * [ABC(1) ABC(3)]';
		case 4
			T12 = 2*pwmPeriod/sqrt(3) / Udc * [-ABC(1) -ABC(2)]';
		case 5
			T12 = 2*pwmPeriod/sqrt(3) / Udc * [ABC(3) ABC(2)]';
		case 6
			T12 = 2*pwmPeriod/sqrt(3) / Udc * [-ABC(3) -ABC(1)]';
	end
	if sum(T12) > pwmPeriod
		T12 = pwmPeriod * T12 / sum(T12);
	end
	%更新Tabc
	Tabc = [-1/4 -1/4;1/4 -1/4; 1/4 1/4] * T12 + [pwmPeriod/4 pwmPeriod/4 pwmPeriod/4]';
	% 更新 CompareABCIndex
	CompareABCIndex = pwmCompareTab(:, svpwmSectorTab(N));
end

Q = zeros(6,1);
D = Tabc(CompareABCIndex(:, 1), 1);

for i = 1:3
	if (t - LastUpdateTime) > D(i,1) && (t - LastUpdateTime) <= (pwmPeriod - D(i,1))
		Q((i-1)*2+1,1) = 1;
		Q((i-1)*2+2,1) = 0;
	else
		Q((i-1)*2+1,1) = 0;
		Q((i-1)*2+2,1) = 1;
	end
end