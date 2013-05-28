b = Buffer.read(Server.default,
        path: "/Users/jp/Dropbox/JPH2/SoundSamples/swallows/swallows10minL.aiff"
)

b.play;.

b = Buffer.read(Server.default,
        path: "/Users/jp/Dropbox/JPH2/SoundSamples/swallows/swallows.wav"
)

b.play;

b.inspect;
b.updateInfo;

a = Synth("playbufmagabove", [\buf, b]);

Dialog.openPanel({ | path | path.postln; });