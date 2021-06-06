package com.example.demo.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.IntStream;

public class GenUtil {

  public static final DateTimeFormatter FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

  public static void printStr(final Object s) {
    System.out.println(String.format("[%s][%s]: %s", FORMAT.format(LocalDateTime.now()), Thread.currentThread().getName(), s));
  }

  public static <T> void  printList(final List<T> list) {

    final StringBuilder sb = new StringBuilder();
    IntStream.range(0, list.size()).forEach(i -> {
      sb.append(list.get(i));

      if (i != list.size()-1) {
        sb.append(", ");
      }
    });
    sb.append("\n");
    printStr(sb.toString());
  }

  public static <T> void  printArr(final T[] arr) {
    final List<T> list = new ArrayList<>();
    Arrays.stream(arr).forEach(list::add);
    printList(list);
  }
}
