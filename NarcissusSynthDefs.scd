/* IZ Thu 06 June 2013  2:29 PM EEST
Synthdefs for Narcissus
*/

/* playbufmagabove :
out : output channel
buf : buffer number i.e. which sample is user
rate : rate of playback. 1 = original recording speed, 2 = double speed, -1 = reverse playback etc.
startPos : the position in the sample from which playback starts. 0 = beginning 1 = end of sample
loop: When this is > 0, (usually 1), then the sound sample will loop to the beginning after ending.
(Otherwise it will just stop playing, while the Synth still keeps playing, silently)
attack : attack time used in envelope to smooth fade in (units: seconds)
release : release time used in envelope to smooth fade out
gate : when this changes to 0 then the envelope releases, and the sound fades out, and then the synth stops
amp : value multiplied with output to scale amplitude. 1 = stay as is. 0 = silence
magabove : our fft filter will only let through frequencies that have magnitude above magabove
magabovelag : smoothing factor to prevent jumps in the change of magabove (default: 2)
pos: Position of output of sound in the quad surround channel output. In channels. Read Help file for PanAz
*/
/*
SynthDef("playbufmagabove", { | out = 0, buf = 0, rate = 1, startPos = 0, loop = 1,
	attack = 0.01, release = 1,
	gate = 1, amp = 1,
	magabove = 0, magabovelag = 2,
	pos = 0 |
	var env, envgen, source, chain;
	env = Env.asr(attack, 1, release);
	envgen = EnvGen.kr(env, gate, amp, doneAction: 2);
	source = envgen *
	PlayBuf.ar(buf.numChannels, buf, Lag.kr(rate,3) * BufRateScale.kr(buf), 1,
				startPos * BufFrames.kr(buf),
				loop,
				doneAction: 2);
	chain = FFT(LocalBuf(2048), source);
	chain = PV_MagAbove(chain, Lag.kr(magabove, magabovelag));
	Out.ar(out, PanAz.ar(4, IFFT(chain), Lag.kr(pos, 5), width: 2));
}).add;
*/
SynthDef("playbufmagabove", { | out = 0, buf = 0, rate = 1, startPos = 0, loop = 1,
	attack = 0.01, release = 1,
	gate = 1, amp = 1,
	magabove = 0, magabovelag = 2,
	pos = 0 |
	var env, envgen, source, chain;
//	env = Env.asr(attack, 1, release); // no release possible when 'release' is a Control instance
	env = Env.asr(attack, 1, 3);

	envgen = EnvGen.kr(env, gate, 1, doneAction: 2);
	source = envgen * PlayBuf.ar(
		buf.numChannels, buf, Lag.kr(rate,3) * BufRateScale.kr(buf), 1,
		startPos * BufFrames.kr(buf), loop, doneAction: 2
	);
	chain = FFT(LocalBuf(2048), source);
	chain = PV_MagAbove(chain, Lag.kr(magabove, magabovelag));
	Out.ar(out, PanAz.ar(4, IFFT(chain), Lag.kr(pos, 5), level: amp, width: 2));
}).add;


