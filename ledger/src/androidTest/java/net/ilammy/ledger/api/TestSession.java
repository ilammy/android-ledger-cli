package net.ilammy.ledger.api;

import org.junit.Test;

import static net.ilammy.ledger.api.Assert.assertThrows;

public class TestSession {
    @Test
    public void readJournalString_Valid() {
        final String journal = "" +
                "2020-12-17 * Valid transaction\n" +
                "    Assets:Testing       $1000\n" +
                "    Equity\n";

        try (Session session = new Session()) {
            session.readJournalFromString(journal);
        }
    }

    @Test
    public void readJournalString_Invalid() {
        // This transaction is unbalanced:
        final String journal = "" +
                "2020-12-17 * Valid transaction\n" +
                "    Assets:Testing       $1000\n" +
                "    Equity                $-99\n";

        try (Session session = new Session()) {
            assertThrows(new Runnable() {
                @Override
                public void run() {
                    session.readJournalFromString(journal);
                }
            });
        }
    }
}
