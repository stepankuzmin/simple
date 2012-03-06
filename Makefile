.SUFFIXES: .erl .beam .yrl

MODS := $(wildcard *.erl)

%.beam: %.erl
	erlc  -W $< 

misultin: beam
	erl -noshell -s simple start misultin_adapter

cowboy: beam
	erl -noshell -s simple start cowboy_adapter

mochiweb: beam
	erl -noshell -s simple start mochiweb_adapter

beam: ${MODS:%.erl=%.beam}

clean:
	rm -rf *.beam *~ erl_crash.dump 
