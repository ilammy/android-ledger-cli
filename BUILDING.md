Building Ledger
===============

If you are here for the build instructions then just run

```bash
make
```

The resulting AAR will be placed into `ledger/build/outputs/aar/ledger-release.aar`

If after waiting for the build to finish you wonder what the heck is going on,
then please continue reading.

## How to build Ledger

[Ledger](https://github.com/ledger/ledger) is written C++.
This is the moment where you can start weeping as building C++ software is notoriously nontrivial.
In order to make building software easier, many *build systems* exist.
Ledger uses **CMake** for building, a well-known build system.
However, using C++ build systems is notoriously nontrivial.
In order to make them easier to use, many projects use various helpers.
Ledger has its own `acprep` script to setup and configure the build environment.
Unfortunately, those tools tend to break if you wander too far from the intended use case,
so we're not using `acprep` and instead run CMake directly.

To be fair, after the dependencies are set up, actually building Ledger is easy, thanks to CMake.
You only need to run

```bash
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release .. && make
```

However, we need to build Ledger *for Android* which makes matters worse.

## Building native binaries for Android

Android build system in unbelievably, mindfuckingly nontrivial.
You'd better stay away from building the Android system itself unless you are a Google employee.
(Once upon a time I was able to do it. I also know a couple of people who did it as well and kept their sanity.)
Thankfully, we don't need to build the entire system, only a single binary.
For that, [Android NDK](https://developer.android.com/ndk) exists.

The catch here is that while Android runs Linux, it's probably not the distro you're using.
Not only it uses Bionic instead of glibc, but Android also supports more than x86_64 architecture.
This means you will need to cross-compile.
Cross-compiling C++ software is notoriously nontrivial:
that's one of the main reasons for build systems in the first place.
However, thanks to sheer luck, Android NDK has first-class support of CMake, which makes things much easier.
I don't know how hard this would have been if not for those CMake toolchain files.

In fact, we are using **Gradle** build system as we have some Java code to compile as well.
Since we're not veering off too far off from the processed used by Google,
starting up the native build is as easy as writing

```groovy
externalNativeBuild {
    cmake {
        path "CMakeLists.txt"
    }
}
```

in the `build.gradle` file.
After that Gradle picks it up and calls CMake with proper arguments to build the binaries for all supported architectures.

The tricky part here is that Ledger has a bunch of dependencies which are *not* a part of Android NDK.
We need to build those dependencies ourselves, and most of them don't use CMake.

But before we get there...
Excuse me, do you have a minute to talk about our Lord and Savior: reproducible builds?

## Docker images

C/C++ follows UNIX way: the entire system is your IDE.
While other languages keep projects contained to their project files,
C++ expects *the system* to be configured in a particular way for development.
The toolchain should be here, the libraries should be there,
the environment variables need to be set up like that, etc.

Reproducing this setup might be tedious, and I don't to do that with each of my boxes
(some of which are not running Linux in the first place),
and with future CI servers as well.
Moreover, while Ledger build requires a bunch of dependencies,
we don't need to rebuild those dependencies often.
Building them alone takes a considerable amount of time, thanks to cross-compilation for 4 architectures.

**Docker** is a contemporary ~~bandaid~~ approach to these issues.
It allows to have a *reproducible* “golden” image,
with preinstalled build dependencies and prebuilt library dependencies.
Also, since Gradle likes to download approximately a half of the Internet in Java dependencies,
those can be cached as well.

The [`Dockerfile`](docker/Dockerfile) defines the build image.
It is also uploaded to Dockerhub at `ilammy/android-ledger-cli`, but you can rebuild it locally.
The image is used in builds performed by the Makefile.
You can start up an interactive container with it using `make docker-shell`.

## Building dependencies

First of all, we need to identify the dependencies.
[Ledger](https://github.com/ledger/ledger#dependencies) has the following essential ones:

  - Boost
  - GMP (also a dependency of MPFR)
  - MPFR
  - utfcpp (vendored with Ledger)

Others are used for running the tests and providing a better interactive command-line,
but we don't care much for that in a library.

### Boost

Yes, Boost, the cancer of C++.
It tends to metastasize over the entire project shortly after being introduced to any of its parts.
Symptoms include unnatural excitement over templates and generic code,
greatly increased compilation times, and issues when building software.

Builing Boost is a challenge in itself, with its homebrew build system and gazillion of options,
and building it for Android is quite of a challenge too.
Thankfully, Moritz Wundke and a lot of others did most of the heavy lifting,
providing [a build script](https://github.com/moritz-wundke/Boost-for-Android/)
to configure a build script to run the built script to build the Boost.
And, surpisingly, it even works sometimes!
However, only with pretty specific versions of Boost built with specifis version of Android NDK.

After building Boost you also need to ensure CMake sees it.
CMake has a FindBoost.cmake script with it, simplifying this task.
But only specific versions of the script work with specific versions of CMake to find specific versions of Boost.
Oh well, just another day in C++ land.
