#! /usr/bin/env bash
set -uvx
set -e
find . -name "*.g.dart" -exec rm -rfv {} \;
dart run build_runner build
