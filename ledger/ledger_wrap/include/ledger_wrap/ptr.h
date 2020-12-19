#ifndef LEDGER_WRAP_PTR_H
#define LEDGER_WRAP_PTR_H

//! 'Dumb pointer' utilities.

namespace ledger_wrap
{
namespace impl
{

/// Wrapper which forwards methods of `ledger::journal_t*`.
///
/// This one exists for the sake of `operator->` working as expected.
template <class T>
class dumb_t
{
    T *raw;

public:
    /// Raw object pointer type.
    typedef T *raw_ptr;

    /// Returns the raw object pointer.
    inline raw_ptr as_ptr() const noexcept
    {
        return raw;
    }

    /// Checks whether the raw object pointer is null.
    inline bool operator!() const noexcept
    {
        return !raw;
    }

protected:
    explicit dumb_t(raw_ptr raw) noexcept
            : raw(raw) // fight the power!
    {
    }
};

/// Dumb pointer wrapper.
///
/// Note that it's 'dumb' and does not track ownership or references.
///
/// You are allowed to copy and destroy this pointer as much as you want,
/// this does not affect the object it points to in any way.
template <class DumbT>
class dumb_ptr
{
    DumbT access;

public:
    /// Wraps a raw object pointer.
    explicit dumb_ptr(typename DumbT::raw_ptr raw) noexcept
            : access(raw)
    {
    }

    /// Returns the raw object pointer.
    inline typename DumbT::raw_ptr as_ptr() const noexcept
    {
        return access.as_ptr();
    }

    /// Checks whether the raw object pointer is null.
    inline bool operator!() const noexcept
    {
        return !access;
    }

    /// Dereferences this pointer into access object.
    inline DumbT *operator->() noexcept
    {
        return &access;
    }

    /// Dereferences this pointer into access object.
    inline const DumbT *operator->() const noexcept
    {
        return &access;
    }
};

} // namespace impl
} // namespace ledger

#endif // LEDGER_WRAP_PTR_H
