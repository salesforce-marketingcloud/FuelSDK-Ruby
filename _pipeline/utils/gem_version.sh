#!/bin/bash

GEMSPEC=$1

ruby -e "puts eval(File.read('$GEMSPEC'), TOPLEVEL_BINDING).version.to_s"
