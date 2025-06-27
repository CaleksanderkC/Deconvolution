function V = filter_response(t, t_0, tau, q, Cfeed)
    alpha = q / Cfeed;

    V = zeros(size(t));

    i = t < t_0;

    V(i)=0;
    
    V(~i)=alpha*((t(~i)-t_0(~i))./tau).*exp(-(t(~i)-t_0(~i))./tau);
end