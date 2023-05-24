#!/bin/bash

# Inspired from https://github.com/hhcordero/docker-jmeter-client
# Basically runs jmeter, assuming the PATH is set to point to JMeter bin-dir (see Dockerfile)
#
# This script expects the standard JMeter command parameters.
# See https://jmeter.apache.org/usermanual/get-started.html#non_gui for details

set -e
set -o pipefail

# Store arguments to pass to JMeter in a JMETER_ARGS variable
JMETER_ARGS=$@

# If JVM_ARGS environment variable is not set, set it to default value
if [ -z "${JVM_ARGS}" ]
then
  MEM_FREE=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
  MEM_N=$((${MEM_FREE}/10*2))
  MEM_S=$((${MEM_FREE}/10*8))
  MEM_X=$((${MEM_FREE}/10*8))
  JVM_ARGS="-Xmn${MEM_N}m -Xms${MEM_S}m -Xmx${MEM_X}m"
  export JVM_ARGS
fi

echo "JMETER_ARGS=${JMETER_ARGS}"
echo "JVM_ARGS=${JVM_ARGS}"
echo ""
echo "START Running JMeter on `date`"
echo ""

# Pass JMETER_ARGS and redirect stdout and stderr to file to check whether the test was successful
jmeter ${JMETER_ARGS} 2>&1 | tee output.log

echo ""
echo "END Running JMeter on `date`"
echo ""

# If JMETER_ARGS contain '--' option (like for version or help), exit without checking the output
if [[ ${JMETER_ARGS} == *--* ]]
then
  exit 0
fi

# If JMETER_ARGS contain '-j' option, output the log file passed to '-j' option, else output the default log file
echo "JMeter log file:"
if [[ ${JMETER_ARGS} == *-j* ]]
then
  cat $(echo ${JMETER_ARGS} | sed s/.*-j// | cut -d " " -f 2)
else
  cat jmeter.log
fi

echo ""

# Evaluate JMeter process output
if grep -q -E 'Err:.+[1-9]\W\(' output.log
then
  echo "RESULT: test failed :-( - return code 1"
  exit 1
else
  echo "RESULT: test suceeded :-) - return code 0"
fi
