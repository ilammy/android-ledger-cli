package net.ilammy.ledger.api;

// Since by Google's grace we are not allowed to use Java 8 or later on Android,
// here is a bunch of convenience assertions that otherwise work better with lambdas.

import static org.junit.Assert.assertNotNull;

final class Assert {
    /**
     * Assert that <code>runnable</code> throws an exception.
     *
     * @param runnable runnable to test
     */
    public static void assertThrows(Runnable runnable) {
        Exception e = trapException(runnable);
        assertNotNull("expression must throw an exception", e);
    }

    private static Exception trapException(Runnable runnable) {
        try {
            runnable.run();
            return null;
        } catch (Exception e) {
            return e;
        }
    }
}
