/*
This is the code for connecting and triggering the guitar and bass.
It is run from main.scd
Requires an arduino loaded withthe Firmata firmware and SCPyduino quark: Quarks.help("SCPyduino");
*/
(
if (~verbose.isNil) { ~verbose = true; };
~guitarTTY = 6;
~guitarPort = SerialPort.devices[~guitarTTY];
~guitarArduino = SCPyduino.new(~guitarPort);
~guitarReady = false;

~guitarChan = 5;
~guitarPin = 12;
~guitarTriggerMode = \firstnote;
//~guitarTriggerMode = \start;
~bassChan = 6;
~bassPin = 8;
~bassTriggerMode = \firstnote;
//~bassTriggerMode = \start;

{
	while {
		~guitarArduino.firmataVersion == "None" || ~guitarArduino.firmataVersion.isNil;
	} {
		0.1.wait;
	};
	~guitarDigitalPortIndex = (~guitarPin > 7).if { 1 } { 0 };
	~bassDigitalPortIndex = (~bassPin > 7).if { 1 } { 0 };
	~guitarArduino.digitalPorts[~guitarDigitalPortIndex].active = 1;
	if (~bassDigitalPortIndex != ~guitarDigitalPortIndex) {
		~guitarArduino.digitalPorts[~bassDigitalPortIndex].active = 1;
	};
	~guitarArduino.digital[~guitarPin].mode = ~guitarArduino.digital_output;
	~guitarArduino.digital[~guitarPin].write(0);
	~guitarArduino.digital[~bassPin].mode = ~guitarArduino.digital_output;
	~guitarArduino.digital[~bassPin].write(0);
	~guitarReady = true;
	if (~verbose) {
		("Guitars ready: " ++ ~guitarArduino.firmataVersion).postln;
	};
}.fork;

~guitarTriggered = false;
~triggerGuitar = {
	if (~guitarReady.not) {
		if (~verbose) {
			"Warning: Guitar trigger called when not ready!".postln;
		};
	} {
		if (~guitarTriggered.not) {
			~guitarArduino.digital[~guitarPin].write(1);
			{
				0.5.wait;
				~guitarArduino.digital[~guitarPin].write(0);
			}.fork;
			if (~verbose) {
				"Go go gadget guitar!".postln;
			};
			~guitarTriggered = true;
		} {
			"Warning: Guitar already triggered!".postln;
		};
	};
};
~bassTriggered = false;
~triggerBass = {
	if (~guitarReady.not) {
		if (~verbose) {
			"Warning: Bass trigger called when not ready!".postln;
		};
	} {
		if (~bassTriggered.not) {
			~guitarArduino.digital[~bassPin].write(1);
			{
				0.5.wait;
				~guitarArduino.digital[~bassPin].write(0);
			}.fork;
			if (~verbose) {
				"Go go gadget bass!".postln;
			};
			~bassTriggered = true;
		} {
			"Warning: Bass already triggered!".postln;
		};
	};
};

~guitarNoteOn = MIDIdef.noteOn(\guitarNoteOn, {|val, num, chan, src|
	if (~guitarTriggered.not) {
		~triggerGuitar.();
	};
}, chan: ~guitarChan);

~bassNoteOn = MIDIdef.noteOn(\bassNoteOn, {|val, num, chan, src|
	if (~bassTriggered.not) {
		~triggerBass.();
	};
}, chan: ~bassChan);

~gbAnyNoteOn = MIDIdef.noteOn(\gbAnyNoteOn, {|val, num, chan, src|
	if (~guitarTriggered.not && ~guitarTriggerMode == \start) {
		~triggerGuitar.();
	};
	if (~bassTriggered.not && ~bassTriggerMode == \start) {
		~triggerBass.();
	};
});

~guitarCleanup = {
	{
		if (~guitarTriggered) {
			~guitarArduino.digital[~guitarPin].write(0);
		};
		~guitarTriggered = false;
		if (~bassTriggered) {
			~guitarArduino.digital[~bassPin].write(0);
		};
		~bassTriggered = false;
		0.1.wait;
		//close the SerialPort connection.
		~guitarArduino.close;
	}.fork;
};
)

/*
~triggerGuitar.();
~triggerBass.();
~guitarCleanup.();
SerialPort.closeAll
*/