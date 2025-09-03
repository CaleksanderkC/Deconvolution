function V_noise = add_white_noise(signal, std)
%   Funkcja dodaje szum biały do zadanego sygnału
% Wejście:
%   signal  :  sygnał wejściowy
%   std     :  odchylenie standardowe rządanego szumy 0-1
% Wyjście:
%   V_noise : sygnał z szumeme białym
  V_noise = normrnd (signal, std);
end