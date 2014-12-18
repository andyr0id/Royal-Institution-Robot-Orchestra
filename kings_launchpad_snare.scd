/*
Launchpad control of just the snare.
Requires my Launchpad class, availiable separately.
*/
(
~kingsSnareTTY = 0;
~kingsSnare = SerialPort(
	SerialPort.devices[~kingsSnareTTY],
	baudrate: 57600,
	crtscts: true);
~kingsSnareStrikeA = {
	{~kingsSnare.put(131);}.fork;
};
~kingsSnareStrikeB = {
	{~kingsSnare.put(132);}.fork;
};
~kingsSnareStrikeAB = {
	{~kingsSnare.put(160);}.fork;
};

l = Launchpad();

//snare
l.setFunc("A1", {|key|
	~kingsSnareStrikeA.();
	l.buttonFeedback(key, true);
});
l.setFunc("A2", {|key|
	~kingsSnareStrikeB.();
	l.buttonFeedback(key, true);
});
l.setColour("A1", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("A2", Launchpad.fullGreen, Launchpad.lowAmber);

l.updateColours;
)

(
~kingsSnare.close;
);

/*
SerialPort.listDevices;
l.connect
l.free
*/