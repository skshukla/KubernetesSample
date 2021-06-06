package com.example.demo.threads;

import com.example.demo.threads.impl.MyBlockingQueue;
import com.example.demo.threads.impl.MyHeap;
import com.example.demo.threads.impl.MyReadWriteLock;
import com.example.demo.threads.impl.MySynchronizedQueue;
import com.example.demo.util.GenUtil;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import org.junit.jupiter.api.Test;
import org.springframework.util.Assert;

public class SampleThreadExamplesUnitTest {

  @Test
  public void blockingQueueExample() throws Exception {
    final MyBlockingQueue<Integer> bq = new MyBlockingQueue<>();

    Executors.newScheduledThreadPool(1).scheduleAtFixedRate(() -> {
      bq.printQueueState();
    }, 0, 5, TimeUnit.SECONDS);

    final ExecutorService manager = Executors.newFixedThreadPool(5);

    manager.submit(() -> {
      while (true) {
        bq.take();
        Thread.currentThread().sleep(2000);
      }
    });

    manager.submit(() -> {
      while (true) {
        bq.push(new Random().nextInt(100));
        Thread.currentThread().sleep(100);
      }
    });
    manager.shutdown();

    manager.awaitTermination(10, TimeUnit.SECONDS);

    Thread.currentThread().sleep(1000);
    bq.printQueueState();
  }


  @Test
  public void synchronizedQueueExample() throws Exception {

    final MySynchronizedQueue<Integer> sq = new MySynchronizedQueue<>();

    final ExecutorService manager = Executors.newFixedThreadPool(5);

    manager.submit(() -> {
      while (true) {
        sq.take();
        Thread.currentThread().sleep(3000);
      }
    });

    manager.submit(() -> {
      while (true) {
        sq.push(new Random().nextInt(100));
        Thread.currentThread().sleep(100);
      }
    });
    manager.shutdown();

    manager.awaitTermination(10, TimeUnit.SECONDS);
  }

  /**
   * For testing, there are 1 Writer and multiple Reader Threads. The sleep timings are set in a way to
   * depict the behaviour that when multiple readers are reading, it would print it fast and smooth
   * and shows that while multiple threads reading there is no locking, however when write thread
   * writes and sleeps, it would blocker other threads to read and give suddent jerks while printing
   * the output.
   */
  @Test
  public void readWriteLockExample() throws InterruptedException {

    final List<Integer> list = new ArrayList<>();

    final MyReadWriteLock myReadWriteLock = new MyReadWriteLock();

    final ExecutorService manager = Executors.newCachedThreadPool();

    final Runnable r1_Reader = () -> {
      while(true) {
        try {
          myReadWriteLock.readLock();
          GenUtil.printList(list);
          myReadWriteLock.readUnLock();
          Thread.currentThread().sleep(200);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
      }
    };

    final Runnable r2_Writer = () -> {
      while(true) {
        try {
          myReadWriteLock.writeLock();
          GenUtil.printStr("Acquired write lock.....");
          list.add(new Random().nextInt(100));
          Thread.currentThread().sleep(2 * 1000);
          myReadWriteLock.writeUnLock();
          Thread.currentThread().sleep(500);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
      }
    };


    manager.submit(r1_Reader);
    manager.submit(r1_Reader);
    manager.submit(r1_Reader);
    manager.submit(r1_Reader);
    manager.submit(r2_Writer);
    manager.shutdown();

    manager.awaitTermination(10, TimeUnit.SECONDS);


  }

  @Test
  public void heapExample() {
    final MyHeap<Integer> myHeap = new MyHeap<>(10, true);
    myHeap.add(10);
    myHeap.add(9);
    myHeap.add(15);
    myHeap.add(4);
    myHeap.add(8);
    myHeap.add(3);
    myHeap.add(7);
    myHeap.add(13);
    myHeap.add(20);
    myHeap.add(1);
    Assert.isTrue(myHeap.remove() == 1, "Remove logic broken");
    Assert.isTrue(myHeap.remove() == 3, "Remove logic broken");
    Assert.isTrue(myHeap.remove() == 4, "Remove logic broken");
    Assert.isTrue(myHeap.remove() == 7, "Remove logic broken");
  }
}



