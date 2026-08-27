package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    @Autowired(required = false)
    private JavaMailSender mailSender; // optional - app can run without SMTP configured

    public void sendOtpEmail(User user, String otp) {
        String subject = "Verify your email - Tax Compliance";
        String text = String.format("Hello %s,\n\nYour verification code is: %s\nIt will expire in 15 minutes.\n\nIf you did not request this, please ignore.",
                user.getFullName() != null ? user.getFullName() : user.getUsername(), otp);

        if (mailSender != null) {
            try {
                SimpleMailMessage message = new SimpleMailMessage();
                message.setTo(user.getEmail());
                message.setSubject(subject);
                message.setText(text);
                mailSender.send(message);
                log.info("Sent OTP email to {}", user.getEmail());
            } catch (Exception e) {
                log.error("Failed to send OTP email to {}: {}", user.getEmail(), e.getMessage());
            }
        } else {
            // Fallback: log OTP so developers can test without SMTP
            log.info("Mail sender not configured. OTP for {} is: {}", user.getEmail(), otp);
        }
    }
}
