package com.example.demo.threads.impl;

import com.example.demo.util.GenUtil;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

public class MyReadWriteLock {

  private List<ThreadInfo> threadsAcquiredLock = new ArrayList<>();
  private List<ThreadInfo> threadsInQueue = new ArrayList<>();

  private void printCountOfAcquiredAndInQueueReadWriteLockCount() {
    long readerAcquired = this.threadsAcquiredLock.stream().filter(e -> e.isReader).count();
    long readerInQueue = this.threadsInQueue.stream().filter(e -> e.isReader).count();

    long writerAcquired = this.threadsAcquiredLock.stream().filter(e -> !e.isReader).count();
    long writerInQueue = this.threadsInQueue.stream().filter(e -> !e.isReader).count();

    GenUtil.printStr(String
        .format("readerAcquired {%d}, readerInQueue {%d}, writerAcquired {%d}, writerInQueue {%d}",
            readerAcquired, readerInQueue, writerAcquired, writerInQueue));

  }

  public synchronized void readLock() throws InterruptedException {

    final ThreadInfo info = new ThreadInfo(Thread.currentThread(), true);
    this.threadsInQueue.add(info);
    while (hasWriterThreadAcquiredLock(this.threadsAcquiredLock)) {
      this.wait();
    }

    this.threadsAcquiredLock.add(info);
    this.threadsInQueue.remove(info);
    printCountOfAcquiredAndInQueueReadWriteLockCount();
    this.notifyAll();

  }

  public synchronized void readUnLock() throws InterruptedException {
    this.threadsAcquiredLock.remove(new ThreadInfo(Thread.currentThread(), true));
    this.notifyAll();
  }

  public synchronized void writeLock() throws InterruptedException {

    final ThreadInfo info = new ThreadInfo(Thread.currentThread(), false);
    this.threadsInQueue.add(info);
    while (this.threadsAcquiredLock.size() > 0) {
      this.wait();
    }

    this.threadsAcquiredLock.add(info);
    this.threadsInQueue.remove(info);
    printCountOfAcquiredAndInQueueReadWriteLockCount();
    this.notifyAll();
  }

  public synchronized void writeUnLock() throws InterruptedException {
    this.threadsAcquiredLock.remove(new ThreadInfo(Thread.currentThread(), false));
    this.notifyAll();
  }

  private boolean hasWriterThreadAcquiredLock(final List<ThreadInfo> threadInfoList) {
    return threadInfoList.stream().filter(e -> !e.isReader()).collect(Collectors.toList()).size()
        > 0;
  }

  static class ThreadInfo {

    private Thread t;
    private boolean isReader;

    public ThreadInfo() {

    }

    public ThreadInfo(Thread t, boolean isReader) {
      this.t = t;
      this.isReader = isReader;
    }

    @Override
    public int hashCode() {
      return this.t.hashCode();
    }

    @Override
    public boolean equals(Object other) {
      if (!(other instanceof ThreadInfo)) {
        return false;
      }
      final ThreadInfo otherInfo = (ThreadInfo) other;

      if (!(otherInfo.getT().equals(this.getT()))) {
        return false;
      }

      if (!Objects.equals(otherInfo.isReader, this.isReader)) {
        return false;
      }
      return true;
    }

    public Thread getT() {
      return t;
    }

    public void setT(Thread t) {
      this.t = t;
    }

    public boolean isReader() {
      return isReader;
    }

    public void setReader(boolean reader) {
      isReader = reader;
    }
  }

}
