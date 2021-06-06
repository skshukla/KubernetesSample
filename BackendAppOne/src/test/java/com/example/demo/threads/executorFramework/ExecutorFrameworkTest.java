package com.example.demo.threads.executorFramework;

import com.example.demo.threads.executorFramework.impl.MyExecutorService;
import com.example.demo.threads.executorFramework.impl.MyExecutors;
import com.example.demo.threads.executorFramework.impl.MyFuture;
import com.example.demo.util.GenUtil;
import org.junit.jupiter.api.Test;

public class ExecutorFrameworkTest {

  @Test
  public void executorFrameworkExample() throws Exception {
    final MyExecutorService manager = MyExecutors.newFixedThreadPool(3);
    final MyFuture<Integer> myFuture = manager.submit( () -> {
      Thread.currentThread().sleep(2 * 1000);
      return 20;
    });

    GenUtil.printStr(myFuture.get());
  }

}
