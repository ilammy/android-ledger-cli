#include <ledger_wrap/session.h>

// First <system.hh> before any other Ledger headers
#include <system.hh>
#include <session.h>

#include "global.h"

namespace ledger_wrap
{

session_ptr session_ptr::make()
{
    auto session = new ledger::session_t();
    init_ledger_globals(session);
    return session;
}

void session_ptr::free(session_ptr &session)
{
    delete session.session;
    session.session = nullptr;
}

} // namespace ledger_wrap
