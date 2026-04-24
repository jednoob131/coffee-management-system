package util;

import vn.payos.PayOS;

public class PayOSUtil {

    private static final String CLIENT_ID = "88d9ccba-0884-418f-a5ed-9b5714ee36d5";
    private static final String API_KEY = "efeb9027-d855-41fc-b9b3-cc6e0f4c175f";
    private static final String CHECKSUM_KEY = "c63b9697d0b5e0718aa0df8b4312fe3b60e787c4b116e30dc3c36b9c1dc58ccf";

    private static final PayOS payOS = new PayOS(
            CLIENT_ID,
            API_KEY,
            CHECKSUM_KEY
    );

    public static PayOS getPayOS() {
        return payOS;
    }

    public static String getClientId() {
        return CLIENT_ID;
    }

    public static String getApiKey() {
        return API_KEY;
    }

    public static String getChecksumKey() {
        return CHECKSUM_KEY;
    }
}