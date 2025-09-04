clc; clear; close all;
com.mathworks.desktop.mnemonics.MnemonicsManagers.get.disable;
addpath('Lib');

%% Parametry Systemu

N=10000;                 % Ilośc próbek
q = 20;                  % Ładunek testowy
Cfeed = 3;               % Wspólczynnik amplitudowy
V_ref = 50;              % Napięcie maksymalne 

tau_sh = 1;              % Okres sygnału bezwymiarowy
smp_sh_ratio = 1;        % Stosunek okresu sygnału do okresu próbkowania (T_smp/ tau_sh)

 % Okres probkowania
T_smp = smp_sh_ratio*tau_sh; 

% Czas trwania sygnału
t = -3 * tau_sh : T_smp : 10*tau_sh ;
t = repmat(t, N, 1);

% Początek sygnału w chwili losowej
t_0 = unifrnd(0, T_smp, N, 1);
t_0 = repmat(t_0, 1, length(t(1,:)));


%% Pojedynczy sygnał Testowy
%Dla rozdielczości
bit_res_test = 12;
White_noise_resio = 0.1;

V_real = filter_response(t, t_0, tau_sh, q/Cfeed);
V_real = add_white_noise(V_real, White_noise_resio);
V_real = quantize_signal(V_real, V_ref, bit_res_test);

d = deconvolution(V_real, tau_sh, T_smp);
time=(-3/smp_sh_ratio)*T_smp:0.001:(10/smp_sh_ratio)*T_smp;
V_time=linspace(0,0,length(time));
i=time<t_0(1,1);
V_time(i)=0;
V_time(~i)=q/Cfeed*((time(~i)-t_0(1,1))/tau_sh).*exp(-(time(~i)-t_0(1,1))/tau_sh);
% V_time = add_white_noise(V_time, 0.1);


max_sampls = find_2_max(d, t, T_smp);

[q_calc_quant, t_calc] = charge_output(max_sampls, T_smp, tau_sh, Cfeed);
disp(q_calc_quant)


figure;
hold on;
scatter(t(1,:),V_real(1,:));
plot(time, V_time);
stem(t(1,:), d(1,  1:end-2 ) );
xlabel('Time [au]');
ylabel('Amplituda [au]');
legend('Samples', 'FE pulse', 'Deconvolution');
grid on;
hold off;


%% Zależność błędu obliczenia ładunku Q i startu sygnału t_0 od ilości bitów przetwornika ADC
bit_res=4:16;
q_err=zeros(1,length(bit_res));
t_err=zeros(1,length(bit_res));

for i=1:length(bit_res)
    % Odpowiedź Filtru -- sygnał spróbkowany
    V_real = filter_response(t, t_0, tau_sh, q/Cfeed);

    %  Generujemy szumy
    V_real = add_white_noise(V_real, White_noise_resio);
    V_real = quantize_signal(V_real, V_ref, bit_res(i));

    %  Dekonwolucja
    d = deconvolution(V_real, tau_sh, T_smp);

    % Dwa największe prążki
    max_sampls = find_2_max(d, t, T_smp);

    % Obliczamy ładunek i t_0 
    [q_calc_quant, t_0_calc_quant] = charge_output(max_sampls, T_smp, tau_sh, Cfeed);

    % q_calc_quant dąży do inf  trzeba poprawić funkcję
    % Na razie wstawiłem warunek który usuwa osobliwości
    quant_index = ~isnan(q_calc_quant) & abs(q_calc_quant) <= V_ref & ~isnan(t_0_calc_quant) & abs(t_0_calc_quant) <= 1;

    q_calc_quant = q_calc_quant(quant_index);
    t_0_calc_quant = t_0_calc_quant(quant_index);

    % Błąd względny 
    q_err(i)=mean( abs(q_calc_quant-q)/q );
    t_err(i)=mean( abs(t_0_calc_quant-t_0(quant_index,1))./t_0(quant_index,1) );
end


figure;
semilogy(bit_res,q_err, "o");
xlabel('Rozdzielczość bitowa przetwornika ADC');
ylabel('Q error [%]');
grid on;

