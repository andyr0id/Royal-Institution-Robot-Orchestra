/*
This is the code for controlling the KCL Drumbot directly via USB.
We connect to the Arduinos directly via the SerialPort class,
and send bytes to each of the ports to trigger the drums

            Ch A | Ch B | Both
Hi Hat -      129   130   144
Snare -       131   132   160
Cymbal&Kick - 133   134   176
Small Tom -   135   136   192
Large Tom -   137   138   208
Floor Tom -   139   140   224
*/

//-----------START-----------
(
if (~verbose.isNil) { ~verbose = true; };
~kingsStart = 0;
~kingsFirst = "/dev/ttyACM" ++ ~kingsStart;
~kingsKickTTY = ~kingsStart;

if (SerialPort.devices[~kingsKickTTY] == ~kingsFirst) {
	SerialPort.devices[~kingsKickTTY].postln;
	~kingsCymbalkick = SerialPort(
		SerialPort.devices[~kingsKickTTY],
		baudrate: 57600,
		crtscts: true);

	~kingsSnareTTY = ~kingsKickTTY+1;
	~kingsSnare = SerialPort(
		SerialPort.devices[~kingsSnareTTY],
		baudrate: 57600,
		crtscts: true);

	~kingsSmalltomTTY = ~kingsSnareTTY+1;
	~kingsSmalltom = SerialPort(
		SerialPort.devices[~kingsSmalltomTTY],
		baudrate: 57600,
		crtscts: true);

	~kingsHihatTTY = ~kingsSmalltomTTY+1;
	~kingsHihat = SerialPort(
		SerialPort.devices[~kingsHihatTTY],
		baudrate: 57600,
		crtscts: true);

	~kingsFloortomTTY = ~kingsHihatTTY+1;
	~kingsFloortom = SerialPort(
		SerialPort.devices[~kingsFloortomTTY],
		baudrate: 57600,
		crtscts: true);

	~kingsLargetomTTY = ~kingsFloortomTTY+1;
	~kingsLargetom = SerialPort(
		SerialPort.devices[~kingsLargetomTTY],
		baudrate: 57600,
		crtscts: true);

	~kingsHihatStrikeA = {
		{~kingsHihat.put(129);}.fork;
	};
	~kingsHihatStrikeB = {
		{~kingsHihat.put(130);}.fork;
	};
	~kingsHihatStrikeAB = {
		{~kingsHihat.put(144);}.fork;
	};
	~kingsSnareStrikeA = {
		{~kingsSnare.put(131);}.fork;
	};
	~kingsSnareStrikeB = {
		{~kingsSnare.put(132);}.fork;
	};
	~kingsSnareStrikeAB = {
		{~kingsSnare.put(160);}.fork;
	};
	~kingsCymbalkickStrikeA = {
		{~kingsCymbalkick.put(133);}.fork;
	};
	~kingsCymbalkickStrikeB = {
		{~kingsCymbalkick.put(134);}.fork;
	};
	~kingsCymbalkickStrikeAB = {
		{~kingsCymbalkick.put(175);}.fork;
	};
	~kingsSmalltomStrikeA = {
		{~kingsSmalltom.put(135);}.fork;
	};
	~kingsSmalltomStrikeB = {
		{~kingsSmalltom.put(136);}.fork;
	};
	~kingsSmalltomStrikeAB = {
		{~kingsSmalltom.put(192);}.fork;
	};
	~kingsLargetomStrikeA = {
		{~kingsLargetom.put(137);}.fork;
	};
	~kingsLargetomStrikeB = {
		{~kingsLargetom.put(138);}.fork;
	};
	~kingsLargetomStrikeAB = {
		{~kingsLargetom.put(208);}.fork
	};
	~kingsFloortomStrikeA = {
		{~kingsFloortom.put(139);}.fork;
	};
	~kingsFloortomStrikeB = {
		{~kingsFloortom.put(140);}.fork;
	};
	~kingsFloortomStrikeAB = {
		{~kingsFloortom.put(224);}.fork;
	};

};

~kingsTestAll = {
	var counter, dur, list;
	counter = 0;
	dur = 0.5;
	list = [
		~kingsHihatStrikeA.(),
		~kingsHihatStrikeB.(),
		~kingsHihatStrikeAB.(),
		~kingsSnareStrikeA.(),
		~kingsSnareStrikeB.(),
		~kingsSnareStrikeAB.(),
		~kingsCymbalkickStrikeA.(),
		~kingsCymbalkickStrikeB.(),
		~kingsCymbalkickStrikeAB.(),
		~kingsSmalltomStrikeA.(),
		~kingsSmalltomStrikeB.(),
		~kingsSmalltomStrikeAB.(),
		~kingsLargetomStrikeA.(),
		~kingsLargetomStrikeB.(),
		~kingsLargetomStrikeAB.(),
		~kingsFloortomStrikeA.(),
		~kingsFloortomStrikeB.(),
		~kingsFloortomStrikeAB.()
	];


	Task.new ({

		{counter < list.size}.while ({

			list[counter].();

			counter.postln;

			counter = counter + 1 ;
			dur.wait;
		});
	}).play;
};



~kingsCleanup = {
	if (~kingsCymbalkick.notNil) {
		~kingsCymbalkick.close;
		~kingsHihat.close;
		~kingsFloortom.close;
		~kingsLargetom.close;
		~kingsSmalltom.close;
		~kingsSnare.close;
	};
};

/*
C2: Kick "C1".asNote.asInteger
D2: Snare
F2: Floor Tom
C#3: Crash Cymbal "C#3".asNote.asInteger
*/
~kingsKickNote = 36;
~kingsSnareNote = 38;
~kingsFloortomNote = 41;
~kingsHihatNote = 42;
~kingsCymbalNote = 49;
~kingsSnareCount = 0;
~kingsHihatCount = 0;
~kingsChan = 8;
~kingsSnareRelativeLatency = 0.0;
~kingsKickRelativeLatency = 0.05;
~kingsFloortomRelativeLatency = 0.0;
~kingsCymbalRelativeLatency = 0.0;
~kingsHihatRelativeLatency = 0.0;
MIDIdef.noteOn(\kingsNoteOn, {|val, num, chan, src|
	//if (~verbose) { ("Kings: " ++ num).postln; };
	if (num == ~kingsKickNote) {
		{
			~kingsKickRelativeLatency.wait;
			//if (~verbose) { "Kings: kick".postln; };
			~kingsCymbalkickStrikeA.();
		}.fork;
	};
	if (num == ~kingsCymbalNote) {
		{
			~kingsCymbalRelativeLatency.wait;
			//if (~verbose) { "Kings: cymbal".postln; };
			~kingsCymbalkickStrikeB.();
		}.fork;
	};
	if (num == ~kingsFloortomNote) {
		{
			~kingsFloortomRelativeLatency.wait;
			// if (~verbose) { "Kings: floortom".postln; };
			~kingsFloortomStrikeA.();
		}.fork;
	};
	if (num == ~kingsSnareNote) {
		{
			~kingsSnareRelativeLatency.wait;
			// if (~verbose) { "Kings: snare".postln; };
			if (~kingsSnareCount == 0) {
				~kingsSnareStrikeA.();
			} {
				~kingsSnareStrikeB.();
			};
			~kingsSnareCount = (~kingsSnareCount + 1) % 2;
		}.fork;
	};
	if (num == ~kingsHihatNote) {
		{
			~kingsHihatRelativeLatency.wait;
			if (~kingsHihatCount == 0) {
				~kingsHihatStrikeA.();
			} {
				~kingsHihatStrikeB.();
			};
			~kingsHihatCount = (~kingsHihatCount + 1) % 2;
		}.fork;
	};
}, chan: ~kingsChan);
)

/*
~kingsTestAll.();

~kingsHihatStrikeA.();
~kingsHihatStrikeB.();
~kingsHihatStrikeAB.(); //err
~kingsSnareStrikeA.();
~kingsSnareStrikeB.();
~kingsSnareStrikeAB.();
~kingsCymbalkickStrikeA.();
~kingsCymbalkickStrikeB.();
~kingsCymbalkickStrikeAB.(); //err
~kingsSmalltomStrikeA.();
~kingsSmalltomStrikeB.();
~kingsSmalltomStrikeAB.(); //err
~kingsLargetomStrikeA.();
~kingsLargetomStrikeB.();
~kingsLargetomStrikeAB.(); //err
~kingsFloortomStrikeA.();
~kingsFloortomStrikeB.();
~kingsFloortomStrikeAB.(); //err

fork{~kingsPort.put(0)};

~kingsCleanup.();

SerialPort.listDevices;
SerialPort.closeAll;
*/