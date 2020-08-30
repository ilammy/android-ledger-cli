package net.ilammy.ledger.api;

/**
 * Session owns an individual journal and provides supporting operations on it.
 */
public final class Session implements AutoCloseable {
    static {
        System.loadLibrary("ledger_jni");
    }

    // Pointer to native ledger::session_t object.
    private long sessionPtr;

    private final Journal journal;

    private static native long newSession();
    private static native void deleteSession(long sessionPtr);

    /**
     * Make a new empty session.
     *
     * Remember to close this session after you're done with it to avoid memory leaks.
     */
    public Session() {
        sessionPtr = newSession();

        journal = Journal(this);
    }

    /**
     * Close and free this session.
     *
     * Closing a session also closes the journal associated with it, invalidating the journal
     * object along with all derived data such as transactions, postings, etc.
     */
    public void close() {
        journal.close();

        if (sessionPtr != 0) {
            deleteSession(sessionPtr);
            sessionPtr = 0;
        }
    }

    private static native long getJournal(long sessionPtr);

    /**
     * Return a pointer to the native ledger::journal_t object.
     */
    long getJournalPtr() {
        return getJournal(sessionPtr);
    }

    /**
     * Get the journal object of this session.
     *
     * Remember that the journal becomes invalidated once the session is closed.
     */
    public Journal getJournal() {
        return journal;
    }

    private static native void readJournalFromString(long sessionPtr, byte[] data);

    /**
     * Read in a journal file from memory buffer.
     */
    public void readJournalFromString(byte[] data) {
        readJournalFromString(sessionPtr, data);
    }
}
