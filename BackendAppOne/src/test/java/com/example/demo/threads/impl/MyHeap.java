package com.example.demo.threads.impl;


public class MyHeap<T extends Comparable> {

  private final boolean isMinHeap;
  private final int size;
  private int currentNoOfElements = -1;
  private final T[] data;

  public MyHeap() {
    this(5, true);
  }

  public MyHeap(final int size, final boolean isMinHeap) {
    this.size = size;
    this.isMinHeap = isMinHeap;
    this.data = (T[]) new Integer[size];
  }

  public void add(T t) {
    if (currentNoOfElements >= this.size - 1) {
      throw new HeapFullException(this.size);
    }
    data[++currentNoOfElements] = t;

    int counter = this.currentNoOfElements;
    for (; counter > 0; ) {
      int parentIndex = this.getParentElementIndex(counter);

      if (isMinHeap && this.data[parentIndex].compareTo(this.data[counter]) >= 0) {
        this.swap(this.data, parentIndex, counter);
        counter = parentIndex;
        continue;
      } else if (!isMinHeap && this.data[parentIndex].compareTo(this.data[counter]) < 0) {
        this.swap(this.data, parentIndex, counter);
        counter = parentIndex;
        continue;
      }
      break;
    }

  }

  public T remove() {
    final T returnVal = data[0];
    this.data[0] = this.data[currentNoOfElements];
    this.data[currentNoOfElements--] = null;


    for (int rootIndex = 0;; ) {
      int firstChildIndex = this.getFirstChildIndex(rootIndex);
      if (firstChildIndex > this.currentNoOfElements) {
        break;
      }
      int secondChildIndex = this.currentNoOfElements == firstChildIndex ? -1 : firstChildIndex + 1;
      int smallerDataChildIndex = secondChildIndex == -1
          || this.data[firstChildIndex].compareTo(this.data[secondChildIndex]) < 0 ? firstChildIndex
          : secondChildIndex;
      if (this.isMinHeap && this.data[rootIndex].compareTo(this.data[smallerDataChildIndex]) > 0) {
        this.swap(this.data, rootIndex, smallerDataChildIndex);
        rootIndex = smallerDataChildIndex;
        continue;
      } else if (!this.isMinHeap
          && this.data[rootIndex].compareTo(this.data[smallerDataChildIndex]) < 0) {
        this.swap(this.data, rootIndex, smallerDataChildIndex);
        rootIndex = smallerDataChildIndex;
        continue;
      }
      break;
    }

    return returnVal;
  }

  private int getFirstChildIndex(int i) {
    return 2 * i + 1;
  }

  private void shift(T[] arr, int i, int j) {
    for (int k = i; k <= j; k++) {
      arr[k - 1] = arr[k];
    }
  }

  private void swap(T[] arr, int i, int j) {
    T tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
  }

  private int getParentElementIndex(int i) {
    return i % 2 == 0 ? (i / 2) - 1 : (i - 1) / 2;
  }

  public T[] getData() {
    return data;
  }
}

class HeapFullException extends RuntimeException {

  public HeapFullException(final int n) {
    super(String.format("Heap is full with {%d} elements, consider removing some elements", n));
  }
}
