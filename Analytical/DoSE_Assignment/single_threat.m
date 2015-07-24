
%Sweep for client count

n_cl = 1000:1000:10000;
mpft=zeros(1,length(n_cl));
nrly=zeros(1,length(n_cl));
nft=zeros(1,length(n_cl));
eTime=zeros(1,length(n_cl));
for i=1:length(n_cl)
    tpft=0;
    tnrly=0;
    teTime=0;
    tnft=0;
    for k=1:10
        out=aSingleThreat(n_cl(i),1,2);
        tpft=tpft+out.avgPft;
        tnrly=tnrly+out.nRelays;
        teTime=teTime+out.eTime;
        tnft=tnft+out.nft;
    end
	mpft(i)=tpft/k;
    nrly(i)=tnrly/k;
    eTime(i)=teTime/k;
    nft(i)=tnft/k;
end


