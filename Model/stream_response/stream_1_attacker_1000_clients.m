clear all

numClients=200;

DSim=dsim.DSim.getInstance();

server=dsim.Server();
DSim.addAgent(server);

mgmtServer=dsim.MgmtServer(numClients,1);
mgmtServer.targetServer=server.id;
DSim.addAgent(mgmtServer);

for i=1:numClients
client=dsim.Client();
client.managementServer=mgmtServer.id;
client.nextSendTime=i*2;
client.endTime=i*2+50;
DSim.addAgent(client);
end

server.responseFrequency=2000;

for i=1:10
    attacker=dsim.Attacker();
    attacker.managementServer=mgmtServer.id;
    attacker.nextSendTime=10*i+10;
    attacker.attackStartTime=10*i+10;
    DSim.addAgent(attacker);
end

logger=dsim.Logger();
DSim.addAgent(logger);


%Some tuning parameters
mgmtServer.targetRiskPerRelay=4;
mgmtServer.CRPA=3;


DSim.run(140);

tempRelay=dsim.RelayNode();

EC2_Scale_Factor=40/tempRelay.startupDelay;
EC2_Relay_Rate=0.02; %Hourly Rate in Dollars

time=logger.time*EC2_Scale_Factor;
pft=logger.pft;
pft(isnan(pft))=1;
pft(logger.time<20)=0;

hold all;
figure;
plot(time,pft);
xlabel('Time (s)');
ylabel('Pct. of Failed Transactions (pft)');
ylim([0 1]);
hold off;


attackDurSec=120;
fprintf('Attack Mitigated After: %5.2f seconds\n',attackDurSec);
fprintf('Avg. Relay Used: %5.2f\n',mean(logger.numRelays));
cost=EC2_Relay_Rate*attackDurSec/60/60*mean(logger.numRelays);
fprintf('Attack Cost: %5.4f\n',cost);


