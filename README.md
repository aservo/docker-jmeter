Docker JMeter
==============

A JMeter image packaged with the JMeter plugins manager plus initialized plugins. These are
- JPGC Dummy Sampler
- JPGC Basic Graphs
- JPGC Parameterized Controllers
- JPGC Functions
- JPGC Webdriver 
- Prometheus Listener

> Note: The entrypoint script evaluates the run results and returns 0 for successful runs and 1 if any errors occurred. 

## Links

* JMeter: https://jmeter.apache.org/
* JMeter Plugins: https://jmeter-plugins.org/
* JMeter Prometheus Plugin: https://github.com/johrstrom/jmeter-prometheus-plugin