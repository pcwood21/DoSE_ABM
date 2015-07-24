function out=motag_GreedAsn(Client,Insider,Prox)

if Client < Prox
    out=1:Client;
    return;
end

if Prox == 1
    out=ones(1,length(Client));
    return;
end

if Insider == 0
    i=1:Client;
    i=mod(i,Prox)+1;
    out=i;
    return;
end
        
w=motag_MaxProxy(Client,0,Client-Insider,Insider);
ProxToFill=floor(Client/w);
if ProxToFill >= Prox
    ProxToFill=Prox-1;
end

RemC = Client - ProxToFill*w;
RemP = Prox - ProxToFill;
RemA = round(Insider*RemC/Client);

asn=[];
for k=0:(ProxToFill-1)
    asn(end+1:end+w)=k+1;
end

asn(end+1:Client)=motag_GreedAsn(RemC,RemA,RemP)+k+1;
out=asn;

end