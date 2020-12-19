#ifndef LEDGER_WRAP_SESSION_H
#define LEDGER_WRAP_SESSION_H

#include <string>

#include <ledger_wrap/forward.h>
#include <ledger_wrap/journal.h>

namespace ledger_wrap
{

// Forward declaration for the benefit of friends.
class session_ptr;

// We have to declare this first because C++ still pretends to be single-pass.
namespace impl
{

/// Wrapper which forwards methods of `ledger::session_t*`.
///
/// This one exists for the sake of `operator->` working as expected.
class session_t
{
    ledger::session_t *session;

public:
    /// Reads journal data into this session from given string.
    ///
    /// This invalidates all previously obtained accessors into journal data.
    session_t& read_journal_from_string(const std::string &data);

    /// Returns journal object of this session.
    ///
    /// Returned object is invalidated on any modifications to the session.
    journal_ptr get_journal();

private:
    friend class ledger_wrap::session_ptr;

    explicit session_t(ledger::session_t *session) noexcept
      : session(session)
    {
    }
};

} // namespace ledger_wrap::impl

/// Dumb pointer equivalent of `ledger::session_t*`
///
/// Note that it's 'dumb' and does not track ownership or references.
/// You need to manage the memory manually via `make()` and `free()`.
///
/// You are allowed to copy and destroy this pointer as much as you want,
/// this does not affect the object it points to in any way.
class session_ptr
{
    impl::session_t session;

public:
    /// Allocates a new session and wraps it into a `session_ptr`.
    static session_ptr make();

    /// Deallocates the session pointed to by this `session_ptr`.
    static void free(session_ptr &session);

    /// Wraps a raw session pointer.
    explicit session_ptr(ledger::session_t *session) noexcept
      : session(session)
    {
    }

    /// Returns the raw session pointer.
    inline ledger::session_t* as_ptr() const noexcept
    {
        return session.session;
    }

    /// Checks whether the session pointer is null.
    inline bool operator!() const noexcept
    {
        return !session.session;
    }

    /// Dereferences this pointer into session object.
    inline impl::session_t* operator->() noexcept
    {
        return &session;
    }

    /// Dereferences this pointer into session object.
    inline const impl::session_t* operator->() const noexcept
    {
        return &session;
    }
};

} // namespace ledger_wrap

#endif // LEDGER_WRAP_SESSION_H
