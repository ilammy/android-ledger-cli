# Android Ledger-CLI

Here you can find build scripts for compiling [Ledger] for Android platforms.

[Ledger]: https://www.ledger-cli.org/

## How to use

Run the following to build Ledger:

```bash
make
```

The resulting AAR will be placed into `ledger/build/outputs/aar/ledger-release.aar`

Other Makefile targets:

- `make ledger` – build Ledger AAR (the default one)
- `make docker-image` – build base Docker image
- `make clean` – delete all build files
- `make help` – learn more

## Why is this so complicated?

Because Android and C++ want you to suffer.
If you want to read more technical details and rants,
please go to [BUILDING.md](BUILDING.md).

## License

The combined result — Ledger AAR — is distributed under [GNU LGPL v3](LICENSE)
or any later version at your choice.

The reasons for this are complicated.
Ledger itself is licensed under BSD-style license.
However, the binary includes more than just Ledger:
it's also _statically_ linked with a number of libraries.

  - [Boost] uses Boost Software License. 
  - [GNU MP] uses GNU LGPL v3 (or GNU GPL v2).
  - [GNU MPFR] uses GNU LGPL v3 as well.
  - Bionic and libc++ linked into the binary by Android toolchain.

[Boost]: https://www.boost.org/
[GNU MP]: https://gmplib.org/
[GNU MPFR]: https://www.mpfr.org/

Build scripts in this repository are also available under [MIT license](LICENSE.MIT),
if you wish to include and reuse them for building something else.
