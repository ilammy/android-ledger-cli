#include <jni.h>

#include <exception>
#include <stdexcept>

#include <ledger_wrap/session.h>

#include "exceptions.h"

static inline jlong to_jlong(ledger_wrap::session_ptr session)
{
    return reinterpret_cast<jlong>(session.as_ptr());
}

static inline ledger_wrap::session_ptr from_jlong(jlong session)
{
    return ledger_wrap::session_ptr(reinterpret_cast<ledger::session_t*>(session));
}

extern "C" JNIEXPORT
jlong JNICALL Java_net_ilammy_ledger_api_Session_newSession(JNIEnv *env, jclass klass)
{
    try {
        auto session = ledger_wrap::session_ptr::make();
        return to_jlong(session);
    }
    catch (const std::exception &e) {
        ledger_jni::rethrow_as_java_runtime_exception(env, e);
        return 0;
    }
}

extern "C" JNIEXPORT
void JNICALL Java_net_ilammy_ledger_api_Session_deleteSession(JNIEnv *env, jclass klass, jlong sessionPtr)
{
    try {
        auto session = from_jlong(sessionPtr);
        ledger_wrap::session_ptr::free(session);
    }
    catch (const std::exception &e) {
        ledger_jni::rethrow_as_java_runtime_exception(env, e);
    }
}

extern "C" JNIEXPORT
void JNICALL Java_net_ilammy_ledger_api_Session_readJournalFromString(JNIEnv *env, jclass klass, jlong sessionPtr, jbyteArray data)
{
    try {
        auto session = from_jlong(sessionPtr);
        if (!session) {
            throw std::invalid_argument("sessionPtr cannot be null");
        }

        // Copy Java byte array into a string.
        auto dataLen = env->GetArrayLength(data);
        std::string dataString(dataLen, 0);
        {
            auto bytes = env->GetPrimitiveArrayCritical(data, nullptr);
            if (!bytes) {
                return; // Java exception already thrown
            }
            dataString.assign(static_cast<const char*>(bytes), dataLen);
            env->ReleasePrimitiveArrayCritical(data, bytes, JNI_ABORT);
        }

        session->read_journal_from_string(dataString);
    }
    catch (const std::exception &e) {
        ledger_jni::rethrow_as_java_runtime_exception(env, e);
    }
}
