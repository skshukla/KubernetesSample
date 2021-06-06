package com.example.demo.it;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;
import org.springframework.test.annotation.Rollback;
import org.springframework.util.Assert;

@SpringBootTest
@Rollback(value = true)
public class BaseTest {

  @Autowired
  protected ApplicationContext applicationContext;

	@Test
	void contextLoads() {
    Assert.notNull(this.applicationContext, "Application context cannot be null!");
	}

}
