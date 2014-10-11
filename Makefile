# The MIT License (MIT)
# Copyright © 2013 Carl Chen.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


include Makefile.cfg

ProjectAbsolutePath = $(shell pwd)

WorkFolder = build

VPATH = $(WorkFolder)

WorkPath = $(ProjectAbsolutePath)/$(WorkFolder)

CompileOutputPath = $(WorkPath)/iPhoneOS

UploadPath = $(WorkPath)/upload

PlistBuddyPath = /usr/libexec/PlistBuddy

Configuration ?= Release

#define InfoPlistFilePath
#$(shell echo $(CompileOutputPath)/*.app/Info.plist)
#endef

InfoClr     = \033[01;33m
ResultClr   = \033[01;32m
ResetClr    = \033[0m

BuildCmdConfig = -configuration $(Configuration) CONFIGURATION_BUILD_DIR=$(CompileOutputPath)

ifneq ($(Scheme),)
BuildCmdConfig += -scheme $(Scheme)
endif

ifneq ($(ProvisioningProfile),)
BuildCmdConfig += PROVISIONING_PROFILE=$(ProvisioningProfile)
endif


define AppDisplayName
$(shell $(PlistBuddyPath) -c 'print CFBundleDisplayName' $(CompileOutputPath)/*.app/Info.plist)
endef

define AppBuildVersion
$(shell $(PlistBuddyPath) -c 'print CFBundleVersion' $(CompileOutputPath)/*.app/Info.plist)
endef

define AppBuildIdentifier
$(shell $(PlistBuddyPath) -c 'print CFBundleIdentifier' $(CompileOutputPath)/*.app/Info.plist)
endef

define AppBundleName
$(shell $(PlistBuddyPath) -c 'print CFBundleName' $(CompileOutputPath)/*.app/Info.plist)
endef

UploadPlistName = $(AppBundleName).plist

UploadLogoName = logo.png

UploadPlistPath = $(UploadPath)/$(UploadPlistName)

ItemsURL = itms-services://?action=download-manifest&url=$(PlistFileHttpsURL)

AppName ?= $(AppDisplayName)

GitLog = $(shell git log --no-merges --pretty=format:"\r✓ %s" --abbrev-commit --date=relative -n 10 | /usr/bin/php -r 'echo htmlentities(fread( STDIN, 2048 ), ENT_QUOTES, "UTF-8");')

define html
'<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">\
<title>$(AppName)</title><style type="text/css">body{text-align:center;font-family:"Helvetica";font-size:13px;}ul{text-align:left;}\
.container{width:300px;margin:0 auto;}h1{margin:0;padding:0;font-size:14px;}.install_button{background-image:-webkit-linear-gradient(top,rgb(126,203,26),rgb(92,149,19));background-origin:padding-box;background-repeat:repeat;-webkit-box-shadow:rgba(0,0,0,0.36) 0px 1px 3px 0px;-webkit-font-smoothing:antialiased;-webkit-user-select:none;background-attachment:scroll;background-clip:border-box;background-color:rgba(0,0,0,0);border-color:#75bc18;border-bottom-left-radius:18px;border-bottom-right-radius:18px;border-bottom-style:none;border-bottom-width:0px;border-left-style:none;border-left-width:0px;border-right-style:none;border-right-width:0px;border-top-left-radius:18px;border-top-right-radius:18px;border-top-style:none;border-top-width:0px;box-shadow:rgba(0,0,0,0.359375) 0px 1px 3px 0px;cursor:pointer;display:inline-block;margin:10px 0;padding:1px;position:relative;-webkit-box-shadow:0 1px 3px rgba(0,0,0,0.36);line-height:50px;margin:.5em auto;}\
.install_button a{-webkit-box-shadow:rgba(255,255,255,0.25) 0px 1px 0px 0px inset;-webkit-font-smoothing:antialiased;-webkit-user-select:none;background-attachment:scroll;background-clip:border-box;background-color:rgba(0,0,0,0);background-image:-webkit-linear-gradient(top,rgb(195,250,123),rgb(134,216,27) 85%%,rgb(180,231,114));background-origin:padding-box;background-repeat:repeat;border-bottom-color:rgb(255,255,255);border-bottom-left-radius:17px;border-bottom-right-radius:17px;border-bottom-style:none;border-bottom-width:0px;border-left-color:rgb(255,255,255);border-left-style:none;border-left-width:0px;border-right-color:rgb(255,255,255);border-right-style:none;border-right-width:0px;border-top-color:rgb(255,255,255);border-top-left-radius:17px;border-top-right-radius:17px;border-top-style:none;border-top-width:0px;box-shadow:rgba(255,255,255,0.246094) 0px 1px 0px 0px inset;color:#fff;cursor:pointer;display:block;font-size:16px;font-weight:bold;height:36px;line-height:36px;margin:0;padding:0;text-decoration:none;text-shadow:rgba(0,0,0,0.527344) 0px 1px 1px;width:278px;}\
.icon{border-radius:10px;box-shadow:1px 2px 3px lightgray;width:57px;height:57px;}\
.release_notes{text-align:left;border:1px solid lightgray;padding:30px 10px 15px 30px;border-radius:8px;overflow:hidden;line-height:1.3em;box-shadow:1px 1px 3px lightgray;}\
.release_notes:before{font-size:10px;content:"Change Log";background:lightgray;margin:-31px;float:left;padding:3px 8px;border-radius:4px 0 6px 0;color:white;}\
footer{font-size:x-small;font-weight:bolder;}</style></head>\
<body><div class="container">\
<p><img class="icon" src="$(BaseURL)/$(UploadLogoName)"/></p>\
<h1>$(AppName)</h1><br/>\
<small>Built on '`date "+%Y-%m-%d %H:%M:%S"`'</small>\
<div class="install_button"><a href="$(ItemsURL)">INSTALL</a></div><br/><br/>\
<pre class="release_notes">$(GitLog)<br/>    ......</pre>\
</body></html>\
'
endef


all : package uploadFiles
.PHONY : all compile package uploadFiles plist sendEmail sendIMsg upload

compile :
	@echo "Start building project."
	@xcodebuild $(BuildCmdConfig)

package : compile
	@echo "Start packaging."
	@xcrun -sdk iphoneos PackageApplication -v $(CompileOutputPath)/*.app -o $(WorkPath)/$(AppBundleName).ipa

uploadFiles : plist
	@cp $(WorkPath)/*.ipa $(UploadPath)/$(AppBundleName).ipa
	@-cp Icon@2x.png  $(UploadPath)/$(UploadLogoName)
	@echo $(html) > $(UploadPath)/index.html


plist :
	@rm -rf $(UploadPath)
	@mkdir $(UploadPath)
	@$(PlistBuddyPath) -c "Add :items array" $(UploadPlistPath) $2>/dev/null
	@$(PlistBuddyPath) -c "Add :items:0 dict" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets array" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:0 dict" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:0:url string \"$(BaseURL)/$(AppBundleName).ipa\"" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:0:kind string software-package" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:1 dict" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:1:kind string display-image" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:1:needs-shine bool NO" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:1:url string \"$(BaseURL)/$(UploadLogoName)\"" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:2 dict" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:2:kind string full-size-image" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:2:needs-shine bool NO" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:2:url string \"$(BaseURL)/$(UploadLogoName)\"" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:metadata dict" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:metadata:title string \"$(AppName)\"" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:metadata:kind string software" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:metadata:bundle-version string \"$(AppBuildVersion)\"" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:metadata:bundle-identifier string \"$(AppBuildIdentifier)\"" $(UploadPlistPath)
	@mv $(UploadPlistPath) $(WorkPath)
	
sendEmail :
	@echo "Sending E-mails..."
	@curl -s --user api:$(MailGunApiKey) \
		https://api.mailgun.net/v2/$(MailGunDomain)/messages \
		-F from='$(AppName) <postmaster@$(MailGunDomain)>' \
		-F to=$(MailGunReceiveList)\
		-F subject="$(AppName) has been updated" \
		-F text='This email is send by automatical shell created by ccf.Do not reply it directly.' \
		-F "html=<$(UploadPath)/index.html"	
	@echo "\nMails sent."

sendIMsg :
	@for address in $(IMsgList) ; do \
		echo "Sending iMessage to $${address}..." ; \
		osascript -e "set toAddress to \"$${address}\"" \
		-e "tell application \"Messages\"" \
		-e "set theBuddy to buddy toAddress of (first service whose service type is iMessage)" \
		-e "send \"$(AppName) has been updated. Click to install: $(BaseURL)/index.html\" to theBuddy" \
		-e "end tell" ; \
	done

upload :
	@echo "Uploading...."

ifneq ($(ScpHost),)
ifneq ($(ScpUser),)
ifneq ($(ScpFilePath),)
	@scp $(UploadPath)/* $(ScpUser)@$(ScpHost):$(ScpFilePath)
endif
endif
endif

ifneq ($(FtpHost),)
ifneq ($(FtpUser),)
ifneq ($(FtpPassword),)
	@cd $(UploadPath); ls -l | awk '/^-/{print $$NF}' | while read filename; do curl -u $(FtpUser):$(FtpPassword) -T $${filename} ftp://$(FtpHost)/$${filename}; done
endif
endif
endif

	@echo "Upload success."

.PHONY : clean
clean : 
	@xcodebuild clean $(BuildCmdConfig)
	@rm -rf $(WorkPath)
