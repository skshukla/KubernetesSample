package com.example.demo.threads.executorFramework.impl;

import com.example.demo.threads.impl.MyBlockingQueue;
import java.util.concurrent.Callable;

public class MyFuture<T> {

  private final MyBlockingQueue<T> myQueue = new MyBlockingQueue<>();
  private Callable<T> callable = null;

  public MyFuture(final Callable<T> callable) {
    this.callable = callable;
  }

  public T get() throws InterruptedException {

    return myQueue.take();
  }

  protected void execute() throws Exception {
    final T t = this.callable.call();
    myQueue.push(t);
  }

}
