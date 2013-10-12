/* IZ Wed 05 June 2013 10:03 PM EEST
Packaging Narcissus installation procedures in a class for easier editing and automatic startup.

Narcissus.start;
Narcissus.loadBufferPath;
Narcissus.bufferPath;

*/

Narcissus {
	classvar <>cccPort = 3333; // Make sure that this is the port that Community Core Vision is sending to
	classvar <cccTest;
	classvar <bufferPath, <>buffer, <synth;
	classvar <>rect, <blobWatcher;
	classvar <>rate_spec;

	*initClass { // Make Narcissus start whenever the Library is recompiled
//		StartUp add: { this.start }
	}

	*start {
		this.initRect;
		this.setRateSpec;
		bufferPath = this.loadBufferPath;
		if (bufferPath.size == 0) {
			Dialog.openPanel({ | path |
				bufferPath = path;
				this.saveBufferPath;
				this.startServerAndEnable;
			})
		}{
			this.startServerAndEnable;
		}
	}

	*initRect {
		rect ?? { rect =  Rect(0.1, 0.1, 0.93, 0.93); };
	}

	*setRateSpec { | min = 0.7, max = 1.3 |
		rate_spec = ControlSpec(min, max);
	}

	*loadBufferPath {
		^this.bufferPathPath.load;
	}

	*bufferPathPath {
		^Platform.userAppSupportDir +/+ "narcissus_buffer.scd";
	}

	*saveBufferPath {
		File(this.bufferPathPath, "w").putString(bufferPath.asCompileString).close;
	}

	*startServerAndEnable {
		Server.default.waitForBoot({
			this.loadSynthDefs;
			0.5.wait;
			this.loadBuffers;
			1.wait;
			this.enable;
		});
	}

	*loadSynthDefs {
		(PathName(this.filenameSymbol.asString).pathOnly +/+ "NarcissusSynthDefs.scd").load;
	}

	*loadBuffers {
		buffer = Buffer.read(Server.default, bufferPath);
	}

	*enable {
		blobWatcher ?? { this.makeBlobWatcher };
		blobWatcher.enable;
	}

	*makeBlobWatcher {
		blobWatcher = BlobWatcher(
			{ | blob |
//				postf("new blob at %\n", (blob.x_pos@blob.y_pos));
				if (synth.isNil and: { rect.containsPoint((blob.x_pos@blob.y_pos)) }) {
						"MAKING NEW SYNTH".postln;
						synth = Synth('playbufmagabove', [buf: buffer, attack: 1, release: 3, startPos: blob.x_pos,
						rate: this calcRate: blob.x_pos, magabove: blob.y_pos * 15, pos: blob.width * 10,
						magabovelag: 2,
						amp: 0.7
					])
				}
			},
			{ | blob |
//				postf("blob moved to: %\n", (blob.x_pos@blob.y_pos));
				synth !? { synth.set(\rate, this calcRate: blob.x_pos, \magabove, blob.y_pos * 15, \pos, blob.width * 10) }
			},
			{ | blob |
//				postf("blob died: %\n", (blob.x_pos@blob.y_pos));
				synth !? {
					if (blob.blobs.detect({ | b | rect.containsPoint(b.x_pos@b.y_pos) }).isNil) {
							"STOPPING SYNTH".postln;
							synth.release; synth = nil
						}
				};
			},
		port: cccPort;
		)
	}

	*calcRate { | rate | ^rate_spec.map(rate) }

	*disable { blobWatcher !? { blobWatcher.disable } }

	// preliminary tests to see if OSC is being received from CCC application
	*startCCCtest {
		cccTest ?? { cccTest = OSCFunc({ | ... args | "KINECT! ".post; args.postln }, '/tuio/2Dcur', recvPort: cccPort); };
		cccTest.enable;
	}

	*stopCCCtest { cccTest !? { cccTest.disable } }
}

// The following routine (fork) is put in the startup file to start playing as soon as SC boots:
/*
// This is for using a custom sound card (for multichannel etc.):
// 	Server.default.options.device = "ProFire 610";
*/


