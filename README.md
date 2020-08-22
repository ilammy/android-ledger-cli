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

## Why is this so complicated?

Because Android and C++ want you to suffer.
If you want to read more technical details and rants,
please go to [BUILDING.md](BUILDING.md).

## License

The end result is distributed under [GNU GPL v3 or later](LICENSE).

Actually, it's more complicated.
Ledger itself is licensed under BSD-style license.
However, the binary includes more than just Ledger:
it's also _statically_ linked with a number of libraries.

  - [Boost] uses Boost Software License. 
  - [GNU MP] uses GNU LGPL v3 (or GNU GPL v2).
  - [GNU MPFR] uses GNU LGPL v3 as well.
  - Whatever Android toolchain links into C/C++ binaries.

[Boost]: https://www.boost.org/
[GNU MP]: https://gmplib.org/
[GNU MPFR]: https://www.mpfr.org/

Build scripts in this repository are distributed under [MIT license](LICENSE.MIT).
That is everything not in a Git submodule.
