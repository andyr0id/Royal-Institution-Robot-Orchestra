Royal Institution Robot Orchestra
=================================

This is the code that ran the entire Robot Orchestra and a couple of other demos during the final Royal Institution Christmas Lecture 2014.

Implemented in SuperCollider, the main.scd file is the entry point.
A MIDI file is read in and sequenced using SuperCollider's Patterns library.
The sequencing takes into account the various intruments' latencies and delays the MIDI signals accordingly.

Some of the instruments were directly controlled via MIDI cable, but others were controlled with Open Sound Control, or directly down a USB port.
