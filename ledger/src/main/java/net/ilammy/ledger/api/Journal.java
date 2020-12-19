package net.ilammy.ledger.api;

public final class Journal {

    // Pointer to native ledger::journal_t object.
    private long journalPtr;

    Journal(long journalPtr) {
        this.journalPtr = journalPtr;
    }

    /**
     * Close this journal.
     *
     * Closing a journal does not free the native journal object (which is owned by its session).
     * However, it does invalidate this Java object along with all data derived from it,
     * such as transactions, postings, etc.
     */
    void close() {
        journalPtr = 0;
    }

    // TODO: implement accessors
}
