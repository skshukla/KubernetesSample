package com.example.demo.threads.impl;

import com.example.demo.util.GenUtil;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class MyBlockingQueue<T> {

  private final int MAX_SIZE;
  final List<T> list = new ArrayList<>();
  private final Lock lock = new ReentrantLock();
  private final Condition cForFull = lock.newCondition();
  private final Condition cForEmpty = lock.newCondition();

  public MyBlockingQueue() {
    this(10);
  }

  public MyBlockingQueue(final int MAX_SIZE) {
    this.MAX_SIZE = MAX_SIZE;
  }


  public void push(T t) {
    lock.lock();

    try {
      while (list.size() == MAX_SIZE) {
        cForFull.await();
      }
      list.add(t);
      GenUtil.printStr(String.format("Pushed Element {%s}", t));
      cForEmpty.signalAll();
    } catch (final InterruptedException ex) {

    } finally {
      lock.unlock();
    }

  }

  public T take() {
    lock.lock();
    try {
      while (list.size() == 0) {
        cForEmpty.await();
      }
      T e = list.remove(0);
      GenUtil.printStr(String.format("Took element {%s}", e));
      cForFull.signalAll();
      return e;
    } catch (InterruptedException ex) {

    } finally {
      lock.unlock();
    }
    return null;
  }

  public void printQueueState() {
    lock.lock();
    try {
      GenUtil.printStr("Acuired the lock for print..now would hold it for longer..");
      GenUtil.printList(list);
    } catch (Exception ex) {

    } finally {
      lock.unlock();
    }

  }


}