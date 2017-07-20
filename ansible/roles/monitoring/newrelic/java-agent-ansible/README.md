Newrelic Java Agent
===================

This role downloads Newrelic jvm agent and configures it.
The `newrelic_license_key` variable must be defined.

Ad this role to the server that has a java app, then add an agent parameter:
`java -javaagent:/opt/newrelic/newrelic-agent-{{ newrelic_java_agent_version }}.jar -jar your-app.jar`

License
---

The project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

---
