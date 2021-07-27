const WebSocket = require("ws");

const wss = new WebSocket.Server({ port: 8082 });

var players = [];
var nextID = [];
var t = [];
var playerCount = 0;
var hex = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"];

wss.on("connection", ws => {
    playerID = players.length;
    //console.log("Client connected! Here is the current playerID: " + playerID);
    if (nextID.length != 0) {
        playerID = nextID.pop();
    }
    t[playerID] = Date.now();
    playerCount = playerCount + 1;
    //ws.send("id," + playerID.toString());
    ws.on("message", data => {
	//console.log("Server just got a message!");
	//console.log(data);
	var s = "";
	var i = 0;
	var j = 0;
	var currpid = playerID;
        var currTime = Date.now();
	if (String.fromCharCode(data[0]) == "i") {
	    i = 1;
        }
	for (i; i < data.length; i++) {
	    curr = String.fromCharCode(data[i]);
	    if (curr == ":") { 
		j = i + 1; 
		//console.log("Iterating through data and found a :");
	    }
	    s += curr;
	}
	if (s[0] == "G") { ws.send(s); return null; }
	//console.log(s);
	if (j != 0) {
	    //console.log("Setting playerID: " + s.slice(0,j-1));
	    currpid = Number(s.slice(0, j-1));
	}
	t[currpid] = currTime;
	players[currpid] = s.slice(j);
	//console.log(s.slice(j));
	//console.log(String.fromCharCode(data[0]));
	//ws.send("You are connected!");
	//ws.send("This should be looping through client and server!")
	for (var k = 0; k < t.length; k++) {
	    if (currTime - t[k] > 60000) {
	        //console.log("--- FOLLOWING PLAYER ID SHOULD BE KICKED --- : " + k.toString())
		players[k] = " , ";
		nextID.push(k);
		playerCount = playerCount - 1;
	    }
	}
	pStr = players.toString();
	hexLen = hex[Math.floor((pStr.length) / 16)] + hex[(pStr.length) % 16];
	res = hexLen + currpid.toString() + pStr;
	//console.log(currpid.toString() + ": " + res);
	ws.send(res);
    });

    ws.on("close", () => {
        //console.log("- - Client disconnected");
	playerCount = playerCount - 1;
	if (playerCount == 0) {
	    playerCount = 0;
	    players = [];
	    nextID = [];
	    t = [];
	}
    })
});
