/*
This is the code to control the iCub theremin via OSC messages.
*/
(
if (~verbose.isNil) { ~verbose = true; };
~thereminChannel = 7;
// ~theremin = NetAddr("192.168.0.107", 3334);
// ~theremin = NetAddr("192.168.104.18", 3334);
~theremin = NetAddr("10.0.0.121", 3334);

~thereminEvts = ~file.noteSustainEvents.select({|evt|
	evt[3] == ~thereminChannel;
});

~thereminCurrEvt = 0;

MIDIdef.noteOn(\thereminNoteOn, {|val, num, chan, src|
	~theremin.sendMsg("/noteOn", num, val);
	if (~verbose) {
		("theremin noteOn: " ++ num.asString).postln;
	};
}, chan: ~thereminChannel);

MIDIdef.noteOff(\thereminNoteOff, {|val, num, chan, src|
	var thisOn, nextOn, doNoteOff;
	doNoteOff = false;
	if (~thereminCurrEvt < (~thereminEvts.size-1)) {
		thisOn = ~thereminEvts[~thereminCurrEvt];
		nextOn = ~thereminEvts[~thereminCurrEvt+1];
		if (nextOn[1] - (thisOn[1]+thisOn[6]) > 1) {
			doNoteOff = true;
		};
	} {
		doNoteOff = true;
	};
	if (doNoteOff) {
		~theremin.sendMsg("/noteOff");
		if (~verbose) {
			"theremin noteOff!".postln;
		};
	};
	~thereminCurrEvt = (~thereminCurrEvt+1) % ~thereminEvts.size;
}, chan: ~thereminChannel);

MIDIdef.cc(\thereminPanic, {|val, num, chan, src|
	~theremin.sendMsg("/allNotesOff");
	if (~verbose) {
		"theremin panic!".postln;
	};
}, 123, ~thereminChannel);

~endActions.add({
	~theremin.sendMsg("/end");
	if (~verbose) {
		"theremin end!".postln;
	};
});
)

/*
~theremin.sendMsg("/noteOn", 64, 126);
~theremin.sendMsg("/noteOn", 55, 126);
~theremin.sendMsg("/noteOff");
*/