package net.ilammy.ledger.api;

/**
 * Journal owns transactions and postings.
 */
public final class Journal {
    static {
        System.loadLibrary("ledger_jni");
    }

    // Pointer to native ledger::journal_t object.
    private long journalPtr;

    /**
     * Make a new journal for a session.
     *
     * Normally there is only one Journal object for each Session object.
     */
    Journal(Session session) {
        journalPtr = session.getJournalPtr();
    }

    /**
     * Close this journal.
     *
     * This method is called when the parent session is closed, freeing native journal object.
     * Since there may be Java references to this Journal object in the application,
     * this method makes sure that all future method calls does not cause use-after-free.
     */
    void close() {
        if (journalPtr != 0) {
            journalPtr = 0;
        }
    }
}
