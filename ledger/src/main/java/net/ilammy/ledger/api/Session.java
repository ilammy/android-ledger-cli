package net.ilammy.ledger.api;

import android.support.annotation.NonNull;

import java.nio.charset.StandardCharsets;

/**
 * Session owns an individual journal and provides supporting operations on it.
 */
public final class Session implements AutoCloseable {
    static {
        System.loadLibrary("ledger_jni");
    }

    // Pointer to native ledger::session_t object.
    private long sessionPtr;

    // Cached journal of this session.
    private Journal journal;

    private static native long newSession();
    private static native void deleteSession(long sessionPtr);

    /**
     * Make a new empty session.
     *
     * Remember to close this session after you're done with it to avoid memory leaks.
     */
    public Session() {
        sessionPtr = newSession();
    }

    /**
     * Close and free this session.
     *
     * Closing a session also closes the journal associated with it, invalidating the journal
     * object along with all derived data such as transactions, postings, etc.
     */
    public void close() {
        if (sessionPtr != 0) {
            if (journal != null) {
                journal.close();
                journal = null;
            }
            deleteSession(sessionPtr);
            sessionPtr = 0;
        }
    }

    private static native void readJournalFromString(long sessionPtr, byte[] data);

    /**
     * Read in a journal file from memory buffer.
     */
    public void readJournalFromString(@NonNull byte[] data) {
        readJournalFromString(sessionPtr, data);
    }

    /**
     * Read in a journal file from a string.
     */
    public void readJournalFromString(@NonNull String data) {
        readJournalFromString(data.getBytes(StandardCharsets.UTF_8));
    }

    private static native long getJournal(long sessionPtr);

    /**
     * Get journal object.
     */
    @NonNull
    public Journal getJournal() {
        if (journal == null) {
            journal = new Journal(getJournal(sessionPtr));
        }
        return journal;
    }
}
