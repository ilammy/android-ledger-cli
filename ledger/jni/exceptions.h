#ifndef LEDGER_JNI_EXCEPTIONS_H
#define LEDGER_JNI_EXCEPTIONS_H

#include <exception>

#include <jni.h>

namespace ledger_jni
{

void rethrow_as_java_runtime_exception(JNIEnv *env, const std::exception &e);

} // namespace ledger_jni

#endif // LEDGER_JNI_EXCEPTIONS_H
