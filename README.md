Erlang markdown blog engine
===============

[EHE](https://github.com/joearms/adapter_pattern) usage example.
View the example at [http://simpler.herokuapp.com/index.ehe](http://simpler.herokuapp.com/index.ehe)

Download
-----------

    git clone git://github.com/StepanKuzmin/simple.git

Install
-------

    cd simple
    rebar get-deps
    rebar compile

Usage
-----

    erl -pa ebin deps/*/ebin -noshell -s simple_app

View the site at [http://localhost:1234/index.ehe](http://localhost:1234/index.ehe)
