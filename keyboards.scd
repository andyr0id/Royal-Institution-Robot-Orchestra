/*
This is the code for the keyboards, run from main.scd
*/
(
if (~verbose.isNil) { ~verbose = true; };
~keyboardsChannel = 2;
~keyboardsPanic = 1;

~playActions.add({|clock|
	// send an additional noteOff to prevent a note from getting stuck
	clock.sched(8*12, {
		~midiOuts[0].noteOff(~keyboardsChannel, 47);
	});

	if (~verbose) {
		"keyboards play!".postln;
	};
});

//a special message to get the robots to dance!
~keyboardsEndNote = 2;
~endActions.add({
	~midiOuts[0].noteOn(~keyboardsChannel, ~keyboardsEndNote);
	if (~verbose) {
		"keyboards end!".postln;
	};
});
)