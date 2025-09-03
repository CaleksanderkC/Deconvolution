function [q, t_0] = charge_output(d, T_smp, tau, Cfeed)
%   Funkcja zwraca odtworzony ładunek oraz chwilę detekcji sygnału
% Wejście:
%   d         :  Czas systemu (określa indexowanie tablicy wyjściowej)
%   T_smp     :  okres próbkowania
%   tau       :  Okres sygnału
%   Cfeed     :  Współczynnik amplitudowy
% Wyjście:
%   q         : zrekonstruowany ładunek sygnału
%   t_0       : zrekonstruowany chwila startu sygnału

    % t_0 przewidywane z obliczeń     
    t_0=(d(:,2)./d(:,1)*T_smp)./(d(:,2)./d(:,1)+exp(-T_smp/tau));
    A=(d(:,1)+d(:,2)).*(tau*exp((T_smp-t_0-tau)/tau)./(T_smp-t_0*(1-exp(-T_smp/tau))));
    q=abs(A*exp(1)*Cfeed);
end