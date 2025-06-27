%  Funkcja dodaje szum biały do zadanego sygnału

function V_noise = add_white_noise(signal, std)
    V_noise = normrnd (signal, std);
end