#include <jni.h>

#include <exception>
#include <stdexcept>

// First <system.hh> before any other Ledget headers
#include <system.hh>
#include <report.h>
#include <scope.h>
#include <session.h>

#include "global.h"
#include "exceptions.h"

extern "C" JNIEXPORT
jlong JNICALL Java_net_ilammy_ledger_api_Session_newSession(JNIEnv *env, jclass klass)
{
    try {
        auto session = new ledger::session_t();
        ledger_jni::init_ledger_globals(session);
        return reinterpret_cast<jlong>(session);
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
        auto session = reinterpret_cast<ledger::session_t*>(sessionPtr);
        if (!session) {
            throw std::invalid_argument("sessionPtr cannot be null");
        }
        delete session;
    }
    catch (const std::exception &e) {
        ledger_jni::rethrow_as_java_runtime_exception(env, e);
    }
}

extern "C" JNIEXPORT
jlong JNICALL Java_net_ilammy_ledger_api_Session_getJournal(JNIEnv *env, jclass klass, jlong sessionPtr)
{
    try {
        auto session = reinterpret_cast<ledger::session_t*>(sessionPtr);
        if (!session) {
            throw std::invalid_argument("sessionPtr cannot be null");
        }

        auto journal = session->get_journal();
        return reinterpret_cast<jlong>(journal);
    }
    catch (const std::exception &e) {
        ledger_jni::rethrow_as_java_runtime_exception(env, e);
        return 0;
    }
}

extern "C" JNIEXPORT
void JNICALL Java_net_ilammy_ledger_api_Session_readJournalFromString(JNIEnv *env, jclass klass, jlong sessionPtr, jbyteArray data)
{
    try {
        auto session = reinterpret_cast<ledger::session_t*>(sessionPtr);
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
