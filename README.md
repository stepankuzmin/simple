Simple
===============

Simple is a markdown blog engine.

Build with [EHE and adapter_pattern](https://github.com/joearms/adapter_pattern) by Joe Armstrong, [erlang-yaml](https://github.com/bobsh/erlang-yaml) by bobsh and [erlmarkdown](https://github.com/gordonguthrie/erlmarkdown) by Gordon Guthrie.

View the Simple usage example at [simpler.herokuapp.com](http://simpler.herokuapp.com)

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

View the site at [http://localhost:1234](http://localhost:1234)
