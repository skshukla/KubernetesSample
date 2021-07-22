package com.sachin.work.serviceC.pkg;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.UUID;

@RestController
@RequestMapping("/service/c")
public class MyController2 {


    @Autowired
    private RestTemplate restTemplate;

    @GetMapping
    public MyResponseVO defaultResponse() {
        System.out.println("Called the default get for service C");
        return new MyResponseVO(String.format("service-c: {%s}", getIPAddress()) + UUID.randomUUID().toString());
    }

    @GetMapping("random")
    public String sample() {
        return UUID.randomUUID().toString();
    }

    private String getIPAddress() {
        try {
            final String ipAddress = java.net.Inet4Address.getLocalHost().getHostAddress();
            System.out.println(String.format("Ip address of machine is {%s}", ipAddress));
            return ipAddress;
        } catch (final Exception ex) {
            ex.printStackTrace();
        }

        return "localhost";

    }
}