figure;
semilogy(bit_res,t_err, "o");
xlabel('Rozdzielczość bitowa przetwornika ADC');
ylabel('t error [%]');
grid on;



%% Zależność błędu obliczenia ładunku Q i startu sygnału t_0 od szumu białego
White_noise_resio_=0.0:0.1:0.6;

q_err_noise=zeros(1,length(White_noise_resio_));
t_err_noise=zeros(1,length(White_noise_resio_));

for i = 1:length(White_noise_resio_)

    V_real = filter_response(t, t_0, tau_sh, q/Cfeed);
    V_real = add_white_noise(V_real, White_noise_resio_(i));
    V_real = quantize_signal(V_real, V_ref, 12);

    d = deconvolution(V_real, tau_sh, T_smp);

    max_sampls = find_2_max(d, t, T_smp);

    [q_calc_quant, t_0_calc_quant] = charge_output(d, T_smp, tau_sh, Cfeed);
    quant_index = ~isnan(q_calc_quant) & abs(q_calc_quant) <= V_ref & ~isnan(t_0_calc_quant) & abs(t_0_calc_quant) <= 1;

    q_calc_quant = q_calc_quant(quant_index);
    t_0_calc_quant = t_0_calc_quant(quant_index);

    % Błąd względny 
    q_err_noise(i)=mean( abs(q_calc_quant-q)/q );
    t_err_noise(i)=mean( abs(t_0_calc_quant-t_0(quant_index,1))./t_0(quant_index,1) );
end

figure;
semilogy(White_noise_resio_,q_err_noise, "o");
xlabel('Intensywność szumu białego 𝞂');
ylabel('Q error [%]');
grid on;

figure;
semilogy(White_noise_resio_,t_err_noise, "o");
xlabel('Intensywność szumu białego 𝞂');
ylabel('t error [%]');
grid on;




%% Zależność błędu obliczenia ładunku Q i startu sygnału t_0 od stosunku okresu probkowania do okresu sygnału


smp_sh_ratio_samples= 0.25:0.25:2;
q_err_noise=zeros(1,length(smp_sh_ratio_samples));
t_err_noise=zeros(1,length(smp_sh_ratio_samples));

for i = 1:length(smp_sh_ratio_samples)

    T_smp = smp_sh_ratio_samples(i)*tau_sh; 

    % Czas trwania sygnału
    t = -3 * tau_sh : T_smp : 10*tau_sh ;
    t = repmat(t, N, 1);
    
    % Początek sygnału w chwili losowej
    t_0 = unifrnd(0, T_smp, N, 1);
    t_0 = repmat(t_0, 1, length(t(1,:)));

    V_real = filter_response(t, t_0, tau_sh, q/Cfeed);
    V_real = add_white_noise(V_real, 0.1);
    V_real = quantize_signal(V_real, V_ref, 12);

    d = deconvolution(V_real, tau_sh, T_smp);

    max_sampls = find_2_max(d, t, T_smp);

    [q_calc_quant, t_0_calc_quant] = charge_output(d, T_smp, tau_sh, Cfeed);
    quant_index = ~isnan(q_calc_quant) & abs(q_calc_quant) <= V_ref & ~isnan(t_0_calc_quant) & abs(t_0_calc_quant) <= 1;

    q_calc_quant = q_calc_quant(quant_index);
    t_0_calc_quant = t_0_calc_quant(quant_index);

    % Błąd względny 
    q_err_noise(i)=mean( abs(q_calc_quant-q)/q );
    t_err_noise(i)=mean( abs(t_0_calc_quant-t_0(quant_index,1))./t_0(quant_index,1) );
end

figure;
semilogy(smp_sh_ratio_samples,q_err_noise, "o");
xlabel('Stosunek okresu sygnału do okresu próbkowania');
ylabel('Q error [%]');
grid on;

figure;
semilogy(smp_sh_ratio_samples,t_err_noise, "o");
xlabel('Stosunek okresu sygnału do okresu próbkowania');
ylabel('t error [%]');
grid on;