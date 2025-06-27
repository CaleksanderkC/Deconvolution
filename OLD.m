clc; clear; close all;
q=10;
Cfeed=3;
tau_sh=1;
T_smp=tau_sh;
t_0=0.5;
t=-3*T_smp:T_smp:10*T_smp;
alpha=q/Cfeed;
time=-3*T_smp:0.001:10*T_smp;
V=linspace(0,0,length(t));
i=t<t_0;
V(i)=0;
V(~i)=alpha*((t(~i)-t_0)./tau_sh).*exp(-(t(~i)-t_0)./tau_sh);
fillter_coeffs=[1, -2*exp(-T_smp/tau_sh), exp(-2*T_smp/tau_sh)];
figure;
w=conv(V,fillter_coeffs);
w(w<max(w)*0.01)=0;
stem(w);
grid on;

V_time=linspace(0,0,length(time));
i=time<t_0;
V_time(i)=0;
V_time(~i)=alpha*((time(~i)-t_0)/tau_sh).*exp(-(time(~i)-t_0)/tau_sh);

V_time = add_white_noise(V_time, 1);

% V_reaV_timel = quantize_signal(V_time, V_ref, bit_res(i));
figure;
plot(t,V, 'o');
hold on;
plot(time,V_time);
stem([t, 0, 0], w);

d=w(w>0);

if(isscalar(d))
    t_0_calc=0;
    A=d*tau_sh/T_smp * exp((T_smp-tau_sh)/tau_sh);
else
    t_0_calc=(d(2)/d(1)*T_smp)/(d(2)/d(1)+exp(-T_smp/tau_sh));
    A=(d(1)+d(2))*(tau_sh*exp((T_smp-t_0_calc-tau_sh)/tau_sh)/(T_smp-t_0_calc*(1-exp(-T_smp/tau_sh))));
end
q_calc=A*exp(1)*Cfeed;

q
q_calc