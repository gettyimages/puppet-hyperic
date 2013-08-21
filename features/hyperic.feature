Feature: hyperic
  As a devops-y sysadmin
  I want a hyperic agent installed on my nodes
  So I can be the envy of all my peers

Scenario: Provision a hyperic agent
  Given a centos6 machine
  When I apply the hyperic module
#Then wishes should come true
