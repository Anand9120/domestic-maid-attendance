package com.app.maidattendance;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class MaidAttendanceApplication {
    public static void main(String[] args) {
        SpringApplication.run(MaidAttendanceApplication.class, args);
    }
}
