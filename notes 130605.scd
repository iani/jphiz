
b = Buffer.read(Server.default,
	  path: "/Users/jp/Dropbox/JPH2/SoundSamples/swallows/swallows_clean5am.wav"
    );

b.play
)

Server.killAll;