#ifndef LEDGER_WRAP_SESSION_H
#define LEDGER_WRAP_SESSION_H

#include <ledger_wrap/forward.h>

namespace ledger_wrap
{

class session_ptr
{
    ledger::session_t *session;

public:
    static session_ptr make();
    static void free(session_ptr &session);

    session_ptr(ledger::session_t *session)
      : session(session)
    {
    }
};

} // namespace ledger_wrap

#endif // LEDGER_WRAP_SESSION_H
