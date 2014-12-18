/*
This is the code to control the UAV cymbal via OSC messages.
*/
(
if (~verbose.isNil) { ~verbose = true; };
//UAV control
~uavChan = 3;
~uavNote = nil;
// ~uav = NetAddr("192.168.0.104", 7110);
// ~uav = NetAddr("192.168.104.24", 7110);
~uav = NetAddr("10.0.0.64", 7110);
~verbose = true;
~uavNoteOn = MIDIdef.noteOn(\uavNoteOn, {|val, num, chan, src|
	~uav.sendMsg("/noteOn", num);
	if (~verbose) { ("UAV /noteOn " ++ num).postln; };
}, ~uavNote, ~uavChan);
)

/*
~uav.sendMsg("/noteOn", 36);
*/