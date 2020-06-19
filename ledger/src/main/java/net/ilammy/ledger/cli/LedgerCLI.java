package net.ilammy.ledger.cli;

import java.io.IOException;

public class LedgerCLI {
    public static Process exec(String... args) {
        String[] command = new String[args.length + 1];
        command[0] = "lib...hello...so";
        System.arraycopy(args, 0, command, 1, args.length);

        try {
            return Runtime.getRuntime().exec(command);
        }
        catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
