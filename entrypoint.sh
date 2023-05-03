#!/bin/bash

# Inspired from https://github.com/hhcordero/docker-jmeter-client
# Basically runs jmeter, assuming the PATH is set to point to JMeter bin-dir (see Dockerfile)
#
# This script expects the standard JMeter command parameters.

set -e
set -o pipefail

freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

echo "START Running Jmeter on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
echo "JMeter args=$@"

# Pass JMeter arguments and redirect stdout and err to file for checking whether or not the test was successful
jmeter $@ 2>&1 | tee jmeter-output
echo "END Running Jmeter on `date`"

# Evaluate jmeter process output
if grep -q -E 'Err:.+[1-9]\W\(' jmeter-output
then
  echo "RESULT: test failed :-( - return code 1"
  exit 1
else
  echo "RESULT: test suceeded :-) - return code 0"
fi
