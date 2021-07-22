package com.sachin.work.serviceB.pkg;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.stereotype.Controller;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Controller
public class MyController {

    @Autowired
    private MyService myService;

    @MessageMapping("hello")
    public Mono<MyResponseVO> execute(MyRequestVO vo) {
        return this.myService.greet(vo);
    }
}
