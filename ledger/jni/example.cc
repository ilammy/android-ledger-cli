#include <jni.h>

// First <system.hh> before any other Ledget headers
#include <system.hh>
#include <session.h>

extern "C" JNIEXPORT
void JNICALL Java_net_ilammy_ledger_api_Ledger_demo(JNIEnv *env, jobject self)
{
    ledger::session_t session;
}
