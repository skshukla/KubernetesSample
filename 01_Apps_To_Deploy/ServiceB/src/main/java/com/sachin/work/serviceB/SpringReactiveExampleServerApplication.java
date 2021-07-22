package com.sachin.work.serviceB;

import com.sachin.work.serviceB.pkg.MyRequestVO;
import com.sachin.work.serviceB.pkg.MyResponseVO;
import com.sachin.work.serviceB.pkg.MyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;

@SpringBootApplication
public class SpringReactiveExampleServerApplication {

	@Bean
	public RestTemplate restTemplate() {
		return new RestTemplate();
	}

	public static void main(String[] args) {
		SpringApplication.run(SpringReactiveExampleServerApplication.class, args);
	}

}

@Component
class Server {

	@Autowired
	private MyService myService;

	@EventListener(ApplicationReadyEvent.class)
	public void execute() {
		System.out.println("Coming to server...");
		System.out.println("Done with the server call");

	}
}
