// Thu 23 May 2013  9:16 AM EEST

// Post array of available audio i/o devices:
ServerOptions.devices;

// From the above array choose the name of the multichannel card that you want to use
// and insert it in double quotes in the code below:
// For example:

// Use M-Audio ProFire 610 card for sound I/O:
Server.default.options.device = "ProFire 610";


// This version can be put in the startup file startup.scd in folder Application Support/SuperCollider
// The following routine (fork) is put in the startup file to start playing as soon as SC boot
{
	1.wait;
// This is for using a custom sound card (for multichannel etc.):
 	Server.default.options.device = "ProFire 610";
	3.wait;
	~installation.value;

}.fork(AppClock);
