
/*vliegtuig*/
s.boot
(
SynthDef.new(\vliegtuig,
	{   arg gate = 1, amp = 0.25;
		var env, sig, freq1, freq2;
		freq1 =XLine.kr( {Rand(1, 200)}!10,100,8);
		sig = Saw.ar(freq1) ;
		sig = Splay.ar(sig, 1,0.5,0);
		env = EnvGen.kr(Env.adsr(12, 3, 0.75, 2), gate, doneAction:2);
		sig = sig * env *  amp;

		Out.ar(0, sig);
	};
).add;
)


/*drone*/

(
SynthDef.new(\splaySine_high,
	{   arg gate = 1, amp = 0.07, freqLaag = 660, freqHoog = 880;
		var env, sig;
		sig = SinOsc.ar( {Rand(freqLaag, freqHoog)}!20) ;
		sig = Splay.ar(sig, 1,0.5,1);
		env = EnvGen.kr(Env.adsr(0.09, 1, 0.75, 10), gate, doneAction:2);
		sig = sig * env * amp;

		Out.ar(0, sig);
	};
).add;
)


(
SynthDef.new(\splaySine_highL,
	{   arg gate = 1, amp = 0.07, freqLaag = 660, freqHoog = 880;
		var env, sig;
		sig = SinOsc.ar( {Rand(freqLaag, freqHoog)}!20) ;
		sig = Splay.ar(sig, 1,0.5,-1);
		env = EnvGen.kr(Env.adsr(0.09, 1, 0.75, 15), gate, doneAction:2);
		sig = sig * env * amp;

		Out.ar(0, sig);
	};
).add;
)

// akkoorden

(
SynthDef.new(\moog_chords,
	{   arg gate = 1, amp = 0.02, freq = 110, mod = 2.0, ampli = 0.02, stal = 70;
		var env, sig, freq2, ampMod, pony, pony2;

		pony = freq + 0;
		pony2 = freq + 40 - stal;
		freq2 =XLine.kr( {Rand(pony, pony2)}!4,pony,4.2);
		ampMod = SinOsc.ar(amp);
		sig = BMoog.ar(
			LFSaw.ar(freq2),
        SinOsc.kr(SinOsc.kr(0.005),1.5pi,1550,1800), 0.2,
			1);
		sig = Splay.ar(sig, 1,1);
		env = EnvGen.kr(Env.adsr(6 , 0.01, 1, 0.05), gate, doneAction:2);
		sig = sig * env * ampMod *ampli;
		Out.ar(100, sig.sum);
		Out.ar(0, sig);
	};
).add;
)


// strijkers

(
SynthDef.new(\strijker,
	{   arg gate = 1, amp = 0.25, freq= 600;
		var env, sig, vib;
		env = EnvGen.kr(Env.adsr(3, 4, 0.75, 4), gate, doneAction:2);
		sig = Saw.ar(Vibrato.ar(DC.ar(freq),4,0.004,0,0,0.04,0.1),0.8,0.007);
		sig = sig * env * amp;

		Out.ar([0, 1], sig);
	};
).add;
)

(
SynthDef.new(\strijker_staccato,
	{   arg gate = 1, amp = 0.25, freq= 600;
		var env, sig, vib;
		env = EnvGen.kr(Env.perc(0.1,0.5,0.2,-4), gate, doneAction:0);
		sig = Saw.ar(Vibrato.ar(DC.ar(freq),4,0.004,0,0,0.04,0.1),0.8,0.007);
		sig = sig * env * amp;

		Out.ar([0, 1], sig);
	};
).add;
)
(
Synth.tail(s,\jverb);
~pattern_randomBass = Pbind(
	\instrument, \moog_bass,
	\midinote, Pseq([50, 52, 53, 55, 56, 58, 69, 62],inf),
	\amp, Pshuf([0.02], inf),
	\mod, Prand([0.5, 0.8, 1.2, 1.5, 0.5 ], inf),
	\stal, Prand([0,70,0,20,0],inf),
	\sus, 4,
	\legato, Pseq([4,8], inf),
	\dur, Pseq([4], inf),
);
)

