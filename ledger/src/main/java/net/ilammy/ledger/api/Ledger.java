package net.ilammy.ledger.api;

public class Ledger {
    {
        System.loadLibrary("ledger_jni");
    }

    public Ledger() {
    }

    public native void demo();
}
