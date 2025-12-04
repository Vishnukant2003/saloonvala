package com.salonvala.salonmanagement.utils;

import org.springframework.stereotype.Component;

@Component
public class SmsUtils {

    public void sendSMS(String mobile, String message) {
        // TODO – Integrate Twilio / MSG91 / Fast2SMS
        System.out.println("SMS Sent To: " + mobile);
        System.out.println("Message: " + message);
    }
}
