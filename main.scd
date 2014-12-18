/*
This is the main file for the entire band.
First run the INIT patch, followed by the Play patch.
There are also patches for sedning MIDI panic and reset instructions.
There is testing and debug code in the sandbox section of this file.
Requires Quark: wslib
*/

/************
 * ! INIT ! *
 ************/
(
//set a path variable
~path = thisProcess.nowExecutingPath.dirname;
//which parts are running
/*~parts = (
	guitars: false,
	uavs: false,
	mortimer: false,
	kings: false,
	theremin: true,
	keyboards: false
);*/
~parts = (
	guitars: true,
	uavs: true,
	mortimer: true,
	kings: true,
	theremin: true,
	keyboards: true
);
~verbose = true;
//boot server
s.boot;
//read in midi file
m = SimpleMIDIFile.read(~path +/+ "midi/song.mid");
m.sortMIDIEvents;
/*m.noteEvents.do {|evt|
	evt[3] = evt[0];
	if (evt[2] == \noteOn && evt[5] == 0) {
		evt[2] = \noteOff;
	};
};
m.adjustTracks;*/
~file = m;

//init MIDI
if (MIDIClient.initialized.not) {
	MIDIClient.init;
	{
		while {
			MIDIClient.initialized.not
		} {
			0.1.wait;
		};
	}.fork;
};
~midiOuts = [MIDIOut(0), MIDIOut(1)];

~panic = {
	~midiOuts.do {|o|
		(0 .. 15).do {|j|
			o.allNotesOff(j); //panic message
		};
	};
};

~playActions = List();
~endActions = List();

//latencies
~latencies = 0.0 ! 16;
/*
Channels
1: Organ
2: Xylophone
3: Keyboard
4: Drone
5: Guitar
6: Bass
7: Printer
8: Theremin
9: Kings Drums
10: Mortimer Drums
*/
~latencies[0] = 0.15; //Organ
~latencies[1] = 0.1; //Xylophone
~latencies[2] = 0.3; //Keyboard
~latencies[3] = 0.7; //Drone
~latencies[4] = 0.1; //Printer
~latencies[5] = 0.2; //Guitar
~latencies[6] = 0.2; //Bass
~latencies[7] = 0.3; //Theremin
~latencies[8] = 0.2; //Kings Drums
~latencies[9] = 0.12; //Mortimer Drums

~delays = ~latencies.maxItem - ~latencies;
~delays.postln;

~file.noteEvents.do {|evt|
	// [track, absTime, \noteOn, channel, note, velo, dur, upVelo]
	//swap channels for print, guitar, bass
	if (evt[3] == 6) {
		evt[3] = 4;
	} {
		if (evt[3] == 5) {
			evt[3] = 6;
		} {
			if (evt[3] == 4) {
				evt[3] = 5;
			};
		};
	};
	//fix organ
	if (evt[3] == 0) {
		evt[4] = evt[4] + 12;
	};
};

//channel > midiout routing
~channelToOuts = ~midiOuts[0] ! 16;

//load functions
this.executeFile(~path +/+ "utils.scd");
if (~parts[\uavs]) {
	//UAV control
	this.executeFile(~path +/+ "uavs.scd");
};
if (~parts[\guitars]) {
	//Guitar control
	this.executeFile(~path +/+ "guitar_bass.scd");
};
if (~parts[\mortimer]) {
	//Mortimer control
	this.executeFile(~path +/+ "mortimer.scd");
};
if (~parts[\kings]) {
	//Kings control
	this.executeFile(~path +/+ "kings.scd");
};
if (~parts[\theremin]) {
	//Theremin control
	this.executeFile(~path +/+ "theremin.scd");
};
if (~parts[\keyboards]) {
	//Keyboards control
	this.executeFile(~path +/+ "keyboards.scd");
};

{
	1.wait;
	//make MIDI connections
	~midiConnections = List();
	MIDIClient.destinations.do {|d,i|
		[d.device,d.name,d.uid].postln;
		if (d.device == "SuperCollider" && d.name == "in0") { // SC in0
			MIDIOut.connectByUID(0, d.uid);
			~midiConnections.add([0, d.uid]);
		};
		if (d.device == "MidiSport 1x1" && d.name == "MidiSport 1x1 MIDI 1") { // MIDI interface
			MIDIOut.connectByUID(0, d.uid);
			~midiConnections.add([0, d.uid]);
			MIDIOut.connectByUID(1, d.uid);
			~midiConnections.add([1, d.uid]);
		};
		if (d.device == "MIDI monitor" && d.name == "midi in") {  // MIDI monitor
			MIDIOut.connectByUID(0, d.uid);
			~midiConnections.add([0, d.uid]);
		};
	};

	~disconnectMIDI = {
		~midiConnections.do {|v, i|
			MIDIOut.disconnectByUID(v[0], v[1]);
		};
	};

	"MIDI connections ready".postln;
}.fork;
)

/************
 * ! PLAY ! *
 ************/
(
~play = {|clock|
	~pattern.play;
	~playActions.do {|a|
		a.(clock);
	};
	/*c = MIDIClockOut(tempoClock: clock);
	c.port = ~midiOuts[1];
	c.play;*/
};
~pattern = ~toMIDIPattern.(~file, ~channelToOuts, ~latencies);
~pattern.list.postln;
~panic.();
{
	1.0.wait;
	~clock = TempoClock(m.tempo/60);
	~play.(~clock);
}.fork;
)

/***********
 * ! END ! *
 ***********/
(
~endActions.do {|a|
	a.();
};
)

/*************
 * ! PANIC ! *
 *************/
(
~panic.();
)

/***************
 * ! CLEANUP ! *
 ***************/
(
CmdPeriod.run;
//c.stop;
~panic.();
~guitarCleanup.();
~kingsCleanup.();
~disconnectMIDI.();
)

/***************
 * ! SANDBOX ! *
 ***************/

Quarks.help("wslib");
Quarks.gui;

//open the folder
("thunar " ++ ~path.escapeChar($ )).unixCmd;
//open the MIDI monitor
"gmidimonitor --alsa".unixCmd;
"killall gmidimonitor".unixCmd;

//simple pattern playback
(
p = m.p.play;
)

//simple pattern playback over midi
(
p = Pchain(
	(type: \midi, midiout: ~midiOuts[0], chan: 4),
	m.p
).play;
)

"C1".asNote.asInteger

//add a second track for testing
(
~m1 = SimpleMIDIFile.read(~midiFiles[1]);
~m1.sortMIDIEvents;
m.addAllMIDIEvents(~m1.midiEvents);
m.adjustTracks;
)

//SC MIDI synth for debug
x = MIDISynth();
//remove debug synth
x.remove;

//analyse the file
m.adjustTracks
m.tracks
m.noteEvents(5)
m.firstNoteOnTrack()
m.analyzeTracks('noteOn')
m.plot
m.usedTracks(0)
[m.tempo, m.timeSignatureAsArray].postln;
m.info
m.timeMode.postln;
m.midiEvents;

//arduino
(
//list devices
SerialPort.listDevices;
//choose appropriate index. You can also cut and paste the path name directly in the port argument
d = SerialPort.devices[6]; // or "/dev/tty.usbserial-A1001NeZ"
f = SCPyduino.new(d);
{
	//wait ~three secs
	3.5.wait;
	// posts the version of Firmata returned from the microcontroller if connection is ok
	f.firmataVersion;
}.fork;


~drumEvt = {|evt|
	//drum code goes here:

};
)

//close the SerialPort connection.
f.close;