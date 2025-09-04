function max_sampls = find_2_max(d, t, T_smp)
%FIND_2_MAX zwraca 2 największe przążki po dekonwolucji d1,d2
% Wejście:
%   d          :  Przążki po dekonwolucji
%   t          :  czas systemu
%   T_smp      :  Okres próbkowania
% Wyjście:
%   max_sampls : d1,d2
    max_id = find(t(1,:)==1*T_smp);
    max_sampls = d(:, max_id:max_id+1 );
end

