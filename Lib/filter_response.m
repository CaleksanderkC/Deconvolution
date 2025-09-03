function V = filter_response(t, t_0, tau, amp)
%   Funkcja  symyluję odpowiedź filtru na skok jednostkowy
% Wejście:
%   t       :  Czas systemu (określa indexowanie tablicy wyjściowej)
%   t_0     :  Początek sygnału
%   tau     :  Okres pojedynczego sygnału
%   amp     :  Amplituda skoku jednostkowego
% Wyjście:
%   V : odpowiedź filtru fir na skok jednostkowy

    V = zeros(size(t));
    i = t < t_0;
    V(i)=0;
    V(~i)=amp*((t(~i)-t_0(~i))./tau).*exp(-(t(~i)-t_0(~i))./tau);
end