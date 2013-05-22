#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

require File.expand_path("../config/boot.rb", __FILE__)

Padrino::Application.default_options.merge!(
    run: false,
    env: production
)

run Padrino.application
