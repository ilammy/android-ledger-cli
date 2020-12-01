#ifndef LEDGER_WRAP_GLOBAL_H
#define LEDGER_WRAP_GLOBAL_H

#include <ledger_wrap/forward.h>

namespace ledger_wrap
{

/// Initialize Ledger's global state: session context, scope globals, etc.
///
/// Call it once you create the first session object.
///
/// This function is idempotent: i.e., it does nothing on second call.
void init_ledger_globals(ledger::session_t *first_session);

} // namespace ledger_wrap

#endif // LEDGER_WRAP_GLOBAL_H
