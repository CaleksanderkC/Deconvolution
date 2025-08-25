clc; clear; close all;
com.mathworks.desktop.mnemonics.MnemonicsManagers.get.disable;
addpath('Lib');

%% Parametry Systemu
% Ilośc próbek
N=10000;

% Ładunek testowy
q = 9;

%  Wspólczynnik
Cfeed = 3;

% Okres pojedynczego sygnału bezwymiarowy
tau_sh = 1;

% Okres probkowania równy okresu sygnału
T_smp = tau_sh;

% Czas trwania sygnału
t = - 3 * T_smp : T_smp : 10 * T_smp ;
t = repmat(t, N, 1);

% Początek sygnału w chwili losowej
t_0 = unifrnd(0, 1, N, 1);
t_0 = repmat(t_0, 1, length(t(1,:)));

% Napięcie maksymalne 
V_ref = 50;


%% Pojedynczy sygnał Testowy

% Parametr 
bit_res_test = 12;


V_real = filter_response(t, t_0, tau_sh, q, Cfeed);
V_real = add_white_noise(V_real, 0.1);
V_real = quantize_signal(V_real, V_ref, bit_res_test);

d = deconvolution(V_real, tau_sh, T_smp);
time=-3*T_smp:0.001:10*T_smp;
V_time=linspace(0,0,length(time));
i=time<t_0(1,1);
V_time(i)=0;
V_time(~i)=q/Cfeed*((time(~i)-t_0(1,1))/tau_sh).*exp(-(time(~i)-t_0(1,1))/tau_sh);
% V_time = add_white_noise(V_time, 0.1);

q_calc_quant = charge_output(d(:, 5:6), T_smp, tau_sh, Cfeed);
disp(mean(q_calc_quant(~isnan(q_calc_quant))) - q);

figure(1);
title('Example of asynchronous sampling with two non-zero filter output samples');
hold on
scatter(t(1,:),V_real(1,:));
plot(time, V_time)
stem([t(1,:), 0, 0], d(1,:));
legend('Samples','FE pulse','Deconvolution')
hold off


% Liczymy zależność błędu od ilości bitów przetwornika ADC
bit_res=4:16;
err=zeros(1,length(bit_res));

for i=1:length(bit_res)
    % Odpowiedź Filtru -- sygnał spróbkowany
    V_real = filter_response(t, t_0, tau_sh, q, Cfeed);

    %  Generujemy szumy
    V_real = add_white_noise(V_real, 0.4);
    V_real = quantize_signal(V_real, V_ref, bit_res(i));

    %  Dekonwolucja
    d = deconvolution(V_real, tau_sh, T_smp);

    % Dwa największe prążki
    d=d(:,5:6);

    % Obliczamy ładunek i t_0 
    q_calc_quant = charge_output(d, T_smp, tau_sh, Cfeed);
    q_calc_quant = q_calc_quant(~isnan(q_calc_quant));

    % q_calc_quant strzela do inf   trzeba poprawić funkcję

    % Na razie wstawiłem warunek który usuwa osobliwości
    q_calc_quant = q_calc_quant(abs(q_calc_quant)<V_ref);

    % Błąd względny 
    err(i)=mean(abs(q_calc_quant-q));
    disp(mean(abs(q_calc_quant-q)));
end
figure(2);
hold on
title('Zależność błędu dekonwolucji od rozdzielczości bitowej.');
semilogy(bit_res,err, "o");
xlabel('Rozdzielczość bitowa');
ylabel('Błąd');
grid on;
hold off