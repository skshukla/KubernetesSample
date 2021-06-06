package com.example.demo.threads.executorFramework.impl;

import com.example.demo.threads.impl.MyBlockingQueue;
import java.util.concurrent.Callable;
import java.util.stream.IntStream;

public class MyExecutorService<T> {

  final MyBlockingQueue<MyFuture<T>> mbq = new MyBlockingQueue<>();

  public MyExecutorService(int nThreads) {

    IntStream.range(0, nThreads).forEach(i -> {
      initNewThread();
    });
  }

  private void initNewThread() {
    new Thread(() -> {

      while(true) {
        try {
          final MyFuture<T> myFuture = mbq.take();
          myFuture.execute();
        } catch (Exception e) {
          e.printStackTrace();
        }
      }

    }).start();
  }

  public MyFuture<T> submit(final Callable<T> callable) {
    final MyFuture<T> myFuture = new MyFuture<>(callable);
    mbq.push(myFuture);
    return myFuture;
  }
}
