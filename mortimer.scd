/*
This is the code to control Mortimer the drumbot via OSC messages.
*/
(
if (~verbose.isNil) { ~verbose = true; };
//mortimer control
~mortimerChan = 9;
// ~mortimer = NetAddr("192.168.0.102", 57120);
// ~mortimer = NetAddr("192.168.104.19", 57120);
// ~mortimer = NetAddr("169.254.10.53", 57120);
~mortimer = NetAddr("10.0.0.35", 57120);
~mortimerKick = 36;
~mortimerFloortom = 41;
~mortimerRelativeLatency = 0.05;
//DONT SEND THE FLOOR TOM!
~mortimerNoteOn = MIDIdef.noteOn(\mortimerNoteOn, {|val, num, chan, src|
	if (num != ~mortimerFloortom) {
		{
			if (num != ~mortimerKick) {
				~mortimerRelativeLatency.wait;
			};
			~mortimer.sendMsg("/noteOn", num);
			//if (~verbose) { ("Mortimer /noteOn " ++ num).postln; };
		}.fork;
	};
}, chan: ~mortimerChan);
~playActions.add({
	~mortimer.sendMsg("/start");
	if (~verbose) {
		"mortimer start!".postln;
	};
});
~endActions.add({
	~mortimer.sendMsg("/end");
	if (~verbose) {
		"mortimer end!".postln;
	};
});
)


/*
~mortimer.sendMsg("/noteOn", 36);
~mortimer.sendMsg("/noteOn", 38);
~mortimer.sendMsg("/noteOn", 49);
~mortimerNoteOn.remove
*/