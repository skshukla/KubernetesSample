package com.sachin.work.serviceB.pkg;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

import java.util.UUID;

@RestController
@RequestMapping("/service/b")
public class MyController2 {


    @Autowired
    private RestTemplate restTemplate;

    @Value("${serviceC.url}")
    private String SERVICE_C_URL;

    @GetMapping
    public MyResponseVO defaultResponse() {
        System.out.println("Called the default get for service B");
        return new MyResponseVO(String.format("service-b: {%s}", getIPAddress()) + UUID.randomUUID().toString());
    }

    @GetMapping("random")
    public String sample() {
        return UUID.randomUUID().toString();
    }

    @GetMapping("/call/service/c")
    public MyResponseVO callServiceC() {
        System.out.println("Going to call service C");
        MyResponseVO vo = restTemplate.getForEntity(SERVICE_C_URL, MyResponseVO.class).getBody();
        vo.setMsg(String.format("service-b: {%s}", getIPAddress()) + vo.getMsg());
        return vo;
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