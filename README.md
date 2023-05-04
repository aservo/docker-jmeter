Docker JMeter
==============

A JMeter image packaged with the JMeter plugins manager plus initialized plugins. These are
- JPGC Dummy Sampler
- JPGC Basic Graphs
- JPGC Parameterized Controllers
- JPGC Functions
- JPGC Webdriver 
- Prometheus Listener

> Notes
> - The entrypoint script evaluates the run results and returns 0 for successful runs and 1 if any errors occurred.
> - JMeter provides an out-of-the-box feature to build html reports for performance tests by using the `-e -o ${R_DIR}` args.
> In order to produce html results for functional tests pass the variable XML_REPORT_PATH to trigger JMeter 
> XML report to HTML conversion and make sure this xml report gets generated in your testplan, then pass e.g. `-JXML_REPORT_PATH=report/test-report.xml`
> 

Example call

`docker run -i -v ${PWD}:${PWD} -w ${PWD} aservo/jmeter:5.5 -n -t ./tests/Demo.jmx -JXML_REPORT_PATH=reports/demo.xml`

## Links

* JMeter: https://jmeter.apache.org/
* JMeter Plugins: https://jmeter-plugins.org/
* JMeter Prometheus Plugin: https://github.com/johrstrom/jmeter-prometheus-plugin