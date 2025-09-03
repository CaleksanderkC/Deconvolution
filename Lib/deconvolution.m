function d = deconvolution(signal, tau_sh, T_smp)
%   Funkcja zwraca dekownolucję danego sygnału
% Wejście:
%   signal    :  Sygnał wejściowy
%   tau_sh    :  Okres sygnału
%   T_smp     :  Okres próbkowania
% Wyjście:
%   d : zwraca próżki po dekonwolucji

    %  Współczynniki Filtru FIR dekonwolucji  w0, w1, w2
    filter_coeffs=[1, -2*exp(-T_smp/tau_sh), exp(-2*T_smp/tau_sh)];
    
    [x,y]= size(signal);
    
    w=zeros(x, y+2);
    
    for i = 1 : length(signal(:, 1))
        w(i, :) = conv(signal(i, :), filter_coeffs);
    end


    % d=w(:,5:6);
    d=w;
end