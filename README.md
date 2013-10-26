CCMakefile4iOS
==============

This project can help you to distribute your iOS project automatically by the terminal.

![image](http://webfrogs.me/CCRes/images/2013-10-26_make.gif)

##Usage

Copy the ```Makefile``` and ```Makefile.cfg``` files to the root path of your iOS project(the same directory with the *.xcodeproj* file).

Open the ```Makefile.cfg``` file and edit it. Then, you can use the ```make``` command as shown below.

* ```make``` --- compile and package
* ```make upload``` --- upload itms-services files 
* ```make sendEmail``` --- send E-mails notification
* ```make sendIMsg``` --- send iMessage notification


Tip: Use the ```&&``` to combine and run command in sequence. For example: 

```make && make upload && make sendEmail```.

You can do this as you need.





## License
This code is distributed under the terms and conditions of the MIT license.