(
SynthDef(\jverb, {arg inBus=100;
	Out.ar(0, JPverb.ar(In.ar(inBus),5,0,10,0.707,0.5,3,0.1,1,1,1000,2000));
}).add
)

// Drums

(
SynthDef("hihat", {
	arg amp = 0.1;
	var sig, env;
	sig = BPF.ar(WhiteNoise.ar(220, 0), 15000,1,0.008,0.1)* amp;
	env = EnvGen.kr(Env.perc(0,0.1,1,[4,-4]),1,doneAction:2);
	Out.ar(0, sig * env* amp)
}).add;
)

(
SynthDef.new(\snare, {
	arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var env, snd1, snd2, sum;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = HPF.ar(
		in: WhiteNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: sinfreq, mul: env);
	sum = snd1 + snd2;
	Out.ar(out, Pan2.ar(sum, pan));
}).add;)

(
SynthDef.new(\kick, {
	arg   gate = 1, freq= 60, amp = 0.7;
	var   sig, env;
	env = EnvGen.kr(Env.perc(0,0.2,1,[4,-4]),gate,doneAction:2);
	sig = SinOsc.ar(freq) * amp;
	Out.ar([0, 1], sig*env);
}).add;
)

// Bass

(
SynthDef.new(\moog_basss,
	{   arg gate = 1, amp = 0.02, freq = 50, mod = 2.0, ampli = 0.02;
		var env, sig, freq2, ampMod;

		ampMod = SinOsc.ar(amp);
		freq2 = freq* mod;
		sig = BMoog.ar(
			LFSaw.ar(freq),
        SinOsc.kr(SinOsc.kr(2),1.5pi,1550,1800), 0.2,
        1);
		sig = Splay.ar(sig, 1,1);
		env = EnvGen.kr(Env.adsr(3 , 0.01, 0.75, 2), gate, doneAction:2);
		sig = sig * env * ampMod *ampli;

		Out.ar(0, sig);
	};
).add;
)



