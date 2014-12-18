/*
This file was used to demo the MIDI printer during the show.
*/
(
m = SimpleMIDIFile.read(thisProcess.nowExecutingPath.dirname +/+ "midi/doctor who printer demo v3.mid");
//init MIDI
if (MIDIClient.initialized.not) {
	MIDIClient.init;
};
MIDIClient.destinations.do {|d,i|
	[d.device,d.name,d.uid].postln;
	if (d.device == "MidiSport 1x1" && d.name == "MidiSport 1x1 MIDI 1") { // MIDI interface
		MIDIOut.connectByUID(0, d.uid);
		~midiConnections.add([0, d.uid]);
	};
};
p = Pchain(
	(type: \midi, midiout: MIDIOut(0), chan: 4),
	m.p
).play;
)