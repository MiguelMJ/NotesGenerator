#!/bin/bash
flex -o preprocessor.cpp preprocessor.flex &&
g++ --std=c++11 preprocessor.cpp -o nogpre
flex -o lexer.cpp lexer.flex &&
g++ --std=c++11 lexer.cpp -o noglex