/*Het stuk*/
(
 var a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q;

// vliegtuig
i = Pbind(
    \instrument, \vliegtuig,
	\midinote, Pseq([60], 1),
	\amp, 0.25,
     \dur, Pseq([10], 1));

// drone
a = Pbind(
	\instrument, \splaySine_high,
	\midinote, Pseq([60], inf),
	\freqHoog, Pseq([990],inf),
	\freqLaag, Pseq([770],inf),
	\amp, 0.08,
	   \dur, Pseq([6], 1));
 b = Pbind(
	\instrument, \splaySine_high,
	\midinote, Pseq([60], inf),
	\freqHoog, Pseq([880],inf),
	\freqLaag, Pseq([660],inf),
	\amp, 0.08,
	   \dur, Pseq([5.75], 1));
c = Pbind(
	\instrument, \splaySine_high,
	\midinote, Pseq([60], inf),
	\freqHoog, Pseq([880],inf),
	\freqLaag, Pseq([660],inf),
	\amp, 0.08,
	   \dur, Pseq([5.50], 1));
d = Pbind(
	\instrument, \splaySine_high,
	\midinote, Pseq([60], inf),
	\freqHoog, Pseq([770],inf),
	\freqLaag, Pseq([550],inf),
	\amp, 0.08,
	   \dur, Pseq([5.25], 1));
 e = Pbind(
	\instrument, \splaySine_high,
	\midinote, Pseq([60], inf),
	\freqHoog, Pseq([550],inf),
	\freqLaag, Pseq([300],inf),
	\amp, 0.08,
	   \dur, Pseq([5.0], 1));
 f = Pbind(
	\instrument, \splaySine_high,
	\midinote, Pseq([60], inf),
	\freqHoog, Pseq([440],inf),
	\freqLaag, Pseq([200],inf),
	\amp, 0.08,
	   \dur, Pseq([4.75], 1));
 g = Pbind(
	\instrument, \splaySine_high,
	\midinote, Pseq([60], inf),
	\freqHoog, Pseq([100],inf),
	\freqLaag, Pseq([200],inf),
	\amp, 0.03,
	\dur, Pseq([4.50], 1));
 h = Pbind(
	\instrument, \splaySine_high,
	\midinote, Pseq([60], inf),
	\freqHoog, Pseq([120],inf),
	\freqLaag, Pseq([60],inf),
	\amp, 0.2,
	 \note, Pseq([7, 4, 0], inf),
	   \dur, Pseq([4.25], 1));

p = h = Pbind(
	\instrument, \splaySine_highL,
	\midinote, Pseq([60], inf),
	\freqHoog, Pseq([880],inf),
	\freqLaag, Pseq([660],inf),
	\amp, 0.2,
	 \note, Pseq([7, 4, 0], inf),
	   \dur, Pseq([4.25], 1));

// Akkoorden

Synth.tail(s,\jverb);
j = Pbind(
	 \instrument, \moog_chords,
	 \midinote, Pseq([50, 52, 53, 55, 56, 58, 69, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62, 62],inf),
	 \amp, Pshuf([0.02], inf),
	 \mod, Prand([0.5, 0.8, 1.2, 1.5, 0.5 ], inf),
	 \stal, Prand([0,70,0,20,0],inf),
	 \sus, 4,
	\ampli, Pseq([0.005,0.005,0.006,0.007,0.008,0.011,0.013,0.016,0.018,0.002,0.02,0.02,0.02,0.02,0.02,0.02,0.02,0.02,0.02,0.02,0.02,0.02,0.016,0.014,0.012,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01], 1),
	\legato, Pseq([4,8], inf),
	\dur, Pseq([4], inf));

k = Pbind(
 \instrument, \moog_chords,
	 \midinote, Pseq([62],inf),
	 \amp, Pshuf([1,2], inf),
	 \mod, Prand([0.5], inf),
	 \stal, Prand([0,70,0,20,0],inf),
	 \sus, 4,
	\ampli, 0.02,
	\legato, Pseq([4,8], inf),
	\dur, Pseq([4], inf));

// Drums

l   = Pbind(
	\instrument, \hihat,
	\midinote, Pseq([ \rest, 60], inf),
	\sustain, 0.1,
	\amp, Pshuf([0.3, 0.15], inf),
	\dur, 0.5);

m = Pbind(
	\instrument, \snare,
	\dur, Pseq([Rest(1), 1], inf),
	\att, 0.01,
	\rel, 0.1,
	\sinfreq, 180,
	\ffreq, 2000,
	\amp, 0.25);

n = Pbind(
	\instrument, \kick,
	\midinote, Pseq([25], inf),
	\sustain, 0.1,
	\amp, 0.6,
	\dur, Pseq([2, 0.25, 1.75], inf));

// Bass
o  = Pbind(
	\instrument, \moog_basss,
	\midinote, Pseq([26, 28, 29, 31, 32, 34, 35,37], inf),
	\amp, Pshuf([0.1], inf),
	\ampli, 0.2,
	\mod, 1.90,
	\dur, Pshuf([2], inf));

q = Pbind(
	\instrument, \strijker,
	\freq, Pseq([297,592],inf),
	\amp, Pshuf([0.08], inf),
\dur,  Prand([16],inf));




Ptpar([1.0, i,9.0, a,9.25, b,9.50, c,9.75, d,10, e,10.25, f,10.5, g,10.75, h, 15.0, p, 11.0,j,64,k, 48.1, l, 48.1, m, 48.1, n, 56, o, 71, q, 66.0, p,74, a,80.50, b,82.50, c,84.75, d,86, e,79.25, f,79.5, g,79.75, h,], 1).play;
)

s.quit
