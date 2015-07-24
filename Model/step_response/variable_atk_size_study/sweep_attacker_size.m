function output=sweep_attacker_size(CRPA,numAttackers,numClients)

clear DSim attacker client logger mgmtServer server

DSim=dsim.DSim.getInstance();

server=dsim.Server();
DSim.addAgent(server);

mgmtServer=dsim.MgmtServer(numClients,0);
mgmtServer.targetServer=server.id;
DSim.addAgent(mgmtServer);

for i=1:numClients
client=dsim.Client();
client.managementServer=mgmtServer.id;
DSim.addAgent(client);
end

server.responseFrequency=2000;

for i=1:numAttackers
    attacker=dsim.Attacker();
    attacker.managementServer=mgmtServer.id;
    attacker.attackStartTime=10;
    DSim.addAgent(attacker);
end

logger=dsim.Logger();
DSim.addAgent(logger);

%Some tuning parameters
mgmtServer.targetRiskPerRelay=1;
mgmtServer.CRPA=CRPA;


DSim.run(100);

tempRelay=dsim.RelayNode();

EC2_Scale_Factor=40/tempRelay.startupDelay;
EC2_Relay_Rate=0.02; %Hourly Rate in Dollars

time=logger.time*EC2_Scale_Factor;
pft=logger.pft;
pft(isnan(pft))=1;
pft(logger.time<attacker.attackStartTime)=0;

output.time=time;
output.pft=pft;
output.numRelays=logger.numRelays;

end