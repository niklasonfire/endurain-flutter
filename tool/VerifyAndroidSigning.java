import java.io.File;
import java.security.GeneralSecurityException;
import java.security.KeyStore;
import java.security.PrivateKey;

/** Checks the exact signing passwords without displaying credentials. */
class VerifyAndroidSigning {
    public static void main(String[] args) throws Exception {
        KeyStore store = KeyStore.getInstance(
            new File(args[0]),
            System.getenv("ANDROID_KEYSTORE_PASSWORD").toCharArray()
        );
        if (!(store.getKey(
            System.getenv("ANDROID_KEY_ALIAS"),
            System.getenv("ANDROID_KEY_PASSWORD").toCharArray()
        ) instanceof PrivateKey)) {
            throw new GeneralSecurityException("The supplied alias has no private key.");
        }
    }
}
