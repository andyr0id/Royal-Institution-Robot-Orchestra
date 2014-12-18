/*
Launchpad control of the full KCL drumkit.
Requires my Launchpad class, availiable separately.
*/
(
~path = thisProcess.nowExecutingPath.dirname;

if (~kingsCymbalkickStrikeA.isNil) {
	this.executeFile(~path +/+ "kings.scd");
};

l = Launchpad();

//kick
l.setFunc("A1", {|key|
	~kingsCymbalkickStrikeA.();
	l.buttonFeedback(key, true);
});
l.setFunc("B1", {|key|
	~kingsCymbalkickStrikeB.();
	l.buttonFeedback(key, true);
});
l.setFunc("C1", {|key|
	~kingsCymbalkickStrikeAB.();
	l.buttonFeedback(key, true);
});
l.setColour("A1", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("B1", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("C1", Launchpad.fullGreen, Launchpad.lowAmber);

//snare
l.setFunc("A2", {|key|
	~kingsSnareStrikeA.();
	l.buttonFeedback(key, true);
});
l.setFunc("B2", {|key|
	~kingsSnareStrikeB.();
	l.buttonFeedback(key, true);
});
l.setFunc("C2", {|key|
	~kingsSnareStrikeAB.();
	l.buttonFeedback(key, true);
});
l.setColour("A2", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("B2", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("C2", Launchpad.fullGreen, Launchpad.lowAmber);

//hihat
l.setFunc("A3", {|key|
	~kingsHihatStrikeA.();
	l.buttonFeedback(key, true);
});
l.setFunc("B3", {|key|
	~kingsHihatStrikeB.();
	l.buttonFeedback(key, true);
});
l.setFunc("C3", {|key|
	~kingsHihatStrikeAB.();
	l.buttonFeedback(key, true);
});
l.setColour("A3", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("B3", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("C3", Launchpad.fullGreen, Launchpad.lowAmber);

//small tom
l.setFunc("A4", {|key|
	~kingsSmalltomStrikeA.();
	l.buttonFeedback(key, true);
});
l.setFunc("B4", {|key|
	~kingsSmalltomStrikeB.();
	l.buttonFeedback(key, true);
});
l.setFunc("C4", {|key|
	~kingsSmalltomStrikeAB.();
	l.buttonFeedback(key, true);
});
l.setColour("A4", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("B4", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("C4", Launchpad.fullGreen, Launchpad.lowAmber);

//large tom
l.setFunc("A5", {|key|
	~kingsLargetomStrikeA.();
	l.buttonFeedback(key, true);
});
l.setFunc("B5", {|key|
	~kingsLargetomStrikeB.();
	l.buttonFeedback(key, true);
});
l.setFunc("C5", {|key|
	~kingsLargetomStrikeAB.();
	l.buttonFeedback(key, true);
});
l.setColour("A5", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("B5", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("C5", Launchpad.fullGreen, Launchpad.lowAmber);

//floor tom
l.setFunc("A6", {|key|
	~kingsFloortomStrikeA.();
	l.buttonFeedback(key, true);
});
l.setFunc("B6", {|key|
	~kingsFloortomStrikeB.();
	l.buttonFeedback(key, true);
});
l.setFunc("C6", {|key|
	~kingsFloortomStrikeAB.();
	l.buttonFeedback(key, true);
});
l.setColour("A6", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("B6", Launchpad.fullGreen, Launchpad.lowAmber);
l.setColour("C6", Launchpad.fullGreen, Launchpad.lowAmber);
l.updateColours;
)

/*
l.connect
l.free
*/