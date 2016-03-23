#!/bin/sh

export ROOT_DIR=$(dirname $(readlink -f $0))
export CONFIG_DIR=$ROOT_DIR/configs
export SCRIPT_DIR=$ROOT_DIR/scripts
export VENDOR_DIR=$ROOT_DIR/vendor
export TESTS_DIR=$ROOT_DIR/tests

tests_failed=0
tests_passed=0

for dir in $TESTS_DIR/*/; do
	cd $dir
	for file in ./*.test; do
		echo "************************************************************"
		echo "***** Running test: $(basename $file)"
		echo "************************************************************"
		chmod +x $file
		$file
		if [ $? = 0 ]; then
			tests_passed=$(expr $tests_passed + 1)
		else
			tests_failed=$(expr $tests_failed + 1)
		fi
		echo "***** Test complete!"
		echo
	done
done

echo "***** Done running tests!"
echo "Tests passed: $tests_passed"
echo "Tests failed: $tests_failed"
