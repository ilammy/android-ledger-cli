#ifndef LEDGER_WRAP_JOURNAL_H
#define LEDGER_WRAP_JOURNAL_H

#include <string>

#include <ledger_wrap/forward.h>
#include <ledger_wrap/ptr.h>

namespace ledger_wrap
{

// Forward declaration for the benefit of friends.
class journal_ptr;

// We have to declare this first because C++ still pretends to be single-pass.
namespace impl
{

/// Wrapper which forwards methods of `ledger::journal_t*`.
///
/// This one exists for the sake of `operator->` working as expected.
class journal_t : public dumb_t<ledger::journal_t>
{
public:
    // TODO: implement accessor methods

private:
    friend class ledger_wrap::journal_ptr;
};

} // namespace ledger_wrap::impl

/// Dumb pointer equivalent of `ledger::journal_t*`
///
/// Note that it's 'dumb' and does not track ownership or references.
///
/// You are allowed to copy and destroy this pointer as much as you want,
/// this does not affect the object it points to in any way.
class journal_ptr : public impl::dumb_ptr<impl::journal_t>
{
};

} // namespace ledger_wrap

#endif // LEDGER_WRAP_JOURNAL_H
