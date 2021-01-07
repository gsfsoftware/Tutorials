these files are originally from:
http://www.greatwebdivide.com/files/pbservice.zip

This is a sample of a service application that will
dual compile as either a service or a console application
(see the %COMPILE_AS_SERVICE equate).

The service functionality is wrapped up in pb_srvc.inc
A sample application is provided: sserv.bas
This application does absolutely nothing except install
and eat CPU cycles.

To install the sample application run:
sserv.exe -install
on the command line

To start the service:
go to the services applet in the control panel and find
"Your Service Display Name" in the list. Highlight it and
click the "run" button.

To stop it:
Find it again and click the "stop" button

To uninstall:
Close the services applet if running
Get to a command line and execute:
sserv.exe -uninstall


--Don Dickinson
don@greatwebdivide.com
