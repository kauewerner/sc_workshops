//// ============== General interpreter (sclang)
//
// Executing a single line of SC code -> (Shift + Enter)
//
// Execute a block of code (between parenthesis) -> (Ctrl/Cmd + Enter)
//
/*
Longer
comments
with
a
few
text
lines
*/
//// ============== Global variables
//
// single letter lowercase or word begining with tilda + lowercase
a = 3 // (Shift + Enter)
~aGlobalVar = 3 // (Shift + Enter)
//
//// ============== Local variables
//
// [var]: used when defined within blocks of code or functions
(
var localVar = 2; // execution lines within a block are separated by ";"
localVar = localVar + 2;
localVar = localVar - 2;
) // <- Press (Ctrl/Cmd + Enter) at parenthesis or inside block
//
// operations with local variables cannot be carried out outside the block where they were defined
localVar + 2 // -> ERROR: Variable 'localVar' not defined.
//
// operations with global variables can be carried out anywhere in the code
a + 2
~aGlobalVar + 2
//
//// ============== Functions: operations defined within curly brackets
//
// definition of a global function (lowercase single letter like in global variables)
f = {a + 2};
//
// calling a function which returns its last line of code
f.value
//
a // -> value of global variable "a" was altered by global function "f"
//
// definition of a local function inside a code block
(
var localVar = 1;
var localFunc;
localFunc = {localVar + 1};
)
// not possible to call outside the block where it was defined
localFunc.value // -> ERROR: Variable 'localFunc' not defined.
//
// [arg]: adding arguments to a function
(
f = {arg input; // first line in a function is where you add args
	var la = 0;
	la = la + 2;
	la + input; // last line is what it returns
};
)
// calling a function and setting specific arguments
f.value(input:2)
//
//// ============== Arrays []
//
// collection/list of data (objects, things) defined within brackets
~globalArray = [1,2,3,4]
~globalArray[0] // returns the first element in the array (starts at index 0)
//
//// ============== Do loop operator
//
// calls a function {} n times using values of an n-sized array as arguments
(
[0,1,2].do{arg idx;
	(idx + 1).postln // -> prints the result of this line on the Post window
};
)
//
//// ============== Math operators
2 + 2
2 - 2
2 * 2
2.sqrt
sqrt(2)
// check full list at https://doc.sccode.org/Overviews/Operators.html
//
//// ============== Let's boot the server (scsynth!) and make sound !!
//
// Booting -> ctrl/cmd + B
s.boot;
//
// Killing/closing
s.quit;
//
// Monitoring
s.meter; // Input/Output level meters
s.plotTree; // Real time representation of processing blocks running in the server
s.scope; // Output signal oscilloscope
FreqScope.new // real time spectral visualization of output channel signal
//
// Initial check if the server is running/working
//
// White noise generation function with running processing block in the plotTree
{ WhiteNoise.ar(0.05) }.play
// The uppercase term WhiteNoise represents a class of a UGen (Unit Generator) which creates an instance of a sound processing block that runs on the server generating white noise
// UGens can be in the audio rate (.ar) or control rate (.kr)
// The .play in the function block works as a short cut to create a signal processing execution in the server of the operations defined in the function {}
// kill the sound -> Ctrl/Cmd + .
//
//// ============== Server signal generation/processing functions using UGens
//
// Exploring functions with UGens, arguments and variables
//
// Single channel sine wave generation
(
{
	var sig;
	sig = SinOsc.ar(220,mul:0.1);
	Out.ar(0, sig) // default output channel (index 0 is left speaker)
}.play
)
//
// Dual channel sine wave generation
(
{
	var sigL, sigR, amp = 0.1;
	sigL = SinOsc.ar(220,mul:amp);
	sigR = SinOsc.ar(223,mul:amp);
	Out.ar(0, [sigL, sigR]) // it starts at index 0 sets the number of outputs to the next ones (in this case, 2 channel, indexes 0 and 1, which means left and right speaker channels)
}.play
)
// one can also duplicate a signal like -> sigL!2 which means [sigL,sigL]
//
// Control mode
(
{
	var sigL, sigR, freq = 330, amp = 0.1;
	sigL = SinOsc.ar(SinOsc.kr(2,mul:110,add:220),mul:amp); // frequency modulation using a sine wave (.kr)
	sigR = SinOsc.ar(freq,mul:SinOsc.kr(4,mul:0.25,add:0.25)); // amplitude modulation using a sine wave (.kr)
	Out.ar(0, [sigL, sigR]) // it starts at index 0 sets the number of outputs to the next ones (in this case, 2 channel, indexes 0 and 1, which means left and right speaker channels)
}.play
)
//
// Filters
(
// White noise being filtered by a bandpass (left) and lowpass (right), with cutoff frequency modulated by sine wave
{
	var bpf, lpf, amp = 0.1;
	bpf = BPF.ar(
		WhiteNoise.ar(amp), SinOsc.kr(0.2,mul:1800,add:2000));
	lpf = LPF.ar(
		WhiteNoise.ar(amp), SinOsc.kr(0.2,mul:1800,add:2000));
	Out.ar(0, [bpf, lpf])
}.play
)
//
// Additive synthesis (summing up sine waves with different frequencies in a do loop)
(
{
	var sig = 0, freq = 110, amp = 0.01;
	10.do{arg idx;
		sig = sig + SinOsc.ar((idx + 1)*freq,mul:amp)
	};
	Out.ar(0,sig!2)
}.play
)
//
// Envelopes
(
{
	var sig = 0, env, freq = 110, amp = 0.01;
	env = EnvGen.kr(Env.perc,doneAction:2); // doneAction:2 means killing the synth (block) when the envelope is completed
	10.do{ arg idx;
		sig = sig + SinOsc.ar((idx + 1)*freq,mul:amp)
	};
	Out.ar(0,(env*sig)!2)
}.play
)
// envelopes can be plotted
Env.perc(1,4,curve:4).plot;
//
// detailed UGen walkthrough at https://doc.sccode.org/Guides/Tour_of_UGens.html
//
//// ============== SynthDefs and Synths
//
// creating a \test recipe for the server to create Synths with a SynthDef
// arguments can be added to this recipe which can be later controlled in any instance
(
SynthDef.new(\test,
	{
	arg freq = 110, amp = 1, mix = 0.5;
	var sig = 0, env, envFreq;
	env = EnvGen.kr(Env.perc,doneAction:2);
	envFreq = EnvGen.kr(Env.triangle); // envelope added for frequency control
	10.do{ arg idx;
			sig = sig + SinOsc.ar((idx + 1)*freq*(1 + envFreq),mul:0.01)
	};
	sig = FreeVerb.ar(sig,mix,0.8); // basic reverb UGen
	Out.ar(0,(env*amp*sig)!2)
}).add;
//
)
// send a message to the server to create an instance of a specific recipe and set values for specific arguments
Synth(\test, [\freq, 110, \amp, 1.0, \mix, 0.3])
// create a global variable as an instance and set/update arguments at any time
x = Synth(\test);
x.set(\freq,220); // only if the synth is still running (before doneAction finishes)
//
//// ============== Global patterns: Pbindefs
//
// define the global pattern with a name/label (\test_pattern) and set an \instrument (existing SynthDef, \test)
Pbindef(\test_pattern, \instrument, \test);
// set the sequence of note duration in the pattern
Pbindef(\test_pattern, \dur, Pseq([0.1,0.2,0.5,1],inf));
// the Pbindef gets all arguments from the SynthDef used as \instrument, which can then be varied also with specific patterns
(
Pbindef(\test_pattern, [
	\freq, Pgauss(220,100,inf),
	\mix, Pgauss(0.1,0,inf)
])
)
Pbindef(\test_pattern, \mix, Pgauss(0.5,0.25,inf));
// play and stop at any time
Pbindef(\test_pattern).play;
Pbindef(\test_pattern).stop;
//








