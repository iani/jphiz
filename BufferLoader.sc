/* April 21 2013 */

BufferLoader {
	classvar <libraryPath = 'buffers';
	classvar <>server;

	*initClass {
		StartUp.add({
			server = Server.default;
			server.onBootAdd({ this.reLoadAll });
		});
	}

	*reLoadAll {
		this.allPaths do: { | path | this.createAndStoreBuffer(path) }
	}

	*allPaths {
		var paths;
		paths = Library.at(libraryPath);
		if (paths.isNil) { ^[] };
		^paths.keys.asArray;
	}

	*createAndStoreBuffer { | path |
		var buffer;
		server.waitForBoot({
			buffer = Buffer.read(server, path);
			this.storeBuffer(path, buffer);
		});
		^buffer;
	}

	*storeBuffer { | path, buffer |
		Library.put(path, buffer.asSymbol, buffer);
	}

	*load { | path |
		/* Get the buffer at path, AND if it does not exist, then load it and store it */
		var buffer;
		buffer = this.getBuffer(path);
		if (buffer.isNil) {
			^this.createAndStoreBuffer(path);
		}{
			^buffer;
		}
	}

	*getBuffer { | path |
		/* Get the buffer at path - but do not load it.
		Other methods may do the loading. */
		^Library.at(libraryPath, path.asSymbol);
	}
}

