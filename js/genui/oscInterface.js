import osc from 'osc';

const startServer = () => {
    var udpPort = new osc.UDPPort({
        localAddress: "0.0.0.0",
        localPort: 57121
    });
    
    udpPort.on("ready", function () {
        var ipAddresses = getIPAddresses();
        console.log("Listening for OSC over UDP.");
        ipAddresses.forEach(function (address) {
            console.log(" Host:", address + ", Port:", udpPort.options.localPort);
        });
        console.log("To start the demo, go to http://localhost:8081 in your web browser.");
    });
    
    udpPort.open();
}