#!/bin/bash

# BeagleBone automatic tester
# 
# This script should run automatically during init and run a setup of sub tasks
# each of which will test a specific component of the board.
# It is expected to be run with the board plugged into the test board.
# Test results should be displayed and/or reported to the testboard through GPIO

BONETESTER_DIR=/var/lib/bone-tester/
COMPONENT_DIR=${BONETESTER_DIR}/component/

run_test() {
	if [ -z "$1" ] ; then
		echo "run_test: Missing parameter"
		return 1
	fi
	$COMPONENT_DIR/$1.sh
}

run_tests() {
	run_led_command round_robin
	for test in $* ; do
		run_test $test
		run_led_command stop_led_function
		if [ $? -ne 0 ] ; then
			echo "TEST FAILED: $test"
			run_led_command flash_all
			return $?
		fi
	done
	run_led_command turn_on_all
	echo "All tests succeeded"
}

function run_led_command() {
	${BONETESTER_DIR}/lib/leds.sh $1 &
}

run_tests \
	usb_loopback \
	ethernet
