
~receptionTests = {
	"STARTING KINECT AND WEBCAM RECEPTION POSTING".postln;

	~kinect = OSCFunc({ | ... args | "KINECT! ".post; args.postln }, '/tuio/2Dcur', recvPort: 3001); // used to be 3333
	~webcam = OSCFunc({ | ... args | "WEBCAM! ".post; args.postln }, '/tuio/2Dcur', recvPort: 3333); // used to be 3001

	~kinect.enable;
	~webcam.enable;

	~startCamPost = { ~kinect.enable; ~webcam.enable };
	~stopCamPost = { ~kinect.disable; ~webcam.disable };

};

/*
// Create the reception tests (this also enables posting automatically):
~receptionTests.value;

// Enable posting webcam and kinect:
~startCamPost.value

// Disable posting webcam and kinect:
~stopCamPost.value

*/

~installation = {
	var b0 = 'swallows10minL'.b;
	var synth, rect;
	rect = Rect(0.1, 0.1, 0.93, 0.93);

	~simpleBlob = BlobWatcher(
		{ | blob |
			if (synth.isNil and: { rect.containsPoint((blob.x_pos@blob.y_pos)) }) {
				synth = Synth('playbufmagabove', [buf: b0, attack: 1, release: 3, startPos: blob.x_pos,
					rate: blob.x_pos + 0.7, magabove: blob.y_pos * 15, pos: blob.width * 10,
					magabovelag: 2,
					amp: 0.7
				])
			}
		},
		{ | blob | synth.set(\rate, blob.x_pos + 0.7, \magabove, blob.y_pos * 15, \pos, blob.width * 10) },
		{ | blob |
			synth !? {
				if (blob.blobs.detect({ | b | rect.containsPoint(b.x_pos@b.y_pos) }).isNil) { synth.release; synth = nil }
			};
		},
		port: 3001
	).enable;
};


{
	1.wait;
	Server.default.options.device = "ProFire 610";
	3.wait;
	"OPENING DEFAULT SCRIPTLIB".postln;
	ScriptLib.openDefault;
	3.wait;
	~installation.value;

}.fork(AppClock);

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

*/

