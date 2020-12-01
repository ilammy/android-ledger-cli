ledger_wrap
===========

This directory contains an “insulation wrapper library” of Ledger.
That is, it wraps the original Ledger C++ API to insulate the rest of the project from Boost.

Including Boost – for multiple architectures to boot – pretty much paralyzes Android Studio each time you have to open the project.
Since this is not a typical use case, Android Studio does not offer any help with that and the solution is to just deal with it.
So we do just that: the original Ledger-with-Boost is quarantined in this separate project.
That way we can keep that template cancer contained and slightly reduce developer suffering.
