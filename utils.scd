/*
A big function that converts a MIDI file into a Pattern,
and adjusts each channel based on latency data.
*/
(
//more complex pattern playback
~toMIDIPattern = {|f, channelToOutMap, latencies = nil, amp = 1, useTempo = true, repeat = false| // amp: amp when velo == 127
	var thisFile, repeats;

	if (repeat) {
		repeats = inf;
	} {
		repeats = 1;
	};

	// todo: create multi-note events from chords, detect rests

	if (useTempo) {
		if (f.timeMode == 'seconds') {
			thisFile = f;
		} {
			thisFile = f.copy.timeMode_('seconds');
		};
	} {
		if (f.timeMode == 'ticks') {
			thisFile = f;
		} {
			thisFile = f.copy.timeMode_( 'ticks' );
		};
	};
	Ppar(
		({|tr|
			var sustainEvents, deltaTimes, outs, delays;
			sustainEvents = thisFile.noteSustainEvents(nil, tr);
			if (sustainEvents.size > 0) {
				//sustainEvents = [track, absTime, \noteOn, channel, note, velo, dur, upVelo]
				if (latencies.notNil) {
					var delays = latencies.maxItem - latencies;
					sustainEvents.do {|v,i|
						var chanIndex, delay;
						chanIndex = sustainEvents[i][3];
						delay = delays[chanIndex];
						if (delay > 0) {
							sustainEvents[i][1] = sustainEvents[i][1]+delay;
						};
					};
				};
				sustainEvents = sustainEvents.flop;
				outs = Array.fill(sustainEvents[3].size, {|i|
					var chanIndex = sustainEvents[3][i];
					channelToOutMap[chanIndex];
				});
				if (useTempo) {
					deltaTimes = sustainEvents[1].differentiate;
				} {
					// always use 120BPM
					deltaTimes = (sustainEvents[1] / (f.division*2)).differentiate;
					sustainEvents[6] = sustainEvents[6] / (f.division*2);
				};
				Pbind(
					\type, \midi,
					\midiout, Pseq([channelToOutMap[0]] ++ outs, repeats),
					\dur, Pseq(deltaTimes ++ [0], 1),
					\midinote, Pseq([\rest] ++ sustainEvents[4], repeats),
					\amp, Pseq([0] ++ (sustainEvents[5] / 127) * amp, repeats),
					\sustain, Pseq([0] ++ sustainEvents[6], repeats),
					\chan, Pseq([0] ++ sustainEvents[3], repeats)
				)
			} { nil }
		} ! f.tracks).select({ |item| item.notNil })
	);
};
)