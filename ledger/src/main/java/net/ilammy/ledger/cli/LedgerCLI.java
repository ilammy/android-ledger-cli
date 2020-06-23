package net.ilammy.ledger.cli;

import android.content.Context;
import android.support.annotation.NonNull;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Command-line interface to Ledger.
 */
public class LedgerCLI {
    private final Context context;

    /**
     * Initialize Ledger CLI with Android context.
     * @param context Android context to use
     */
    public LedgerCLI(@NonNull Context context) {
        this.context = context;
    }

    private static final String LEDGER_PATH = "lib/lib...ledger...so";

    private String getLedgerPath() {
        return new File(context.getDataDir(), LEDGER_PATH).getAbsolutePath();
    }

    /**
     * Execute Ledger with provided arguments.
     * @param args command-line arguments to Ledger
     * @return Ledger process descriptor.
     */
    public Process exec(@NonNull String... args) {
        try {
            return prepare(args).start();
        } catch (IOException e) {
            // This exception can happen if the binary file is not executable.
            // Our file should be executable, otherwise it's an error.
            throw new RuntimeException(e);
        }
    }

    /**
     * Prepare a new Ledger invocation.
     * @param args command-line arguments to Ledger
     * @return Ledger process builder.
     */
    public ProcessBuilder prepare(@NonNull String... args) {
        return prepare(Arrays.asList(args));
    }

    /**
     * Prepare a new Ledger invocation.
     * @param args command-line arguments to Ledger
     * @return Ledger process builder.
     */
    public ProcessBuilder prepare(@NonNull List<String> args) {
        ArrayList<String> fullArgs = new ArrayList<>();
        fullArgs.add(getLedgerPath());
        fullArgs.addAll(args);

        ProcessBuilder builder = new ProcessBuilder();
        builder.command(fullArgs);
        return builder;
    }
}
