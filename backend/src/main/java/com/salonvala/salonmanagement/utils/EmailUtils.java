package com.salonvala.salonmanagement.utils;

import org.springframework.stereotype.Component;

@Component
public class EmailUtils {

    public void sendEmail(String to, String subject, String message) {
        // TODO – Integrate SMTP or external service
        System.out.println("Email Sent To: " + to);
        System.out.println("Subject: " + subject);
        System.out.println("Message: " + message);
    }
}
