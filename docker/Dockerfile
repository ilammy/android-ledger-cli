# Build environment for Ledger CLI for Android
#
# We use Debian 9 because that's the last version supporting Java 8.
# Google is too busy to add support of modern Java for Android SDK
# so we have to use oldoldstable. Though it doesn't really matter.
FROM debian:9

# Setup basic system dependencies. This is what I'd like to have handy
# in the system image, and what's necessary to kickstart the build.
RUN apt update && apt install --yes --no-install-recommends \
        sudo curl wget unzip git nano \
        build-essential ninja-build openjdk-8-jdk && \
    apt --yes autoremove && \
    apt --yes clean && \
    rm -rf /var/lib/apt/lists/*

# Create a user account to perform actual builds. It will have sudo
# privileges without a password if necessary, but the rest of the build
# is going to be performed as a regular user, as you should always do.
RUN useradd --groups sudo --create-home --shell /bin/bash user && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER user
WORKDIR /home/user

# Download Android SDK tools
# See https://developer.android.com/studio/#downloads
# You agree to follow the terms and conditions outlined on that site
RUN wget -O ~/sdk-tools-linux.zip \
      https://dl.google.com/android/repository/commandlinetools-linux-6514223_latest.zip && \
    test $(shasum --algorithm 256 ~/sdk-tools-linux.zip | awk '{print $1}') \
       = "ef319a5afdb41822cb1c88d93bc7c23b0af4fc670abca89ff0346ee6688da797" && \
    mkdir -p ~/android-sdk/cmdline-tools && \
    cd ~/android-sdk/cmdline-tools && \
    unzip ~/sdk-tools-linux.zip && \
    rm ~/sdk-tools-linux.zip
ENV ANDROID_HOME=/home/user/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/tools/bin:$ANDROID_HOME/platform-tools

# Setup Android SDK and NDK
# We need a particular NDK version to compile Boost
RUN yes | sdkmanager --licenses && \
    sdkmanager \
        'build-tools;28.0.3' \
        'cmake;3.6.4111459' \
        'ndk;20.0.5594570' \
        'platforms;android-28' \
        'platform-tools'
