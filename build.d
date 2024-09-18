#!/usr/bin/env rdmd

import std.array : split;
import std.process : spawnProcess, wait;

void main() {
    "dmd -betterC -boundscheck=off -run platform/main_windows".split.spawnProcess.wait;
}
