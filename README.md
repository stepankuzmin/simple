Simple
======

Simple is a markdown blog engine.


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

    erl -pa ebin deps/*/ebin -noshell -s crypto -s inets -s ssl -s mnesia -s simple_app

View the site at [http://localhost:8888](http://localhost:8888)
