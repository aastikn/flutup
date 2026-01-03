Step 2 : Prerequisite check

-  Make sure to have these
  - bash mkdir file rm which
  - to install:
  - curl git unzip xz zip glu ninja
  - make sure it's updated

Step 2: Java

- download openjdk, usually we give the user a choice bw 17,21 and other supported versions but defaulkt to 17
- we can do sudo pacman -S jre17-openjdk jdk17-openjdk
- 


Step 3 : Flutter

- Download flutter from "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.38.5-stable.tar.xz"
- store it in /home/<user>/src folder
- echo 'export PATH="/home/<user>/src/flutter/bin/:$PATH"' >> bashrc

Step 3.5 : Android Sdk

- download cmdline tools

- download gradle as well

- tree output: 

- ~/src ❯ tree -L 1
  .
  ├── androidtool
  ├── build-tools
  ├── cmdline-tools
  ├── emulator
  ├── flutter
  ├── jdk-17.0.12
  ├── licenses
  ├── platforms
  ├── platform-tools
  └── tools

  11 directories, 0 files

  ~/src ❯ tree -L 2
  .
  ├── androidtool
  │   └── gradle-9.2.0
  ├── build-tools
  │   └── 36.1.0
  ├── cmdline-tools
  │   └── latest
  ├── emulator
  │   ├── android-info.txt
  │   ├── bin64
  │   ├── crashpad_handler
  │   ├── crashreport
  │   ├── emulator
  │   ├── emulator-check
  │   ├── include
  │   ├── lib
  │   ├── lib64
  │   ├── LICENSE
  │   ├── mksdcard
  │   ├── netsimd
  │   ├── nimble_bridge
  │   ├── NOTICE.csv
  │   ├── NOTICE.txt
  │   ├── package.xml
  │   ├── qemu
  │   ├── qemu-img
  │   ├── qsn
  │   ├── resources
  │   └── source.properties
  ├── flutter
  │   ├── analysis_options.yaml
  │   ├── AUTHORS
  │   ├── bin
  │   ├── buildtools
  │   ├── CHANGELOG.md
  │   ├── CODE_OF_CONDUCT.md
  │   ├── CODEOWNERS
  │   ├── CONTRIBUTING.md
  │   ├── dartdoc_options.yaml
  │   ├── DEPS
  │   ├── dev
  │   ├── docs
  │   ├── engine
  │   ├── examples
  │   ├── flutter_console.bat
  │   ├── flutter_root.iml
  │   ├── LICENSE
  │   ├── packages
  │   ├── PATENT_GRANT
  │   ├── pubspec.lock
  │   ├── pubspec.yaml
  │   ├── README.md
  │   ├── TESTOWNERS
  │   └── third_party
  ├── jdk-17.0.12
  │   ├── bin
  │   ├── conf
  │   ├── include
  │   ├── jmods
  │   ├── legal
  │   ├── lib
  │   ├── LICENSE -> legal/java.base/LICENSE
  │   ├── man
  │   ├── README
  │   └── release
  ├── licenses
  │   ├── android-googletv-license
  │   ├── android-googlexr-license
  │   ├── android-sdk-arm-dbt-license
  │   ├── android-sdk-license
  │   ├── android-sdk-preview-license
  │   ├── google-gdk-license
  │   └── mips-android-sysimage-license
  ├── platforms
  │   └── android-36
  ├── platform-tools
  │   ├── adb
  │   ├── etc1tool
  │   ├── fastboot
  │   ├── hprof-conv
  │   ├── lib64
  │   ├── make_f2fs
  │   ├── make_f2fs_casefold
  │   ├── mke2fs
  │   ├── mke2fs.conf
  │   ├── NOTICE.txt
  │   ├── package.xml
  │   ├── source.properties
  │   └── sqlite3
  └── tools
      ├── android
      ├── bin
      ├── emulator
      ├── emulator-check
      ├── lib
      ├── mksdcard
      ├── monitor
      ├── NOTICE.txt
      ├── package.xml
      ├── proguard
      ├── source.properties
      └── support

  41 directories, 61 files

- extract them to /home/<user>/src/cmdline-tools/latest

- set android home to src and path to src/cmdline-tools

- export GRADLE=/home/sadmin/Desktop/Applications/androidtool/Gradle export PATH=$GRADLE/bin:$PATH  export ANDROID_HOME=/home/sadmin/Desktop/Applications/androidtool/sdk export PATH=$ANDROID_HOME/cmdline-tools/tools/bin:$PATH export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/platforms:$PATH 

- sdkmanager --update sdkmanager --list find current version sdkmanager --list | grep build-tools =--sdkmanager "build-tools;x.y.z" "platform-tools" "platforms;android-x" "tools" sdkmanager --licenses

