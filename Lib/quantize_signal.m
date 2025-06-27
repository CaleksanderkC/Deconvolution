function V_quant = quantize_signal(signal, V_ref, bit_res)
    V_lsb = V_ref/(2^bit_res-1);
    V_levels=0:V_lsb:(2^bit_res-1)*V_lsb;
    V_quant=zeros(size(signal));
    
    for k=1:length(signal(:,1))
        for i = 1:length(signal(1,:))
            [~, j] = min(abs(V_levels-signal(k,i)));
            V_quant(k,i)=V_levels(j);
        end
    end
end 