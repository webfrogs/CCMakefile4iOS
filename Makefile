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

define AppDisplayName
$(shell $(PlistBuddyPath) -c 'print CFBundleDisplayName' $(CompileOutputPath)/*.app/Info.plist)
endef

define AppBuildVersion
$(shell $(PlistBuddyPath) -c 'print CFBundleVersion' $(CompileOutputPath)/*.app/Info.plist)
endef

define AppBuildIdentifier
$(shell $(PlistBuddyPath) -c 'print CFBundleIdentifier' $(CompileOutputPath)/*.app/Info.plist)
endef

define UploadPlistName
$(shell $(PlistBuddyPath) -c 'print CFBundleName' $(CompileOutputPath)/*.app/Info.plist).plist
endef

UploadLogoName = logo.png

UploadPlistPath = $(UploadPath)/$(UploadPlistName)

ItemsURL = itms-services://?action=download-manifest&url=$(BaseURL)/$(UploadPlistName)

define html
'<!DOCTYPE HTML>\
<html>\
  <head>\
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />\
    <title>安装此软件</title>\
  </head>\
  <body>\
	<br>\
	<br>\
	<br>\
	<br>\
	<p align=center>\
		<font size="8">\
			<a href="$(ItemsURL)">点击这里安装</a>\
		</font>\
	</p>\
    </div>\
  </body>\
</html>'
endef


all : package uploadFiles
.PHONY : all compile package uploadFiles plist

compile :
	@echo "Start building project."
	@xcodebuild -configuration $(Configuration) CONFIGURATION_BUILD_DIR=$(CompileOutputPath)

package : compile
	@echo "Start packaging."
	@xcrun -sdk iphoneos PackageApplication -v $(CompileOutputPath)/*.app -o $(WorkPath)/$(AppDisplayName).ipa

uploadFiles : plist
	@cp $(WorkPath)/*.ipa $(UploadPath)/$(AppDisplayName).ipa
	@-cp Icon@2x.png  $(UploadPath)/$(UploadLogoName)
	@echo $(html) > $(UploadPath)/index.html


plist :
	@rm -rf $(UploadPath)
	@mkdir $(UploadPath)
	@$(PlistBuddyPath) -c "Add :items array" $(UploadPlistPath) $2>/dev/null
	@$(PlistBuddyPath) -c "Add :items:0 dict" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets array" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:0 dict" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:assets:0:url string \"$(BaseURL)/$(AppDisplayName).ipa\"" $(UploadPlistPath)
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
	@$(PlistBuddyPath) -c "Add :items:0:metadata:title string \"$(AppDisplayName)\"" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:metadata:kind string software" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:metadata:bundle-version string \"$(AppBuildVersion)\"" $(UploadPlistPath)
	@$(PlistBuddyPath) -c "Add :items:0:metadata:bundle-identifier string \"$(AppBuildIdentifier)\"" $(UploadPlistPath)
	


.PHONY : clean
clean : 
	@xcodebuild clean
	@rm -rf $(WorkPath)
