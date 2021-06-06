package com.example.demo.threads.executorFramework.impl;

public class MyExecutors {

  public static MyExecutorService newFixedThreadPool(int nThreads) {
    return new MyExecutorService(nThreads);
  }
}
