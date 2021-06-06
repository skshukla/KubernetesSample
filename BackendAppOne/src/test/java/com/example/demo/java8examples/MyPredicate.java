package com.example.demo.java8examples;

@FunctionalInterface
public interface MyPredicate<T> {

  public boolean apply(T t);

  default int defaultDouble(final int x) {
    return 2*x;
  }

  static int staticTriple(final int x) {
    return 3*x;
  }
}
