# adonis-cross-compile

AdonisJS is a laravel-style MVC framework for nodejs. This little helper script is created to cross-compile and run it on Android device. The cross-compile is only needed if any native node module is included, e.g. tiny websocket, sqlite3 etc.

## Getting start

### Prerequisite

Nodejs and node native modules use Android NDK for cross-compile, so Android NDK is required to be installed.

### How it works

For native node modules, a binding.gyp file would exist and it defines the rules used by node-gyp/node-pre-gyp for module compilation. This script will search for this file under the node_modules directory and invokes the node-pre-gyp tool for cross-compiling.

### An example

Below gives an example to cross-comile adonis-admin:

```
$ git clone https://github.com/spiesolo/adonis-cross-compile
$ git clone https://github.com/adonis-china/adonis-admin
$ cd adonis-admin
$ npm install git+https://github.com/spiesolo/uWebSockets
$ npm install
$ cp ../adonis-cross-compile/Makefile .
$ make ARCH=arm
NDK toolchain path: /home/xxxxxx/Android/android-ndk-r14b
Android platform SDK API: 17
HOST_OS=linux
HOST_EXE=
HOST_ARCH=x86_64
HOST_TAG=linux-x86_64
HOST_NUM_CPUS=4
BUILD_NUM_CPUS=8
Toolchain installed to android-toolchain.
```

The script will ask for Android NDK path and Android platform SDK API to be used with in command line prompt.

## Limitations

As node-pre-gyp is used for the cross-compile, it is required the support to it in native node modules.

