function MaxAssign=motag_MaxProxy(Client,Lbnd,Ubnd,Insider)

Max=0;
MaxAssign=0;
for i=Lbnd:1:Ubnd
    Save = nchoosek(Client-i,Insider)*i/nchoosek(Client,Insider);
    if Save > Max
        Max=Save;
        MaxAssign=i;
    end
end

end