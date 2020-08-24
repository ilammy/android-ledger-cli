#include "exceptions.h"

namespace ledger_jni
{

void rethrow_as_java_runtime_exception(JNIEnv *env, const std::exception &e)
{
    // TODO: cache class lookup
    auto klass = env->FindClass("java/lang/RuntimeException");
    if (!klass) {
        return; // This throws some other JVM exception.
    }

    // Assume that exception text is encoded in ASCII, which is subset of "modified UTF-8" used by JNI.
    // Also, ignore the result code since we have to way to handle double-fault here.
    env->ThrowNew(klass, e.what());
}
    
} // namespace ledger_jni
