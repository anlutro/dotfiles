#!/bin/sh

assert_equals() {
	local expected="$1" && shift
	local actual="$1" && shift
	if [ "$expected" != "$actual" ]; then
		if [ "$*" ]; then
			echo "Assertion failed! $*"
		else
			echo "Assertion failed!"
		fi
		echo "  EXPECTED: $expected"
		echo "    ACTUAL: $actual"
		exit 1
	fi
}

assert_test() {
	test "$@"
	if [ $? != 0 ]; then
		echo "Test failed: [ $@ ]"
		exit 1
	fi
}
