
/*

This was the original file used to run Narcissus in Cyprus/Limassol, November 2012
for the Roadblocks Project.

It is now being modified to run for other locations.

Testing.

Dialog.openPanel({ | path | path.postln; });

*/

// this is to get the exact path output in the post window
Dialog.openPanel({ | path | path.postln; });

/*
Here we create a function that creates some other functions that we need for tests.
The function that makes the functions is stored in ~receptionTests
The functions that it makes will be stored in ~startCamPost, ~stopCampost

To create the functions we need to run ~receptionTests (see below)
*/



/*~receptionTests = {
	"STARTING KINECT AND WEBCAM RECEPTION POSTING".postln;

	~kinect = OSCFunc({ | ... args | "KINECT! ".post; args.postln }, '/tuio/2Dcur', recvPort: 3001); // used to be 3001
	~webcam = OSCFunc({ | ... args | "WEBCAM! ".post; args.postln }, '/tuio/2Dcur', recvPort: 3333); // used to be 3333

	~kinect.enable;
	~webcam.enable;

	~startCamPost = { ~kinect.enable; ~webcam.enable };
	~stopCamPost = { ~kinect.disable; ~webcam.disable };

};
// Create the reception tests (this also enables posting automatically):
~receptionTests.value;

// Enable posting webcam and kinect:
~startCamPost.value

// Disable posting webcam and kinect:
~stopCamPost.value

*/

/*
Here we create a function that we will run to install the narcissus program and activate it.
This function is installed in ~installation. In a later part below, we show how to use ~installation
to start running the system at startup.
*/
(
~installation = {
	var synth; // The synth that plays the swallows sound and processes it.
	var rect;  // When a blob is inside this rect, then the sound plays.
	var b0; // Buffer where the swallows or any other recorded sound is stored
	// This gets the buffer from the preloaded buffers from ScriptLib. If we do not use ScriptLib, then
	// we need to hard-code the path of the buffer:
	// b0 = 'swallows10minL'.b;   // buffer from ScriptLib. We will not use this
	// Instead we hard-code the path of the sound file:
	/* Here is an easy way to get and print the path in SC using a dialog box:

	Dialog.openPanel({ | path | path.postln; });

	After running the above, make sure to copy the path from the post window.
	*/
	// Now we load the sample using the path that we got from the post window:
	b0 = Buffer.read(Server.default,
		// copy-paste here
		// path: "/Users/jp/Dropbox/JPH2/SoundSamples/swallows/swallows10minL.aiff"
		// path: "/Users/jp/Dropbox/JPH2/SoundSamples/poets/MureauCage.aiff"
		path: "/Users/jp/Dropbox/JPH2/SoundSamples/swallows/swallows_clean5am.wav"
	);

	rect = Rect(0.1, 0.1, 0.93, 0.93);

	// BlobWatcher is part of the Narcissus library which is now in Snippets.
	// We create a BlobWatcher with the properties that we want, and then enable it to start playing
	//:playbufmagabove
	{
		/*
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
		SynthDef("playbufmagabove", { | out = 0, buf = 0, rate = 1, startPos = 0, loop = 1, attack = 1,
			release = 1,
			gate = 1, amp = 1,
			magabove = 0, magabovelag = 2,
			pos = 0 |
			var env, envgen, source, chain;
			env = Env.asr(attack, 1, release);
			envgen = EnvGen.kr(env, gate, amp, doneAction: 2);
			source = envgen *
			PlayBuf.ar(buf.numChannels, buf, /* rate */ 1 * BufRateScale.kr(buf), 1,
				/* startPos */ 0 * BufFrames.kr(buf),
				loop,
				doneAction: 2);
			chain = FFT(LocalBuf(2048), source);
			chain = PV_MagAbove(chain, Lag.kr(magabove, magabovelag));
			Out.ar(out, PanAz.ar(4, IFFT(chain), Lag.kr(pos, 5)));
			// Out.ar(out, PanAz.ar(4, source, Lag.kr(pos, 5), width: 2));
			// Out.ar(out, source);
		}).add;
		0.5.wait;   // Make sure that SynthDef has time to be sent to the server
		// Now ready to start the sound process with the BlobWatcher:
		~simpleBlob = BlobWatcher(
            { | blob |
                if (synth.isNil and: { rect.containsPoint((blob.x_pos@blob.y_pos)) }) {
                        synth = Synth('playbufmagabove', [buf: b0, attack: 1, release: 2, startPos: blob.x_pos,
                        rate: blob.x_pos + 0.7, magabove: blob.y_pos * 15, pos: blob.width * 10,
                        magabovelag: 2,
                        amp: 0.7
                    ])
                }
            },
            { | blob | synth !? { synth.set(\rate, blob.x_pos + 0.7, \magabove, blob.y_pos * 15, \pos, blob.width * 10) } },
            { | blob |
                synth !? {
                    if (blob.blobs.detect({ | b | rect.containsPoint(b.x_pos@b.y_pos) }).isNil) {
                            synth.release; synth = nil
                        }
                };
            },
        port: 3333;  // Make sure that this is the port that Community Core Vision is sending to
    ).enable;
	}.fork; // we need to fork this in order for 'wait' to work.
};
}
//

// The following routine (fork) is put in the startup file to start playing as soon as SC boots:
/*
{
	1.wait;
// This is for using a custom sound card (for multichannel etc.):
// 	Server.default.options.device = "ProFire 610";
	3.wait;
//  We do not use ScritpLib in the current version any more:
//	"OPENING DEFAULT SCRIPTLIB".postln;
//	ScriptLib.openDefault;
//	3.wait;
	~installation.value;

}.fork(AppClock);
*/

/*
// To start a program from SuperCollider, using Unix commands:
// Example:

"open \"/Applications/CCV-1.2-mac-bin/Community Core Vision/Community Core Vision.app\"".unixCmd;


/*

~stopCamPost.value;
~startCamPost.value;
~kinect.disable;~stopCamPost.value;

~kinect.disable;

~kinect.enable;

~webcam.enable;

~webcam.disable;

~installation.value;

*/

