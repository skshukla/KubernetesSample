package com.sachin.work.serviceC.pkg;

import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.util.Date;

@Service
public class MyService {

    public Mono<MyResponseVO> greet(MyRequestVO vo) {
        System.out.println("Coming to greet method..." + vo.getName());
        return Mono.justOrEmpty(new MyResponseVO(String.format("[%s] Hello Mono Mr. {%s}", new Date().toString(), vo.getName())));
    }
}
