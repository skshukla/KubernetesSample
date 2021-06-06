package com.example.demo.threads.impl;

import com.example.demo.util.GenUtil;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class MySynchronizedQueue<T> {


  private  T data = null;
  private final Lock lock = new ReentrantLock();
  private final Condition cNoData = lock.newCondition();
  private final Condition cHasData = lock.newCondition();



  public void push(T t) {
    lock.lock();

    try {
      while (this.data != null) {
        cNoData.await();
      }
      this.data = t;
      GenUtil.printStr(String.format("Pushed Element {%s}", t));
      cHasData.signalAll();

      while (this.data != null) {
        cNoData.await();
      }
      GenUtil.printStr(String.format("Consumer has read the element {%s} and hence exiting!\n", t));
    } catch (final InterruptedException ex) {

    } finally {
      lock.unlock();
    }

  }

  public T take() {
    lock.lock();
    try {
      while (this.data == null) {
        cHasData.await();
      }
      T e = this.data;
      this.data = null;
      cNoData.signalAll();
      GenUtil.printStr(String.format("Took element {%s}", e));
      return e;
    } catch (InterruptedException ex) {

    } finally {
      lock.unlock();
    }
    return null;
  }

}